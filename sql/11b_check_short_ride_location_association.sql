-- PROCESS PHASE: TEST WHETHER VERY SHORT ELECTRIC-BIKE RIDES
-- ARE ASSOCIATED WITH MISSING STATIONS OR ROUNDED COORDINATES
--
-- Purpose:
-- Compare under-60-second electric-bike records with longer electric-bike records.
-- Results are separated by member and casual rider type.
--
-- The query removes duplicate copies and applies the exact date boundary
-- before making the comparison.
--
-- This query only reads and summarises data. It changes nothing.

WITH in_period_deduplicated AS (

  SELECT

    _TABLE_SUFFIX AS source_month,
    -- Retain the source-table month for duplicate handling.

    t.*
    -- Select all original trip columns from each table.

  FROM `cyclistic-capstone-202601.cyclistic_capstone.trips_*` AS t
  -- Read all 12 monthly tables and give them the short name t.

  WHERE started_at >= TIMESTAMP('2025-07-01 00:00:00')
    AND started_at < TIMESTAMP('2026-07-01 00:00:00')
  -- Keep only rides starting inside the exact analysis period.

  QUALIFY
    ROW_NUMBER() OVER (
      PARTITION BY ride_id
      ORDER BY _TABLE_SUFFIX
    ) = 1
  -- ROW_NUMBER gives each occurrence of a ride ID a number.
  -- PARTITION BY starts the numbering again for each ride ID.
  -- ORDER BY keeps the copy from the earliest source table.
  -- QUALIFY keeps only row number 1, removing the 35 extra duplicate copies.
),

prepared_electric_rides AS (

  SELECT

    member_casual,
    -- Retain rider type so members and casual riders can be compared.

    CASE

      WHEN DATE(started_at) = DATE '2025-11-02'
        AND ended_at <= started_at
      THEN TIMESTAMP_DIFF(ended_at, started_at, SECOND) + 3600
      -- Correct the 29 rides affected by the repeated daylight-saving hour.

      ELSE TIMESTAMP_DIFF(ended_at, started_at, SECOND)
      -- Use the recorded duration for all other rides.

    END AS duration_seconds,


    (
      start_station_name IS NULL
      OR TRIM(start_station_name) = ''
      OR start_station_id IS NULL
      OR TRIM(start_station_id) = ''
    ) AS missing_start_station,
    -- TRUE when the start-station name or ID is missing or empty.


    (
      end_station_name IS NULL
      OR TRIM(end_station_name) = ''
      OR end_station_id IS NULL
      OR TRIM(end_station_id) = ''
    ) AS missing_end_station,
    -- TRUE when the end-station name or ID is missing or empty.


    (
      start_lat IS NULL
      OR start_lng IS NULL
    ) AS missing_start_coordinates,
    -- TRUE when either start coordinate is missing.


    (
      end_lat IS NULL
      OR end_lng IS NULL
    ) AS missing_end_coordinates,
    -- TRUE when either end coordinate is missing.


    (
      start_lat IS NOT NULL
      AND start_lng IS NOT NULL
      AND ABS(start_lat - ROUND(start_lat, 2)) < 0.000000001
      AND ABS(start_lng - ROUND(start_lng, 2)) < 0.000000001
    ) AS start_coordinates_on_001_grid,
    -- TRUE when both start coordinates are present and equal to their
    -- values rounded to two decimal places.
    -- ABS measures the difference between the stored and rounded values.
    -- The tiny tolerance accounts for FLOAT storage.


    (
      end_lat IS NOT NULL
      AND end_lng IS NOT NULL
      AND ABS(end_lat - ROUND(end_lat, 2)) < 0.000000001
      AND ABS(end_lng - ROUND(end_lng, 2)) < 0.000000001
    ) AS end_coordinates_on_001_grid
    -- Apply the same 0.01-degree-grid check to the end coordinates.

  FROM in_period_deduplicated
  -- Use the date-filtered and deduplicated records.

  WHERE rideable_type = 'electric_bike'
  -- Restrict this test to electric bikes because every ride under
  -- 60 seconds was recorded as an electric bike.
)

SELECT

  member_casual,
  -- Separate members from casual riders.

  CASE
    WHEN duration_seconds < 60 THEN 'under_60_seconds'
    ELSE '60_seconds_or_more'
  END AS duration_group,
  -- Divide electric-bike rides into the short and longer comparison groups.

  COUNT(*) AS total_rides,
  -- Count rides in each rider-type and duration group.


  ROUND(
    100 * COUNTIF(missing_start_station) / COUNT(*),
    2
  ) AS pct_missing_start_station,
  -- Percentage with incomplete start-station information.


  ROUND(
    100 * COUNTIF(missing_end_station) / COUNT(*),
    2
  ) AS pct_missing_end_station,
  -- Percentage with incomplete end-station information.


  ROUND(
    100 * COUNTIF(missing_start_coordinates) / COUNT(*),
    2
  ) AS pct_missing_start_coordinates,
  -- Percentage with missing start latitude or longitude.


  ROUND(
    100 * COUNTIF(missing_end_coordinates) / COUNT(*),
    2
  ) AS pct_missing_end_coordinates,
  -- Percentage with missing end latitude or longitude.


  ROUND(
    100 * COUNTIF(start_coordinates_on_001_grid) / COUNT(*),
    2
  ) AS pct_start_coordinates_on_001_grid,
  -- Percentage whose start coordinates lie exactly on the 0.01-degree grid.


  ROUND(
    100 * COUNTIF(end_coordinates_on_001_grid) / COUNT(*),
    2
  ) AS pct_end_coordinates_on_001_grid,
  -- Percentage whose end coordinates lie exactly on the 0.01-degree grid.


  ROUND(
    100 * COUNTIF(
      missing_start_station
      AND start_coordinates_on_001_grid
    ) / COUNT(*),
    2
  ) AS pct_missing_start_station_and_001_grid,
  -- Percentage where missing start-station information and rounded
  -- start coordinates occur in the same record.


  ROUND(
    100 * COUNTIF(
      missing_end_station
      AND end_coordinates_on_001_grid
    ) / COUNT(*),
    2
  ) AS pct_missing_end_station_and_001_grid
  -- Percentage where missing end-station information and rounded
  -- end coordinates occur in the same record.

FROM prepared_electric_rides
-- Use the prepared electric-bike records and quality flags.

GROUP BY
  member_casual,
  duration_group
-- Produce one row for each rider-type and duration-group combination.

ORDER BY
  member_casual,
  duration_group;
-- Arrange the output consistently.
