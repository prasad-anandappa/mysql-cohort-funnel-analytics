-- views.sql
USE cohort_funnel;
CREATE OR REPLACE VIEW v_user_order_summary AS
SELECT u.user_id, u.signup_date, DATE_FORMAT(u.signup_date, '%Y-%m-01') AS cohort_month,
       COUNT(o.order_id) AS order_count, COALESCE(SUM(o.total_amount),0) AS lifetime_value,
       MIN(o.ordered_at) AS first_order_at, MAX(o.ordered_at) AS last_order_at
FROM users u LEFT JOIN orders o ON o.user_id = u.user_id AND o.status = 'COMPLETED'
GROUP BY u.user_id, u.signup_date;
CREATE OR REPLACE VIEW v_monthly_revenue AS
SELECT DATE_FORMAT(ordered_at, '%Y-%m-01') AS month, COUNT(*) AS orders, SUM(total_amount) AS revenue,
       COUNT(DISTINCT user_id) AS buyers
FROM orders WHERE status = 'COMPLETED' GROUP BY month;
