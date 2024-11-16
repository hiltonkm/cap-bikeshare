select table_name
  , case when row_number() over (order by table_name) < 54 then "old_format" else "new_format" end as file_format
from`cap-bikeshare-441121.raw_bikeshare_data.INFORMATION_SCHEMA.TABLES`
order by table_name