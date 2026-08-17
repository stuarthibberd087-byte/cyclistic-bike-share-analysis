-- PROCESS PHASE: CHECK THE RANGE OF RIDE DURATIONS
--
-- Purpose:
-- Calculate corrected ride durations within the selected 12-month period
-- and count records at potentially unusual duration ranges.
--
-- This query only summarises the records. It does not remove anything.

WITH rides_with_duration AS (

  SELECT

    ride_id,
    -- Retain the ride ID so each row still represents one ride.

    CASE
      -- CASE applies different calculations under different conditions.

      WHEN DATE(started_at) = DATE '2025-11-02'
        AND ended_at <= started_at
      THEN TIMESTAMP_DIFF(ended_at, started_at, SECOND) + 3600
      -- For the 29 daylight-saving records, add the repeated hour.

      ELSE TIMESTAMP_DIFF(ended_at, started_at, SECOND)
      -- For every other ride, use the recorded timestamp difference.

    END AS duration_seconds
    -- Name the resulting cleaned duration duration_seconds.

  FROM `cyclistic-capstone-202601.cyclistic_capstone.trips_*`
  -- Read all monthly source tables.

  WHERE started_at >= TIMESTAMP('2025-07-01 00:00:00')
    AND started_at < TIMESTAMP('2026-07-01 00:00:00')
  -- Keep only rides starting within the exact analysis period.
)

SELECT

  COUNT(*) AS total_inside_period,
  -- Count all records included before duplicate removal.

  COUNTIF(duration_seconds < 60) AS rides_under_60_seconds,
  -- Count rides lasting less than one minute.
  -- This checks whether the publisher's stated removal rule is reflected.

  COUNTIF(
    duration_seconds BETWEEN 60 AND 86399
  ) AS rides_from_1_minute_to_under_24_hours,
  -- Count rides lasting at least one minute but less than 24 hours.
  -- There are 86,400 seconds in 24 hours.

  COUNTIF(duration_seconds >= 86400) AS rides_24_hours_or_more,
  -- Count unusually long rides for further inspection.
  -- This does not yet mean they should be removed.

  MIN(duration_seconds) AS shortest_duration_seconds,
  -- Show the shortest adjusted duration.

  MAX(duration_seconds) AS longest_duration_seconds
  -- Show the longest adjusted duration.

FROM rides_with_duration;
-- Summarise the temporary duration results into one output row.
