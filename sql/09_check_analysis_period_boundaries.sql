-- PROCESS PHASE: CHECK THE EXACT 12-MONTH DATE BOUNDARY
--
-- Purpose:
-- Confirm how many rides started before, during or after the selected period.
--
-- Analysis period:
-- Start: 1 July 2025 at midnight, included.
-- End:   1 July 2026 at midnight, excluded.
--
-- A ride will eventually be assigned to a month using started_at,
-- regardless of which monthly source table contains it.
--
-- This query only counts records. It does not remove or change anything.

SELECT

  COUNT(*) AS total_raw_rows,
  -- Count every record across the 12 source tables.


  COUNTIF(
    started_at < TIMESTAMP('2025-07-01 00:00:00')
  ) AS rows_before_period,
  -- Count rides beginning before the selected period.
  -- These will be excluded from the cleaned analysis table.


  COUNTIF(
    started_at >= TIMESTAMP('2025-07-01 00:00:00')
    AND started_at < TIMESTAMP('2026-07-01 00:00:00')
  ) AS rows_inside_period,
  -- Count rides beginning within the selected 12-month period.
  --
  -- >= includes midnight at the beginning of 1 July 2025.
  -- < excludes midnight at the beginning of 1 July 2026.
  -- This includes every possible time on 30 June 2026.


  COUNTIF(
    started_at >= TIMESTAMP('2026-07-01 00:00:00')
  ) AS rows_after_period,
  -- Count rides beginning on or after 1 July 2026.
  -- These will be excluded from the cleaned analysis table.


  MIN(started_at) AS earliest_start,
  -- Show the earliest start time found in the raw source tables.


  MAX(started_at) AS latest_start
  -- Show the latest start time found in the raw source tables.


FROM `cyclistic-capstone-202601.cyclistic_capstone.trips_*`;
-- Read every monthly table beginning with trips_.
--
-- There is no GROUP BY because we want one summary row for the full dataset.
