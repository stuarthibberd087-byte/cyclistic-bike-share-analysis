-- PROCESS PHASE: VERIFY THE CLEANED TABLE
--
-- Purpose:
-- Confirm that the cleaned table has the expected row count,
-- unique ride IDs, correct date boundaries and valid calculated durations.
--
-- This query only checks the cleaned table. It changes nothing.

SELECT

  COUNT(*) AS total_clean_rows,
  -- Count all records remaining after cleaning.
  -- Expected result: 5,769,995.


  COUNT(DISTINCT ride_id) AS unique_ride_ids,
  -- Count different ride IDs.
  -- This should equal total_clean_rows.


  COUNT(*) - COUNT(DISTINCT ride_id) AS duplicate_rows,
  -- Calculate the number of excess duplicate copies.
  -- Expected result: 0.


  COUNTIF(
    ride_id IS NULL
    OR TRIM(ride_id) = ''
    OR started_at IS NULL
    OR ended_at IS NULL
    OR member_casual IS NULL
    OR TRIM(member_casual) = ''
    OR rideable_type IS NULL
    OR TRIM(rideable_type) = ''
  ) AS rows_missing_core_fields,
  -- Count rows missing any field required for the core comparison.
  -- Expected result: 0.


  COUNTIF(
    started_at < TIMESTAMP('2025-07-01 00:00:00')
    OR started_at >= TIMESTAMP('2026-07-01 00:00:00')
  ) AS rows_outside_period,
  -- Confirm that every ride starts inside the exact analysis period.
  -- Expected result: 0.


  COUNTIF(
    ride_duration_seconds < 60
  ) AS rides_under_60_seconds,
  -- Confirm that no rides under one minute remain.
  -- Expected result: 0.


  COUNTIF(
    ended_at <= started_at
  ) AS raw_timestamp_reversals_retained,
  -- Count the 29 daylight-saving records whose original timestamps
  -- still appear reversed.
  -- These raw timestamps were intentionally preserved.
  -- Expected result: 29.


  COUNTIF(
    ended_at <= started_at
    AND ride_duration_seconds >= 60
  ) AS dst_adjusted_rides_retained,
  -- Confirm that the reversed timestamp records have positive,
  -- usable calculated durations after the one-hour adjustment.
  -- Expected result: 29.


  MIN(ride_duration_seconds) AS shortest_clean_duration_seconds,
  -- Show the shortest retained duration.
  -- Expected result: at least 60.


  MAX(ride_duration_seconds) AS longest_clean_duration_seconds,
  -- Show the longest retained duration.
  -- Long rides were intentionally retained.


  COUNTIF(
    ride_date IS NULL
    OR ride_month IS NULL
    OR ride_day_name IS NULL
    OR ride_day_number IS NULL
    OR start_hour IS NULL
  ) AS rows_missing_derived_time_fields
  -- Confirm that all newly created analysis fields are populated.
  -- Expected result: 0.

FROM `cyclistic-capstone-202601.cyclistic_capstone.rides_clean`;
-- Read only the new cleaned table.
