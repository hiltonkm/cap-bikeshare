{{ config(materialized='table') }}
{% set tables = ['2010_capitalbikeshare',	'2011_capitalbikeshare',	'2012Q1_capitalbikeshare',	'2012Q2_capitalbikeshare',	'2012Q3_capitalbikeshare',	'2012Q4_capitalbikeshare',	'2013Q1_capitalbikeshare',	'2013Q2_capitalbikeshare',	'2013Q3_capitalbikeshare',	'2013Q4_capitalbikeshare',	'2014Q1_capitalbikeshare',	'2014Q2_capitalbikeshare',	'2014Q3_capitalbikeshare',	'2014Q4_capitalbikeshare',	'2015Q1_capitalbikeshare',	'2015Q2_capitalbikeshare',	'2015Q3_capitalbikeshare',	'2015Q4_capitalbikeshare',	'2016Q1_capitalbikeshare',	'2016Q2_capitalbikeshare',	'2016Q3_capitalbikeshare',	'2016Q4_capitalbikeshare',	'2017Q1_capitalbikeshare',	'2017Q2_capitalbikeshare',	'2017Q3_capitalbikeshare',	'2017Q4_capitalbikeshare',	'201801_capitalbikeshare',	'201802_capitalbikeshare',	'201803_capitalbikeshare',	'201804_capitalbikeshare',	'201805_capitalbikeshare',	'201806_capitalbikeshare',	'201807_capitalbikeshare',	'201808_capitalbikeshare',	'201809_capitalbikeshare',	'201810_capitalbikeshare',	'201811_capitalbikeshare',	'201812_capitalbikeshare',	'201901_capitalbikeshare',	'201902_capitalbikeshare',	'201903_capitalbikeshare',	'201904_capitalbikeshare',	'201905_capitalbikeshare',	'201906_capitalbikeshare',	'201907_capitalbikeshare',	'201908_capitalbikeshare',	'201909_capitalbikeshare',	'201910_capitalbikeshare',	'201911_capitalbikeshare',	'201912_capitalbikeshare',	'202001_capitalbikeshare',	'202002_capitalbikeshare',	'202003_capitalbikeshare'] %}
{% set dataset = 'cap-bikeshare-441121.raw_bikeshare_data' %}

{% for table in tables %}

select
    "" as ride_id
    , `Bike number` as bike_number
    , extract(YEAR from parse_datetime('%F %T', `Start date`)) as year
    , extract(MONTH from parse_datetime('%F %T', `Start date`)) as month
    , `Member type` as member_type
    , "" as rideable_type
    , parse_datetime('%F %T', `Start date`) as `start_date`
    , parse_datetime('%F %T', `End date`) as `end_date`
    , `Start station number` as start_station_id
    , `Start station` as start_station_name
    , `End station number` as end_station_id
    , `End station` as end_station_name
    , null as start_lat
    , null as start_lng
    , null as end_lat
    , null as end_lng
    , file
    , 'old' as format
from `{{ dataset }}.{{ table}}`

{% if not loop.last -%} union all {%- endif %}

{% endfor %}
