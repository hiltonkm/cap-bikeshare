{% set tables = ['table1', 'table2', 'table3'] %}

{% set possible_columns = ['col1', 'col2', 'col3'] %}

{% for table in tables %}
  {%- set table_columns = adapter.get_columns_in_relation( ref(table) ) -%}
  select
    {% for pc in possible_columns %}

      {% if not loop.last -%}

        {% if pc in table_columns %}
          {{ pc }},
        {% else %}
          null as {{ pc }},
        {%- endif %}

      {% else %}
        {% if pc in table_columns %}
          {{ pc }}
        {% else %}
          null as {{ pc }}
        {%- endif %}

      {% endif %}

    {%- endfor %}

  from
    {{ ref(table) }}

  {% if not loop.last -%}
    union all
  {%- endif %}
{% endfor %}