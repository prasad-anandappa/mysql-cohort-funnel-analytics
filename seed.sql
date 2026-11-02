-- seed.sql : small but cohort-shaped (3 signup months, repeat buyers)
USE cohort_funnel;
INSERT INTO users (email, signup_date, acquisition_channel, country) VALUES
  ('u01@example.com','2026-08-03','organic','US'),
  ('u02@example.com','2026-08-10','ads','US'),
  ('u03@example.com','2026-08-18','organic','IN'),
  ('u04@example.com','2026-09-02','referral','US'),
  ('u05@example.com','2026-09-14','ads','GB'),
  ('u06@example.com','2026-09-21','organic','US'),
  ('u07@example.com','2026-10-05','ads','US'),
  ('u08@example.com','2026-10-12','organic','CA'),
  ('u09@example.com','2026-10-19','referral','US'),
  ('u10@example.com','2026-10-26','organic','US');
INSERT INTO products (name, category, price) VALUES
  ('Starter Kit','Kits',49.00),
  ('Pro Plan - Monthly','Subscription',29.00),
  ('Add-on Pack','Add-ons',15.00);
INSERT INTO orders (user_id, ordered_at, total_amount, status) VALUES
  (1,'2026-08-03 10:00:00',49.00,'COMPLETED'),
  (1,'2026-09-05 11:00:00',29.00,'COMPLETED'),
  (1,'2026-10-07 09:30:00',44.00,'COMPLETED'),
  (2,'2026-08-11 12:00:00',49.00,'COMPLETED'),
  (3,'2026-08-20 13:00:00',78.00,'COMPLETED'),
  (3,'2026-10-02 13:00:00',29.00,'COMPLETED'),
  (4,'2026-09-03 10:00:00',49.00,'COMPLETED'),
  (4,'2026-10-10 10:00:00',29.00,'COMPLETED'),
  (5,'2026-09-15 15:00:00',15.00,'COMPLETED'),
  (7,'2026-10-06 09:00:00',49.00,'COMPLETED'),
  (8,'2026-10-13 09:00:00',29.00,'REFUNDED'),
  (10,'2026-10-27 09:00:00',64.00,'COMPLETED');
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (1,1,1,49.00),(2,2,1,29.00),(3,2,1,29.00),(3,3,1,15.00),
  (4,1,1,49.00),(5,1,1,49.00),(5,2,1,29.00),(7,1,1,49.00);
INSERT INTO events (user_id, session_id, event_type, event_at) VALUES
  (1,'s-001','VIEW','2026-10-01 09:00:00'),
  (1,'s-001','ADD_TO_CART','2026-10-01 09:05:00'),
  (1,'s-001','CHECKOUT_START','2026-10-01 09:07:00'),
  (1,'s-001','PURCHASE','2026-10-01 09:09:00'),
  (2,'s-002','VIEW','2026-10-01 10:00:00'),
  (2,'s-002','ADD_TO_CART','2026-10-01 10:04:00'),
  (4,'s-003','VIEW','2026-10-02 11:00:00'),
  (NULL,'s-004','VIEW','2026-10-02 12:00:00'),
  (NULL,'s-004','SIGNUP','2026-10-02 12:02:00');
