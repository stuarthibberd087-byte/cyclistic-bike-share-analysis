-- PROCESS PHASE: CREATE THE COMBINED CLEANED TABLE
--
-- Cleaning rules applied:
-- 1. Combine all 12 monthly source tables.
-- 2. Keep only rides starting within 1 July 2025–30 June 2026.
-- 3. Remove the 35 excess duplicate copies.
-- 4. Correct the calculated duration of the 29 daylight-saving rides.
-- 5. Remove rides lasting less than 60 seconds.
-- 6. Preserve missing station fields and rounded coordinates as supplied.
-- 7. Add fields needed for later time-based analysis.
--
-- The original monthly tables are not changed.

CREATE OR REPLACE TABLE
  `cyclistic-capstone-202601.cyclistic_capstone.rides_clean`
AS
-- Create a new table called rides_clean.
-- If rides_clean already exists, replace only that table.


WITH in_period AS (

  SELECT

    _TABLE_SUFFIX AS source_month,
    -- Preserve the month of the source table for traceability.
    -- This is not necessarily the month when the ride started.

    t.*
    -- Include every original column from the trip records.

  FROM `cyclistic-capstone-202601.cyclistic_capstone.trips_*` AS t
  -- Combine every monthly table whose name starts with trips_.

  WHERE started_at >= TIMESTAMP('2025-07-01 00:00:00')
    AND started_at < TIMESTAMP('2026-07-01 00:00:00')
  -- Keep rides starting inside the exact 12-month analysis period.
  -- This excludes the 102 records starting before 1 July 2025.
),


deduplicated AS (

  SELECT
    *
    -- Retain every column from the date-filtered records.

  FROM in_period

  QUALIFY
    ROW_NUMBER() OVER (
      PARTITION BY ride_id
      ORDER BY source_month
    ) = 1
  -- ROW_NUMBER numbers the records belonging to each ride ID.
  -- PARTITION BY ride_id starts again at 1 for every different ride ID.
  -- ORDER BY source_month keeps the copy from the earliest source table.
  -- QUALIFY keeps row number 1 and removes additional copies.
  -- Because the 35 duplicated pairs are exact copies, no ride information is lost.
),


durations_calculated AS (

  SELECT

    *,
    -- Retain all original columns plus source_month.

    CASE

      WHEN DATE(started_at) = DATE '2025-11-02'
        AND ended_at <= started_at
      THEN TIMESTAMP_DIFF(ended_at, started_at, SECOND) + 3600
      -- Add the repeated daylight-saving hour to the 29 affected rides.
      -- The original started_at and ended_at values remain unchanged.

      ELSE TIMESTAMP_DIFF(ended_at, started_at, SECOND)
      -- Calculate the ordinary duration for every other ride.

    END AS ride_duration_seconds
    -- Store the resulting duration in seconds.

  FROM deduplicated
)


SELECT

  *,
  -- Retain all original fields, source_month and ride_duration_seconds.

  ROUND(
    ride_duration_seconds / 60.0,
    2
  ) AS ride_duration_minutes,
  -- Convert duration from seconds to minutes.
  -- Dividing by 60.0 produces a decimal value.
  -- ROUND displays it to two decimal places.


  DATE(started_at) AS ride_date,
  -- Extract the calendar date on which the ride started.


  DATE_TRUNC(
    DATE(started_at),
    MONTH
  ) AS ride_month,
  -- Convert the start date to the first day of its month.
  -- For example, any ride starting in July 2025 receives 2025-07-01.
  -- This consistently assigns month-crossing rides to their start month.


  FORMAT_DATE(
    '%A',
    DATE(started_at)
  ) AS ride_day_name,
  -- Create the full weekday name, such as Monday or Saturday.


  EXTRACT(
    DAYOFWEEK FROM started_at
  ) AS ride_day_number,
  -- Create a numerical weekday value for sorting.
  -- BigQuery uses Sunday = 1 through Saturday = 7.


  EXTRACT(
    HOUR FROM started_at
  ) AS start_hour
  -- Extract the starting hour as a number from 0 through 23.
  -- This will support comparison of usage by time of day.


FROM durations_calculated
-- Use the deduplicated records with calculated durations.

WHERE ride_duration_seconds >= 60;
-- Remove rides lasting less than 60 seconds.
-- The daylight-saving adjustment occurs before this filter.
-- Missing station fields and rounded coordinates are retained.
