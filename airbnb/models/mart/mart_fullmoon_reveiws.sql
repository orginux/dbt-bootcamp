{{
        config(
                materialized='table'
        )
}}

WITH fct_reviews AS (
        SELECT *
        FROM {{ ref('fct_reviews') }}
),

fullmoon_dates AS (
        SELECT *
        FROM {{ ref('seed_full_moon_dates') }}
)

SELECT
        r.*,
        if(fm.full_moon_date != '1970-01-01', 1, 0) AS is_fullmoon -- default data value
FROM airbnb_dbt.fct_reviews AS r
LEFT JOIN airbnb_dbt.seed_full_moon_dates AS fm ON toYYYYMMDD(r.review_date) = toYYYYMMDD(fm.full_moon_date)
