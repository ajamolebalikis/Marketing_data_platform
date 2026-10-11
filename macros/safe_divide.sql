{#- Division that returns NULL (not an error, not 0) when the denominator is 0 or NULL.
    NULL is correct: a CTR for a day with 0 impressions is "undefined", not "0%". -#}
{% macro safe_divide(numerator, denominator) -%}
    case
        when ({{ denominator }}) is null or ({{ denominator }}) = 0 then null
        else cast(({{ numerator }}) as double) / cast(({{ denominator }}) as double)
    end
{%- endmacro %}
