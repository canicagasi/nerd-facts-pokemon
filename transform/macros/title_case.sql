{% macro title_case(column) %}
    concat(upper(left({{ column }}, 1)), lower({{ column }}[2:]))
{% endmacro %}