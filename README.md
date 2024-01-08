# dbt bootcamp
Base on [The Complete dbt (Data Build Tool) Bootcamp](https://www.udemy.com/course/complete-dbt-data-build-tool-bootcamp-zero-to-hero-learn-dbt/) but with usig ClickHouse as a datastore.

## ClickHouse Table Structure
### Database
```sql
CREATE DATABASE airbnb ON CLUSTER `{cluster}`;
```

### Listings
```sql
CREATE TABLE airbnb.raw_listings_local ON CLUSTER `{cluster}`
(
    `id` Int32,
    `listing_url` String,
    `name` String,
    `room_type` String,
    `minimum_nights` Int32,
    `host_id` Int32,
    `price` String,
    `created_at` DateTime,
    `updated_at` DateTime
)
ENGINE = ReplicatedReplacingMergeTree('/clickhouse/tables/{cluster}/{shard}/airbnb/raw_listings', '{replica}')
ORDER BY id
;

CREATE TABLE airbnb.raw_listings ON CLUSTER '{cluster}' AS airbnb.raw_listings_local
ENGINE = Distributed('{cluster}', 'airbnb', 'raw_listings_local', intHash64(id))
;
```

### Reviews
```sql
CREATE TABLE IF NOT EXISTS airbnb.raw_reviews_local ON CLUSTER '{cluster}'
(
    listing_id Int32,
    date DateTime,
    reviewer_name String,
    comments String,
    sentiment String
) ENGINE = ReplicatedReplacingMergeTree('/clickhouse/tables/{cluster}/{shard}/airbnb/raw_reviews', '{replica}')
ORDER BY listing_id
;

CREATE TABLE IF NOT EXISTS airbnb.raw_reviews ON CLUSTER '{cluster}' AS airbnb.raw_reviews_local
ENGINE = Distributed('{cluster}', 'airbnb', 'raw_reviews_local', intHash64(listing_id))
;
```

### Hosts
```sql
CREATE TABLE IF NOT EXISTS airbnb.raw_hosts_local ON CLUSTER '{cluster}'
(
    id Int32,
    name String,
    is_superhost String,
    created_at DateTime,
    updated_at DateTime
) ENGINE = ReplicatedReplacingMergeTree('/clickhouse/tables/{cluster}/{shard}/airbnb/raw_hosts', '{replica}')
ORDER BY id
;

CREATE TABLE IF NOT EXISTS airbnb.raw_hosts ON CLUSTER '{cluster}'
AS airbnb.raw_hosts_local
ENGINE = Distributed('{cluster}', 'airbnb', 'raw_hosts_local', intHash64(id))
;
```

## Import data
### Set default date format
```sql
SET date_time_input_format='best_effort';
```

### Import listings
```sql
INSERT INTO airbnb.raw_listings_local SELECT *
FROM s3('s3://dbtlearn/listings.csv', 'CSV')
;
```

### Import reviews
```sql
INSERT INTO airbnb.raw_reviews SELECT *
FROM s3('s3://dbtlearn/reviews.csv', 'CSV')
;
```

### Import hosts
```sql
INSERT INTO airbnb.raw_hosts SELECT *
FROM s3('s3://dbtlearn/hosts.csv', 'CSV')
;
```
