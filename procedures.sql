-- procedures.sql : refresh helpers for the analytics pack
USE cohort_funnel;
DELIMITER $$
CREATE PROCEDURE cohort_retention_for(IN p_cohort_month DATE)
BEGIN
  SELECT DATE_FORMAT(o.ordered_at, '%Y-%m') AS activity_month, COUNT(DISTINCT o.user_id) AS active_users
  FROM orders o JOIN users u ON u.user_id = o.user_id
  WHERE o.status = 'COMPLETED' AND DATE_FORMAT(u.signup_date, '%Y-%m-01') = DATE_FORMAT(p_cohort_month, '%Y-%m-01')
  GROUP BY activity_month ORDER BY activity_month;
END$$
DELIMITER ;
