# Data dictionary

## Source files

Twelve monthly CSV files from the [Divvy trip data archive](https://divvy-tripdata.s3.amazonaws.com/index.html), July 2025 to June 2026. One row per ride, 13 columns.

| Column | Type | Description |
| --- | --- | --- |
| ride_id | text | Unique identifier for a ride |
| rideable_type | category | Bicycle type: `classic_bike` or `electric_bike` |
| started_at | timestamp | When the ride began |
| ended_at | timestamp | When the ride ended |
| start_station_name | text | Start station name; blank for some electric-bike rides starting outside the station network |
| start_station_id | text | Start station identifier; used as the grouping key where station names vary |
| end_station_name | text | End station name; may be blank |
| end_station_id | text | End station identifier; may be blank |
| start_lat, start_lng | number | Start coordinates, decimal degrees. Rounded to a roughly one-kilometre grid when no start station is recorded |
| end_lat, end_lng | number | End coordinates; may be blank |
| member_casual | category | Rider type: `member` or `casual` |

There is no duration column (calculated from the timestamps) and no rider identifier (records describe rides, not riders).

## Cleaned table: `rides_clean`

Built by `sql/12_create_rides_clean_table.sql`. 5,769,995 rows, one per ride, July 2025 to June 2026 by ride start time. All source columns are retained, plus:

| Column | Type | Description |
| --- | --- | --- |
| source_month | text | The monthly file the ride came from |
| ride_duration_seconds | integer | Ride duration, corrected for the repeated daylight-saving hour on 2 November 2025 |
| ride_duration_minutes | number | Duration in minutes |
| ride_date | date | Calendar date of the ride start |
| ride_month | date | First day of the ride's month |
| ride_day_name | text | Day of week of the ride start |
| ride_day_number | integer | Day of week as a number, 1 = Sunday |
| start_hour | integer | Hour of the ride start, 0 to 23 |

Rows removed during cleaning: rides under 60 seconds (162,217), excess duplicate ride IDs (35), rides starting before 1 July 2025 (102). Rides of 24 hours or longer were retained.
