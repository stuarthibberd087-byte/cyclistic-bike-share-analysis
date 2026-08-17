-- PROCESS PHASE: EXAMINE RIDES UNDER 60 SECONDS BY CATEGORY
--
-- Purpose:
-- Determine whether very short rides are evenly distributed across
-- rider and bicycle categories before deciding how to clean them.
--
-- This query does not remove any records.

WITH rides_with_duration AS (

  SELECT

    member_casual,
    -- Retain the rider category for comparison.

    rideable_type,
    -- Retain the bicycle category for comparison.

    CASE

      WHEN DATE(started_at) = DATE '2025-11-02'
        AND ended_at <= started_at
      THEN TIMESTAMP_DIFF(ended_at, started_at, SECOND) + 3600
      -- Apply the daylight-saving correction to the 29 affected rides.

      ELSE TIMESTAMP_DIFF(ended_at, started_at, SECOND)
      -- Use the recorded duration for every other ride.

    END AS duration_seconds
    -- Store the calculated duration for this temporary query.

  FROM `cyclistic-capstone-202601.cyclistic_capstone.trips_*`
  -- Read all 12 source tables.

  WHERE started_at >= TIMESTAMP('2025-07-01 00:00:00')
    AND started_at < TIMESTAMP('2026-07-01 00:00:00')
  -- Keep only rides starting inside the selected analysis period.
)

SELECT

  member_casual,
  rideable_type,
  -- Produce results for each rider-type and bicycle-type combination.

  COUNT(*) AS total_rows,
  -- Count all rides in the category combination.

  COUNTIF(duration_seconds < 60) AS rides_under_60_seconds,
  -- Count rides lasting less than one minute.

  ROUND(
    100 * COUNTIF(duration_seconds < 60) / COUNT(*),
    2
  ) AS percentage_under_60_seconds
  -- Divide short rides by all rides in the category.
  -- Multiply by 100 to produce a percentage.
  -- ROUND(..., 2) displays two decimal places.

FROM rides_with_duration
-- Use the temporary duration results created above.

GROUP BY
  member_casual,
  rideable_type
-- Produce one row for each category combination.

ORDER BY
  member_casual,
  rideable_type;
-- Arrange the output alphabetically.
