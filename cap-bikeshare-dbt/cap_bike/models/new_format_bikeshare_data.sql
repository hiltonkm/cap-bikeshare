{{ config(materialized='table') }}
{% set tables = ['202004_capitalbikeshare',	'202005_capitalbikeshare',	'202006_capitalbikeshare',	'202007_capitalbikeshare',	'202008_capitalbikeshare',	'202009_capitalbikeshare',	'202010_capitalbikeshare',	'202011_capitalbikeshare',	'202012_capitalbikeshare',	'202101_capitalbikeshare',	'202102_capitalbikeshare',	'202103_capitalbikeshare',	'202104_capitalbikeshare',	'202105_capitalbikeshare',	'202106_capitalbikeshare',	'202107_capitalbikeshare',	'202108_capitalbikeshare',	'202109_capitalbikeshare',	'202110_capitalbikeshare',	'202111_capitalbikeshare',	'202112_capitalbikeshare',	'202201_capitalbikeshare',	'202202_capitalbikeshare',	'202203_capitalbikeshare',	'202204_capitalbikeshare',	'202205_capitalbikeshare',	'202206_capitalbikeshare',	'202207_capitalbikeshare',	'202208_capitalbikeshare',	'202209_capitalbikeshare',	'202210_capitalbikeshare',	'202211_capitalbikeshare',	'202212_capitalbikeshare',	'202301_capitalbikeshare',	'202302_captialbikeshare',	'202303_capitalbikeshare',	'202304_capitalbikeshare',	'202305_capitalbikeshare',	'202306_capitalbikeshare',	'202307_capitalbikeshare',	'202308_capitalbikeshare',	'202309_capitalbikeshare',	'202310_capitalbikeshare',	'202311_capitalbikeshare',	'202312_capitalbikeshare',	'202401_capitalbikeshare',	'202402_capitalbikeshare',	'202403_capitalbikeshare',	'202405_capitalbikeshare',	'202406_capitalbikeshare',	'202407_capitalbikeshare',	'202408_capitalbikeshare',	'202409_capitalbikeshare',	'202410_capitalbikeshare'] %}
{% set dataset = 'cap-bikeshare-441121.raw_bikeshare_data' %}

{% for table in tables %}

select ride_id as id
    , ride_id
    , "" as bike_number
    , extract(YEAR from 
        case when REGEXP_CONTAINS(started_at, "\\.") then 
                parse_datetime('%F %H:%M:%E*S', started_at)
                else parse_datetime('%F %T', started_at) end) 
            as year
    , extract(MONTH from 
        case when REGEXP_CONTAINS(started_at, "\\.") then 
            parse_datetime('%F %H:%M:%E*S', started_at)
            else parse_datetime('%F %T', started_at) end)
        as month
    , member_casual as member_type
    , rideable_type
    , case when REGEXP_CONTAINS(started_at, "\\.") then 
        parse_datetime('%F %H:%M:%E*S', started_at)
        else parse_datetime('%F %T', started_at) end
        as start_date
    , case when REGEXP_CONTAINS(started_at, "\\.") then 
        parse_datetime('%F %H:%M:%E*S', ended_at)
        else parse_datetime('%F %T', ended_at) end
        as end_date
    , start_station_id
    , start_station_name
    , end_station_id
    , end_station_name
    , cast(start_lat as NUMERIC) as start_lat
    , cast(start_lng as NUMERIC) as start_lng
    , cast(end_lat as NUMERIC) as end_lat
    , cast(end_lng as NUMERIC) as end_lng
    , file
from `{{ dataset }}.{{ table}}`

{% if not loop.last -%} union all {%- endif %}

{% endfor %}
