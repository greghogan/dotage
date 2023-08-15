FROM alpine:latest
WORKDIR /work
ARG years

## TLC Trip Record Data
RUN BASE_URL="https://d37ci6vzurychx.cloudfront.net/trip-data" && \
  for year in ${years} ; do \
    mkdir ${year} && \
    for month in `seq -w 1 12` ; do \
      if [ "${year}${month}" -ge "200901" ] ; then wget --directory-prefix=${year} ${BASE_URL}/yellow_tripdata_${year}-${month}.parquet ; fi ; \
      if [ "${year}${month}" -ge "201308" ] ; then wget --directory-prefix=${year} ${BASE_URL}/green_tripdata_${year}-${month}.parquet ; fi ; \
      if [ "${year}${month}" -ge "201501" ] ; then wget --directory-prefix=${year} ${BASE_URL}/fhv_tripdata_${year}-${month}.parquet ; fi ; \
      if [ "${year}${month}" -ge "201902" ] ; then wget --directory-prefix=${year} ${BASE_URL}/fhvhv_tripdata_${year}-${month}.parquet ; fi ; \
    done \
  done


## Data Dictionaries and MetaData

# Trip Record User Guide
RUN wget https://www.nyc.gov/assets/tlc/downloads/pdf/trip_record_user_guide.pdf

# Yellow Trips Data Dictionary
RUN wget https://www.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf

# Green Trips Data Dictionary
RUN wget https://www.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_green.pdf

# FHV Trips Data Dictionary
RUN wget https://www.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_fhv.pdf

# High Volume FHV Trips Data Dictionary
RUN wget https://www.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_hvfhs.pdf

# Working With PARQUET Format
RUN wget https://www.nyc.gov/assets/tlc/downloads/pdf/working_parquet_format.pdf


## Taxi Zone Maps and Lookup Tables

# Taxi Zone Lookup Table (CSV)
RUN wget https://d37ci6vzurychx.cloudfront.net/misc/taxi+_zone_lookup.csv

# Taxi Zone Shapefile (PARQUET)
RUN wget https://d37ci6vzurychx.cloudfront.net/misc/taxi_zones.zip

# Taxi Zone Map – Bronx (JPG)
RUN wget https://www.nyc.gov/assets/tlc/images/content/pages/about/taxi_zone_map_bronx.jpg

# Taxi Zone Map – Brooklyn (JPG)
RUN wget https://www.nyc.gov/assets/tlc/images/content/pages/about/taxi_zone_map_brooklyn.jpg

# Taxi Zone Map – Manhattan (JPG)
RUN wget https://www.nyc.gov/assets/tlc/images/content/pages/about/taxi_zone_map_manhattan.jpg

# Taxi Zone Map – Queens (JPG)
RUN wget https://www.nyc.gov/assets/tlc/images/content/pages/about/taxi_zone_map_queens.jpg

# Taxi Zone Map – Staten Island (JPG)
RUN wget https://www.nyc.gov/assets/tlc/images/content/pages/about/taxi_zone_map_staten_island.jpg


# create single-layer image with only copied artifacts
FROM scratch
COPY --from=0 /work ./
