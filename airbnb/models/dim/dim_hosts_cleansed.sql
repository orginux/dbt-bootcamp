{{
        config(
                materialized='view'
        )
}}

WITH src_listings AS (
        SELECT *
        FROM {{ ref('src_hosts') }}
)
SELECT
        host_id,
        ifNull(host_name, 'Anonymous') AS host_name,
        is_superhost,
        created_at,
        updated_at
FROM src_listings
