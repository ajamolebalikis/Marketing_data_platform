{#-
  Environment-aware schema naming.
  prod : custom schema used as-is            -> analytics_production.staging / intermediate / marts / elementary
  dev  : <target.schema>_<custom>            -> analytics_development.dbt_alice_marts
  ci   : <target.schema>_<custom>            -> ci_development.pr_42_marts   (dropped after the PR check)
  This is how one codebase safely lands in three isolated places.
-#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- elif target.name == 'prod' -%}
        {{ custom_schema_name | trim }}
    {%- else -%}
        {{ target.schema }}_{{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
