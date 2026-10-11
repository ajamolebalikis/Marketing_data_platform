{#- Cleanup for CI: drops every schema of this pull request (pr_<n>, pr_<n>_staging, ...).
    Usage (CI only):  dbt run-operation drop_ci_schemas --target ci -#}
{% macro drop_ci_schemas() %}
    {% if target.name != 'ci' %}
        {{ exceptions.raise_compiler_error("drop_ci_schemas may only run with --target ci") }}
    {% endif %}
    {% set rows = run_query("show schemas in " ~ target.database) %}
    {% for row in rows %}
        {% set schema_name = row[0] %}
        {% if schema_name == target.schema or schema_name.startswith(target.schema ~ '_') %}
            {% do log("Dropping " ~ target.database ~ "." ~ schema_name, info=true) %}
            {% do run_query("drop schema if exists " ~ target.database ~ "." ~ schema_name ~ " cascade") %}
        {% endif %}
    {% endfor %}
{% endmacro %}
