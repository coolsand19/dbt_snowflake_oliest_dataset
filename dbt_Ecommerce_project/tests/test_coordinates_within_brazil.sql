-- Test: Geolocation coordinates should be within Brazil geographic bounds
-- Brazil bounds: Latitude -34 to 6, Longitude -75 to -33
-- Expectation: This query should return 0 rows (or very few outliers)

SELECT 
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
FROM {{ ref('stg_geolocation') }}
WHERE geolocation_lat < -34 
   OR geolocation_lat > 6
   OR geolocation_lng < -75
   OR geolocation_lng > -33
