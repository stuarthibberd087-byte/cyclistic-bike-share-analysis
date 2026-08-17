-- PROCESS PHASE: CALCULATE DST-ADJUSTED RIDE DURATIONS
-- Purpose:
-- Calculate the likely elapsed duration of each of the 29 rides affected
-- by the repeated 1 a.m. hour on 2 November 2025.
--
-- This query does not alter the original timestamps or source table.

SELECT

  ride_id,
  -- Identify the affected ride.

  member_casual,
  -- Show whether the rider was a member or casual rider.

  rideable_type,
  -- Show the bicycle type.

  started_at,
  ended_at,
  -- Retain the original recorded timestamps for transparency.

  TIMESTAMP_DIFF(
    ended_at,
    started_at,
    SECOND
  ) AS recorded_duration_seconds,
  -- Calculate the unadjusted difference.
  -- This is negative because the local clock repeated the 1 a.m. hour.

  TIMESTAMP_DIFF(
    ended_at,
    started_at,
    SECOND
  ) + 3600 AS adjusted_duration_seconds,
  -- Add the missing 3,600-second daylight-saving hour.

  ROUND(
    (
      TIMESTAMP_DIFF(ended_at, started_at, SECOND) + 3600
    ) / 60.0,
    2
  ) AS adjusted_duration_minutes
  -- Convert the adjusted duration from seconds to minutes.
  -- Dividing by 60.0 produces a decimal result.
  -- ROUND(..., 2) displays the result to two decimal places.

FROM `cyclistic-capstone-202601.cyclistic_capstone.trips_202511`
-- Only November contains these affected records.

WHERE ended_at <= started_at
-- Select the 29 records with negative or zero recorded durations.

ORDER BY adjusted_duration_seconds;
-- Display the shortest adjusted ride first.
