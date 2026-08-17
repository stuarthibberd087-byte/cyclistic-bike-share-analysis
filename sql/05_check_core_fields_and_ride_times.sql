-- PROCESS PHASE: CORE DATA-QUALITY CHECK
-- Purpose:
-- Check whether the fields needed for the member-versus-casual comparison
-- contain missing values or impossible ride times.
--
-- This query only reads and counts records.
-- It does not change, clean or delete any data.

SELECT

  COUNT(*) AS total_rows,
  -- COUNT(*) counts every row found across all 12 monthly tables.
  -- This provides the raw total against which the error counts can be compared.


  COUNTIF(
    ride_id IS NULL
    OR TRIM(ride_id) = ''
  ) AS missing_ride_id,
  -- COUNTIF counts rows where the condition inside the brackets is TRUE.
  -- IS NULL checks whether no ride_id value was recorded.
  -- TRIM removes spaces from the beginning and end of a text value.
  -- Two quotation marks, '', represent an empty text value.
  -- OR means either condition is enough for the row to be counted.
  -- This therefore detects NULLs, empty values and values containing only spaces.


  COUNTIF(
    started_at IS NULL
  ) AS missing_started_at,
  -- Count rows where no ride start time was recorded.
  -- A valid start time is needed to calculate duration, month, weekday and hour.


  COUNTIF(
    ended_at IS NULL
  ) AS missing_ended_at,
  -- Count rows where no ride end time was recorded.
  -- Both started_at and ended_at are required to calculate ride duration.


  COUNTIF(
    member_casual IS NULL
    OR TRIM(member_casual) = ''
  ) AS missing_rider_type,
  -- Count rows where rider type is NULL, empty or contains only spaces.
  -- This is a critical field because the analysis compares members with casual riders.


  COUNTIF(
    rideable_type IS NULL
    OR TRIM(rideable_type) = ''
  ) AS missing_bike_type,
  -- Count rows where bicycle type is NULL, empty or contains only spaces.
  -- This field is needed to compare bicycle use between rider groups.


  COUNTIF(
    ended_at <= started_at
  ) AS non_positive_duration
  -- Count rides where the end time is equal to or earlier than the start time.
  -- These records would produce a duration of zero or a negative duration.
  -- If either timestamp is NULL, this comparison is not TRUE, so that row is
  -- instead captured by the separate missing-time checks above.


FROM `cyclistic-capstone-202601.cyclistic_capstone.trips_*`;
-- FROM identifies the source data.
-- trips_* is a wildcard table reference.
-- It reads every table in the dataset whose name begins with trips_.
-- In this project, that covers trips_202507 through trips_202606.
--
-- There is no GROUP BY because we want one summary row for the entire dataset.
