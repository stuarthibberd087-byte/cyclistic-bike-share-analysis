# Cyclistic bike-share analysis

Google Data Analytics Professional Certificate capstone, Stuart Hibberd.

**The question:** how do annual members and casual riders use Cyclistic bikes differently? Cyclistic is a fictional Chicago bike-share company; the underlying data is real Divvy trip data, used under the [Divvy Data License Agreement](https://divvybikes.com/data-license-agreement). The goal was to give the marketing team evidence to help plan a campaign aimed at converting casual riders into annual members.

**Dashboards:** [public.tableau.com/app/profile/stuart.hibberd/viz/Cyclistic_rider_usage_analysis](https://public.tableau.com/app/profile/stuart.hibberd/viz/Cyclistic_rider_usage_analysis)

## What I found

- Members took 64.71% of the 5,769,995 rides in the year; casual riders took 35.29%.
- Casual rides run about a third longer (median 11.63 minutes against 8.75), concentrate at weekends (37.4% of casual riding against 23.3% for members) and peak from midday into the afternoon, while member rides peak at 8 am and 5 pm on weekdays.
- Both groups are seasonal, but casual volume swings 13.5x between August and January against 4.0x for members, so the customer mix changes through the year.
- Casual ride starts cluster along the lakefront and at visitor attractions. The data has no rider identifier, so tourists cannot be told apart from local riders, and I treated that as a limit on what station volume can say about conversion potential.

## Recommendations

Test conversion by station type, test the shoulder season against the summer peak, and test messaging built around observed casual-rider behaviour. Each recommendation is framed as a test because the trip data cannot show what actually causes membership conversion.

## Method in brief

Twelve monthly Divvy files, July 2025 to June 2026, were imported into BigQuery as separate tables and left unchanged. Validation and cleaning are documented in the numbered SQL: 5,932,349 raw records became 5,769,995 cleaned rides after removing 162,217 rides under 60 seconds (Divvy treats these as potential false starts), 35 duplicate ride IDs and 102 rides outside the analysis period, and adjusting 29 daylight-saving records. Analysis ran against the cleaned table; results were exported as CSV extracts and visualised in Tableau Public.

## Repository contents

| Path | Contents |
| --- | --- |
| `cyclistic_case_study.docx` | The full case study: task, data, cleaning, analysis, conclusions, recommendations, limitations |
| `cyclistic_capstone_presentation.pdf` | Stakeholder presentation summarising the findings, recommendations and limitations |
| `sql/` | The complete numbered query sequence, 01 to 23, in execution order: import validation (01-04), data-quality checks (05-11b), cleaning (12-13), analysis (14-21), map data (22) and a station-name integrity check (23) |
| `data_dictionary.md` | Columns of the source files and of the cleaned table |

## Limitations

The records describe rides, not riders: there is no rider identifier, so repeat use and audience size cannot be measured. Trip purpose, demographics and residence are not recorded. Location analysis covers only rides with a recorded station ID. The station name field contains inconsistent spellings and, in a small number of cases, distinct locations sharing a station ID; the analysis is unaffected because rides are grouped by station ID throughout.

## About me

I came to data analysis from aviation. I worked on avionics in the military and then in civil aviation, and later studied Earth science, sustainability and renewable energy with the Open University. Fault finding on aircraft and reading environmental data both depend on working from the evidence and being careful about what it does and does not support. That is what drew me to this.

This project is my capstone for the Google Data Analytics Professional Certificate. I am looking for junior data analyst roles.

LinkedIn: [stuart-hibberd-bsc-hons-open](https://www.linkedin.com/in/stuart-hibberd-bsc-hons-open-3768568)
