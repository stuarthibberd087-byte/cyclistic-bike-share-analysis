-- PROCESS PHASE: INSPECT RIDES WITH INVALID DURATIONS
-- Purpose:
-- Display the 29 records that end at or before their recorded start time.
-- This query only reads the records; it does not remove them.

SELECT

  _TABLE_SUFFIX AS source_month,
  -- Show which monthly source table contains the record.

  ride_id,
  -- Display the ride's identifier.

  member_casual,
  -- Show whether the record belongs to a member or casual rider.

  rideable_type,
  -- Show the recorded bicycle type.

  started_at,
  -- Display the recorded start date and time.

  ended_at,
  -- Display the recorded end date and time.

  TIMESTAMP_DIFF(
    ended_at,
    started_at,
    SECOND
  ) AS duration_seconds
  -- TIMESTAMP_DIFF calculates the difference between two timestamps.
  -- BigQuery subtracts started_at from ended_at.
  -- SECOND tells BigQuery to return the result in seconds.
  -- Zero means the times are identical; a negative value means the ride
  -- appears to end before it starts.

FROM `cyclistic-capstone-202601.cyclistic_capstone.trips_*`
-- Read all 12 monthly source tables.

WHERE ended_at <= started_at
-- WHERE keeps only individual rows meeting this condition.
-- It differs from HAVING, which filters groups after aggregation.

ORDER BY duration_seconds, ride_id;
-- Show the most negative durations first, then arrange matching values by ride ID.
