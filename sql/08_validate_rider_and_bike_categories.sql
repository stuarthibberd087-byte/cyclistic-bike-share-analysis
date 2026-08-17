-- PROCESS PHASE: VALIDATE CATEGORICAL FIELDS
-- Purpose:
-- Check that rider type and bicycle type use consistent category labels.
-- This query only reads and summarises the data; it changes nothing.

SELECT

  member_casual,
  -- Display every rider-category value exactly as it appears in the data.
  -- Consistent results should normally show member and casual.

  rideable_type,
  -- Display every bicycle-category value exactly as recorded.

  COUNT(*) AS total_rows,
  -- Count how many records use each combination of rider and bicycle type.
  -- A category with very few records could indicate a typo or unusual value.

  COUNTIF(
    member_casual != TRIM(member_casual)
  ) AS rider_type_with_outer_spaces,
  -- != means "is not equal to."
  -- Compare the original value with the value after TRIM removes outside spaces.
  -- If they differ, the original category contains leading or trailing spaces.

  COUNTIF(
    rideable_type != TRIM(rideable_type)
  ) AS bike_type_with_outer_spaces
  -- Check bicycle categories for leading or trailing spaces in the same way.

FROM `cyclistic-capstone-202601.cyclistic_capstone.trips_*`
-- Read all 12 monthly tables.

GROUP BY
  member_casual,
  rideable_type
-- Produce one result row for every rider-type and bicycle-type combination.

ORDER BY
  member_casual,
  rideable_type;
-- Arrange the categories alphabetically so inconsistencies are easier to spot.
