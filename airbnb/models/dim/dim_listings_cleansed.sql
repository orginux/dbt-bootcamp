{{
        config(
                materialized='view'
        )
}}

WITH src_listings AS (
        SELECT *
        FROM {{ ref('src_listings') }}
)
SELECT
        listing_id,
        listing_name,
        room_type,
        IF(minimum_nights=0, 1, minimum_nights) AS minimum_nights,
        host_id,
        toFloat64OrZero(replaceOne(price_str, '$', '')) AS price,
        created_at,
        updated_at
FROM src_listings
