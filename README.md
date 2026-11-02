# mysql-cohort-funnel-analytics

I built this MySQL 8 analytics project to practise the SQL I reach for in product analytics: **cohort retention, funnel conversion, and RFM segmentation** — written with CTEs and window functions, not application-side loops.

## What the schema models

- `users` — signup date, acquisition channel, country (the cohort dimension)
- `products`, `orders`, and `order_items` — completed / refunded / cancelled orders
- `events` — session-level funnel events: `VIEW`, `ADD_TO_CART`, `CHECKOUT_START`, `PURCHASE`, `SIGNUP`

The seed data is deliberately cohort-shaped: three signup months, repeat buyers, a refund, and multi-step sessions, so every query below returns a meaningful, checkable result.

## The analytics pack (`queries.sql`)

1. **Cohort retention** — for each signup-month cohort, active buyers and retention % in month 0, 1, 2, … using three CTEs (cohorts, activity, cohort sizes) and `TIMESTAMPDIFF`.
2. **Funnel conversion** — per-session step flags collapsed with conditional aggregation; view→purchase conversion in one pass over `events`.
3. **RFM segmentation** — recency / frequency / monetary per user, scored with `NTILE(5)` window functions and bucketed into Champions, Loyal, New / Promising, At Risk, and Needs Attention.
4. **Plus** — revenue by channel with a running-total window, product revenue ranking with `RANK()`, repeat-purchase rate, and days-to-second-order using `ROW_NUMBER()`.

Supporting views (`v_user_order_summary`, `v_monthly_revenue`) and a `cohort_retention_for(month)` procedure round it out.

## How to load it into MySQL 8

```bash
mysql -u root -p < schema.sql
mysql -u root -p cohort_funnel < seed.sql
mysql -u root -p cohort_funnel < views.sql
mysql -u root -p cohort_funnel < procedures.sql
mysql -u root -p cohort_funnel < queries.sql
```

## Validation

I validated these files on a machine with **no MySQL/MariaDB server and no Docker**, so I did **not** execute them against a live server and I am not claiming I did. Instead I ran a documented structural lint pass (Python, standard library only) over every `.sql` file in this repo: balanced parentheses and quotes after stripping strings/comments, statement termination, well-formed `DELIMITER` blocks, and a cross-file check that every table/view/procedure referenced is defined in this repo. All files passed that lint. Execution against MySQL 8 remains the reader's final check.

## License

MIT — see `LICENSE`. I am a Software Engineer; this is a personal portfolio project.
