-- Test: Geolocation coordinates must be within valid ranges
-- Latitude: -90 to 90, Longitude: -180 to 180
-- Expectation: This query should return 0 rows

SELECT 
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
FROM {{ ref('stg_geolocation') }}
WHERE geolocation_lat < -90 
   OR geolocation_lat > 90
   OR geolocation_lng < -180
   OR geolocation_lng > 180
