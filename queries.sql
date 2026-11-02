-- queries.sql : cohort retention, funnel conversion, RFM - window functions + CTEs
USE cohort_funnel;
-- 1. COHORT RETENTION: % of each signup cohort ordering in each following month
WITH cohorts AS (
  SELECT user_id, DATE_FORMAT(signup_date, '%Y-%m-01') AS cohort_month FROM users
),
activity AS (
  SELECT DISTINCT o.user_id, DATE_FORMAT(o.ordered_at, '%Y-%m-01') AS activity_month
  FROM orders o WHERE o.status = 'COMPLETED'
),
sizes AS (
  SELECT cohort_month, COUNT(*) AS cohort_size FROM cohorts GROUP BY cohort_month
)
SELECT c.cohort_month,
       TIMESTAMPDIFF(MONTH, STR_TO_DATE(c.cohort_month, '%Y-%m-%d'), STR_TO_DATE(a.activity_month, '%Y-%m-%d')) AS month_index,
       COUNT(DISTINCT a.user_id) AS active_users,
       s.cohort_size,
       ROUND(COUNT(DISTINCT a.user_id) / s.cohort_size * 100, 1) AS retention_pct
FROM cohorts c
JOIN activity a ON a.user_id = c.user_id
JOIN sizes s ON s.cohort_month = c.cohort_month
GROUP BY c.cohort_month, month_index, s.cohort_size
ORDER BY c.cohort_month, month_index;
-- 2. FUNNEL CONVERSION by session step
WITH funnel AS (
  SELECT session_id,
         MAX(event_type = 'VIEW') AS did_view,
         MAX(event_type = 'ADD_TO_CART') AS did_cart,
         MAX(event_type = 'CHECKOUT_START') AS did_checkout,
         MAX(event_type = 'PURCHASE') AS did_purchase
  FROM events GROUP BY session_id
)
SELECT COUNT(*) AS sessions, SUM(did_view) AS viewed, SUM(did_cart) AS added_to_cart,
       SUM(did_checkout) AS started_checkout, SUM(did_purchase) AS purchased,
       ROUND(SUM(did_purchase) / NULLIF(SUM(did_view),0) * 100, 1) AS view_to_purchase_pct
FROM funnel;
-- 3. RFM SEGMENTATION with NTILE scoring
WITH rfm AS (
  SELECT u.user_id,
         DATEDIFF(CURRENT_DATE, MAX(o.ordered_at)) AS recency_days,
         COUNT(o.order_id) AS frequency,
         COALESCE(SUM(o.total_amount),0) AS monetary
  FROM users u JOIN orders o ON o.user_id = u.user_id AND o.status = 'COMPLETED'
  GROUP BY u.user_id
),
scored AS (
  SELECT user_id, recency_days, frequency, monetary,
         NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
         NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
         NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
  FROM rfm
)
SELECT user_id, recency_days, frequency, monetary, r_score, f_score, m_score,
       CASE WHEN r_score >= 4 AND f_score >= 4 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal'
            WHEN r_score >= 4 AND f_score <= 2 THEN 'New / Promising'
            WHEN r_score <= 2 THEN 'At Risk'
            ELSE 'Needs Attention' END AS segment
FROM scored ORDER BY monetary DESC;
-- 4. Revenue by acquisition channel with running total (window function)
SELECT acquisition_channel, month, revenue,
       SUM(revenue) OVER (PARTITION BY acquisition_channel ORDER BY month) AS running_revenue
FROM (
  SELECT u.acquisition_channel, DATE_FORMAT(o.ordered_at, '%Y-%m-01') AS month, SUM(o.total_amount) AS revenue
  FROM orders o JOIN users u ON u.user_id = o.user_id WHERE o.status = 'COMPLETED'
  GROUP BY u.acquisition_channel, month
) monthly ORDER BY acquisition_channel, month;
-- 5. Top products by revenue and units
SELECT p.name, p.category, SUM(oi.quantity) AS units, SUM(oi.quantity * oi.unit_price) AS revenue,
       RANK() OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS revenue_rank
FROM order_items oi JOIN products p ON p.product_id = oi.product_id
GROUP BY p.name, p.category ORDER BY revenue DESC;
-- 6. Repeat purchase rate
SELECT COUNT(DISTINCT CASE WHEN order_count >= 2 THEN user_id END) AS repeat_buyers,
       COUNT(DISTINCT user_id) AS buyers,
       ROUND(COUNT(DISTINCT CASE WHEN order_count >= 2 THEN user_id END) / COUNT(DISTINCT user_id) * 100, 1) AS repeat_rate_pct
FROM (SELECT user_id, COUNT(*) AS order_count FROM orders WHERE status = 'COMPLETED' GROUP BY user_id) per_user;
-- 7. Days between first and second order (retention behaviour)
WITH ranked AS (
  SELECT user_id, ordered_at,
         ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY ordered_at) AS rn
  FROM orders WHERE status = 'COMPLETED'
)
SELECT a.user_id, DATEDIFF(b.ordered_at, a.ordered_at) AS days_to_second_order
FROM ranked a JOIN ranked b ON b.user_id = a.user_id AND b.rn = 2 WHERE a.rn = 1 ORDER BY days_to_second_order;
