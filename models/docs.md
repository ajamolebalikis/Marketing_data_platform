{% docs fct_grain %}
**Grain:** one row per **platform x ad x day x country**. Facebook has no country split, so `country` is NULL for Facebook rows.
Primary key: `ad_performance_key`.
{% enddocs %}

{% docs metric_ctr %}
**CTR (click-through rate)** = `clicks / impressions`. NULL when impressions = 0. When aggregating, use `sum(clicks)/sum(impressions)`; never average this column.
{% enddocs %}

{% docs metric_cpc %}
**CPC (cost per click, EUR)** = `spend_eur / clicks`. NULL when clicks = 0. Aggregate as `sum(spend_eur)/sum(clicks)`.
{% enddocs %}

{% docs metric_cpm %}
**CPM (cost per 1,000 impressions, EUR)** = `spend_eur / impressions * 1000`. NULL when impressions = 0. Aggregate as `sum(spend_eur)*1000/sum(impressions)`.
{% enddocs %}

{% docs spend_eur_doc %}
Advertising spend converted to **EUR** (reporting currency). Always use this column to compare or add spend across platforms/accounts. `spend` is in the original account currency and must not be summed across currencies.
{% enddocs %}
