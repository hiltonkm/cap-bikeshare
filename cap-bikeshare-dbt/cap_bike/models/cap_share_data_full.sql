{{ config(materialized='table') }}

with u as (
    select * from {{ ref('old_format_bikeshare_data') }}
    union all
    select * from {{ ref('new_format_bikeshare_data') }}
)

select *
    , timestamp_diff(end_date, start_date, MINUTE) as duration
from u