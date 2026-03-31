# Define your whitelist here (space-separated paths)
# You can include root projects or nested ones like project-c/nested-api
ARG PROJECTS="benchmark ec2-instance-manager graphai timesheet"

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
        find "$proj" -type d \( -name target -o -name .git -o -name .claude \) -prune -o \
               -type f \( -name "Cargo.toml" -o -name "Cargo.lock" \) \
               -exec sh -c 'mkdir -p "/extract/$(dirname "{}")" && cp "{}" "/extract/{}"' \; ; \
    done


# ---------------------------------------------------
# Stage 2: The Vendor Builder
# ---------------------------------------------------
FROM rust:1.85 AS vendor-builder
WORKDIR /usr/src/app

ARG EXCLUDE_FROM_WORKSPACE

COPY --from=manifest-extractor /extract/ ./

RUN find . -mindepth 2 -name Cargo.toml -exec sh -c '\
        for manifest do \
            awk '\''\
                # Drop original workspace metadata and lint policy. The synthetic
                # vendoring workspace only needs package/dependency information.
                /^\[(workspace|lints)(\.|])/{skip=1; next} \
                /^\[/{skip=0} \
                !skip{print} \
            '\'' "$manifest" > "$manifest.tmp" && \
            mv "$manifest.tmp" "$manifest"; \
            if ! grep -q '\''^\[package\]'\'' "$manifest"; then \
                rm -f "$manifest"; \
            fi; \
        done \
    ' sh {} +

RUN echo "[workspace]" > Cargo.toml && \
    echo 'resolver = "3"' >> Cargo.toml && \
    echo "members = [" >> Cargo.toml && \
    LIST="$EXCLUDE_FROM_WORKSPACE" && \
    for toml in $(find . -mindepth 2 -name Cargo.toml); do \
        if grep -q '\[package\]' "$toml"; then \
            dir=$(dirname "$toml"); \
            clean_dir=${dir#./}; \
            mkdir -p "$dir/src" && touch "$dir/src/main.rs" && touch "$dir/src/lib.rs"; \
            skip=false; \
            for excl in $LIST; do \
                case "$clean_dir" in \
                    *"$excl"*) skip=true; break ;; \
                esac; \
            done; \
            if [ "$skip" = "true" ]; then \
                echo "--- EXCLUDING: $clean_dir"; \
            else \
                echo "+++ ADDING: $clean_dir"; \
                echo "\"$clean_dir\"," >> Cargo.toml; \
            fi; \
        fi; \
    done && \
    echo "]" >> Cargo.toml && \
    echo "exclude = [" >> Cargo.toml && \
    for excluded in $EXCLUDE_FROM_WORKSPACE; do \
        echo "\"$excluded\"," >> Cargo.toml; \
    done && \
    echo "]" >> Cargo.toml


# Step 3: Run Vendor
RUN mkdir -p .cargo && cargo vendor > .cargo/config.toml


# ---------------------------------------------------
# Stage 3: The Empty Storage Container
# ---------------------------------------------------
FROM scratch AS vendor-storage
WORKDIR /vendor-data

# ONLY copy the generated vendor files, leaving the fake workspace behind completely
COPY --from=vendor-builder /usr/src/app/vendor/ ./vendor/
COPY --from=vendor-builder /usr/src/app/.cargo/ ./.cargo/
