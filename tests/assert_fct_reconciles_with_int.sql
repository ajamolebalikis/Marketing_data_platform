-- Fails if the incremental fact lost or duplicated spend/impressions/clicks versus the unified view.
with fct as (
    select sum(spend_eur) s, sum(impressions) i, sum(clicks) c from {{ ref('fct_marketing_spend') }}
),
src as (
    select sum(spend_eur) s, sum(impressions) i, sum(clicks) c from {{ ref('int_marketing_ads') }}
)
select fct.s, src.s, fct.i, src.i, fct.c, src.c
from fct cross join src
where abs(fct.s - src.s) > 0.01 or fct.i <> src.i or fct.c <> src.c
