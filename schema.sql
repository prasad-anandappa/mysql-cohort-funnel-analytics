-- mysql-cohort-funnel-analytics : schema.sql
CREATE DATABASE IF NOT EXISTS cohort_funnel CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE cohort_funnel;
CREATE TABLE users (
  user_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  email VARCHAR(160) NOT NULL,
  signup_date DATE NOT NULL,
  acquisition_channel VARCHAR(40) NOT NULL DEFAULT 'organic',
  country VARCHAR(60) NULL,
  PRIMARY KEY (user_id),
  UNIQUE KEY uq_users_email (email),
  KEY idx_users_signup (signup_date)
) ENGINE=InnoDB;
CREATE TABLE products (
  product_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(140) NOT NULL,
  category VARCHAR(80) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (product_id)
) ENGINE=InnoDB;
CREATE TABLE orders (
  order_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  ordered_at DATETIME NOT NULL,
  total_amount DECIMAL(12,2) NOT NULL,
  status ENUM('COMPLETED','REFUNDED','CANCELLED') NOT NULL DEFAULT 'COMPLETED',
  PRIMARY KEY (order_id),
  KEY idx_orders_user_time (user_id, ordered_at),
  CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users (user_id)
) ENGINE=InnoDB;
CREATE TABLE order_items (
  item_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL,
  product_id INT UNSIGNED NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  unit_price DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (item_id),
  CONSTRAINT fk_items_order FOREIGN KEY (order_id) REFERENCES orders (order_id),
  CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products (product_id)
) ENGINE=InnoDB;
CREATE TABLE events (
  event_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NULL,
  session_id VARCHAR(64) NOT NULL,
  event_type ENUM('VIEW','ADD_TO_CART','CHECKOUT_START','PURCHASE','SIGNUP') NOT NULL,
  event_at DATETIME NOT NULL,
  PRIMARY KEY (event_id),
  KEY idx_events_session_time (session_id, event_at),
  KEY idx_events_type_time (event_type, event_at),
  CONSTRAINT fk_events_user FOREIGN KEY (user_id) REFERENCES users (user_id)
) ENGINE=InnoDB;
