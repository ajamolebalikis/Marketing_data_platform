-- Fails if any report_date is in the future (bad date parsing / timezone shifts).
select * from {{ ref('fct_marketing_spend') }} where report_date > current_date()
