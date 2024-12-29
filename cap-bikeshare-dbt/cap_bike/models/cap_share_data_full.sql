{{ config(materialized='table') }}

with u as (
    select * from {{ ref('old_format_bikeshare_data') }}
    union all
    select * from {{ ref('new_format_bikeshare_data') }}
)

select
    GENERATE_UUID() AS uuid
    , ride_id
    , bike_number
    , year
    , month
    , lower(member_type) as member_type
    , rideable_type
    , case when rideable_type IN ('electric_bike', 'electric_scooter') then 1 else 0 end as e_flag
    , case when rideable_type IN ('electric_bike', 'electric_scooter') then 'electric' 
            when rideable_type IN ('classic_bike', 'docked_bike') then 'classic'
            else null end as rideable_type_binary
    , start_date
    , end_date
    , timestamp_diff(end_date, start_date, MINUTE) as duration
    , start_station_id
    , start_station_name
    , end_station_id
    , end_station_name
    , start_lat
    , start_lng
    , end_lat
    , end_lng
    , file
    , format
from u

/*
SELECT distinct(rideable_type || " " || e_flag) FROM `cap-bikeshare-441121.dbt_bikeshare_data.cap_share_data_full` 

SELECT count(uuid) FROM `cap-bikeshare-441121.dbt_bikeshare_data.cap_share_data_full` 
44,128,471

SELECT count(distinct(uuid)) FROM `cap-bikeshare-441121.dbt_bikeshare_data.cap_share_data_full` 
44,128,471
*/