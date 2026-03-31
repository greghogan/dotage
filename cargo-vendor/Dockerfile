# Define your whitelist here (space-separated paths)
# You can include root projects or nested ones like project-c/nested-api
ARG PROJECTS="benchmark dactyl ec2-instance-manager graphmp timesheet"

# Define crates to EXCLUDE from the workspace array (space-separated)
ARG EXCLUDE_FROM_WORKSPACE="benchmark/ptr_hash_upstream"

# ---------------------------------------------------
# Stage 1: The Manifest Extractor
# ---------------------------------------------------
FROM alpine AS manifest-extractor
WORKDIR /extract

ARG PROJECTS

# Mount the whole context, but ONLY extract the whitelisted paths
RUN --mount=type=bind,target=/context \
    cd /context && \
    for proj in $PROJECTS; do \
        echo "Extracting manifests for: $proj"; \
        # Only run the find command inside the specific whitelisted directory
        find "$proj" -type d \( -name target -o -name .git \) -prune -o \
               -type f \( -name "Cargo.toml" -o -name "Cargo.lock" \) \
               -exec sh -c 'mkdir -p "/extract/$(dirname "{}")" && cp "{}" "/extract/{}"' \; ; \
    done

# ---------------------------------------------------
# Stage 2: The Vendor Builder
# ---------------------------------------------------
FROM rust:1.85 AS vendor-builder
WORKDIR /usr/src/app

# Pull the global EXCLUDE variable
ARG EXCLUDE_FROM_WORKSPACE

COPY --from=manifest-extractor /extract/ ./

RUN echo $EXCLUDE_FROM_WORKSPACE

# Step 2: Your "Deep Scan" Fake Workspace Generator
RUN echo '[workspace]' > Cargo.toml && \
    echo 'resolver = "3"' >> Cargo.toml && \
    echo 'members = [' >> Cargo.toml && \
    for toml in $(find . -mindepth 2 -name Cargo.toml); do \
        if grep -q '\[package\]' "$toml"; then \
            dir=$(dirname "$toml"); \
            clean_dir=${dir#./}; \
            \
            # 1. Create dummy files
            mkdir -p "$dir/src" && touch "$dir/src/main.rs" && touch "$dir/src/lib.rs"; \
            \
            # 2. Bulletproof Check against the exclusion list using grep
            # We wrap variables in spaces to ensure exact word matches
            if echo " $EXCLUDE_FROM_WORKSPACE " | grep -qF " $clean_dir "; then \
                echo "🚨 EXCLUDED: Skipping $clean_dir to avoid collision."; \
                continue; \
            fi; \
            \
            # 3. If we made it here, add it to the workspace
            echo "✅ ADDING: $clean_dir"; \
            echo "\"$clean_dir\"," >> Cargo.toml; \
        fi \
    done && \
    echo ']' >> Cargo.toml && \
    echo 'exclude = [' >> Cargo.toml && \
    for excluded in $EXCLUDE_FROM_WORKSPACE; do \
        echo "\"$excluded\"," >> Cargo.toml; \
    done && \
    echo ']' >> Cargo.toml

RUN mkdir -p .cargo && cargo vendor > .cargo/config.toml

RUN rm Cargo.toml && \
    find . -type d -name src -exec rm -rf {} +

# ---------------------------------------------------
# Stage 3: The Empty Storage Container
# ---------------------------------------------------
FROM scratch AS vendor-storage
WORKDIR /vendor-data

COPY --from=vendor-builder /usr/src/app/ ./
