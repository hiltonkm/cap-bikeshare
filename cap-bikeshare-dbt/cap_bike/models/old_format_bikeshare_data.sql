{% set tables = ['table1', 'table2', 'table3'] %}
select `Bike number` as id
    , null as ride_id
    , `Bike number` as bike_number
    , extract(YEAR from parse_datetime('%F %T', `Start date`)) as year
    , extract(MONTH from parse_datetime('%F %T', `Start date`)) as month
    , `Member type` as member_type
    , null as rideable_type
    , format_datetime("%c", parse_datetime('%F %T', `Start date`)) as `start_date`
    , format_datetime("%c", parse_datetime('%F %T', `End date`)) as `end_date`
    , Duration as duration
    , `Start station number` as start_station_id
    , `Start station` as start_station_name
    , `End station number` as end_station_id
    , `End station` as end_station
    , null as start_lat
    , null as start_lng
    , null as end_lat
    , null as end_lng
    , file
from `cap-bikeshare-441121.raw_bikeshare_data.2010_capitalbikeshare`

