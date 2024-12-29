{{ config(materialized='table') }}

select
    count(uuid) as c
    , date(year, month, 1) as mo_yr
    , month
    , year
    , member_type
    , rideable_type_binary
    , start_station_id
    , start_station_name
    , end_station_id
    , end_station_name
    , file
    , format
from {{ ref('cap_share_data_full') }}
group by month, year, member_type, rideable_type_binary, start_station_id, start_station_name, end_station_id, end_station_name, file, format