-- SHARE PHASE: CREATE MAP DATA FOR THE TOP CASUAL STATIONS
--
-- Purpose:
-- Produce one map point for each station ID.
-- Where one station ID has more than one recorded name, use its most
-- frequently recorded name rather than splitting it into separate stations.

WITH valid_station_rides AS (

  SELECT
    start_station_id,
    start_station_name,
    start_lat,
    start_lng,
    member_casual

  FROM `cyclistic-capstone-202601.cyclistic_capstone.rides_clean`

  WHERE start_station_id IS NOT NULL
    AND TRIM(start_station_id) != ''
    AND start_station_name IS NOT NULL
    AND TRIM(start_station_name) != ''
    AND start_lat IS NOT NULL
    AND start_lng IS NOT NULL
  -- Keep only named public stations with usable coordinates.
),


station_name_counts AS (

  SELECT
    start_station_id,
    start_station_name,
    COUNT(*) AS name_occurrences
    -- Count how often each name is associated with each station ID.

  FROM valid_station_rides

  GROUP BY
    start_station_id,
    start_station_name
),


preferred_station_names AS (

  SELECT
    start_station_id,

    ARRAY_AGG(
      start_station_name
      ORDER BY name_occurrences DESC, start_station_name
      LIMIT 1
    )[OFFSET(0)] AS start_station_name
    -- Select the most frequently recorded name for each station ID.

  FROM station_name_counts

  GROUP BY start_station_id
),


station_summary AS (

  SELECT
    start_station_id,

    ROUND(AVG(start_lat), 6) AS station_latitude,
    ROUND(AVG(start_lng), 6) AS station_longitude,
    -- Calculate one representative location for each station ID.

    COUNTIF(member_casual = 'casual') AS casual_rides,
    COUNTIF(member_casual = 'member') AS member_rides,
    COUNT(*) AS total_station_rides,

    ROUND(
      100 * SAFE_DIVIDE(
        COUNTIF(member_casual = 'casual'),
        COUNT(*)
      ),
      2
    ) AS percentage_casual_rides

  FROM valid_station_rides

  GROUP BY start_station_id
  -- Group only by station ID so alternative names do not split the totals.
)


SELECT
  s.start_station_id,
  n.start_station_name,
  s.station_latitude,
  s.station_longitude,
  s.casual_rides,
  s.member_rides,
  s.total_station_rides,
  s.percentage_casual_rides

FROM station_summary AS s

INNER JOIN preferred_station_names AS n
  ON s.start_station_id = n.start_station_id

WHERE s.percentage_casual_rides > 50

ORDER BY s.casual_rides DESC

LIMIT 12;
