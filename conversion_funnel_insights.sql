CREATE DATABASE conversion_funnel_insights;
SHOW DATABASES;
-- Switched to project database
USE conversion_funnel_insights;
-- Confirmed current database
SELECT DATABASE();
-- Created table to store user activity
CREATE TABLE raw_events (
    user_id INT,
    event VARCHAR(50),
    timestamp DATETIME,
    device VARCHAR(50),
    location VARCHAR(50)
);
-- To see if table was created
SHOW TABLES;
-- Inserted sample user behavior data
INSERT INTO raw_events VALUES
(1, 'visit', '2025-03-01 10:00:00', 'mobile', 'India'),
(1, 'product_view', '2025-03-01 10:02:00', 'mobile', 'India'),
(1, 'add_to_cart', '2025-03-01 10:05:00', 'mobile', 'India'),

(2, 'visit', '2025-03-01 11:00:00', 'desktop', 'India'),
(2, 'product_view', '2025-03-01 11:03:00', 'desktop', 'India'),

(3, 'visit', '2025-03-01 12:00:00', 'mobile', 'India'),
(3, 'product_view', '2025-03-01 12:01:00', 'mobile', 'India'),
(3, 'add_to_cart', '2025-03-01 12:05:00', 'mobile', 'India'),
(3, 'purchase', '2025-03-01 12:10:00', 'mobile', 'India');
-- View inserted data
SELECT * FROM raw_events;
-- Create funnel table (one row per user)
CREATE TABLE funnel (
    user_id INT,
    visit INT,
    view INT,
    cart INT,
    purchase INT
);
-- Confirm funnel table exists
SHOW TABLES;
-- Converting user events into binary flags (1 = action performed, 0 = not performed)
-- Using MAX to ensure that if a user performed an action at least once, it is captured
INSERT INTO funnel
SELECT 
    user_id,
    MAX(CASE WHEN event = 'visit' THEN 1 ELSE 0 END),
    MAX(CASE WHEN event = 'product_view' THEN 1 ELSE 0 END),
    MAX(CASE WHEN event = 'add_to_cart' THEN 1 ELSE 0 END),
    MAX(CASE WHEN event = 'purchase' THEN 1 ELSE 0 END)
FROM raw_events
GROUP BY user_id;
SELECT * FROM funnel;
-- Analyzing user drop-off across funnel stages to identify where users are leaving the platform
SELECT 
    SUM(visit) AS total_visits,
    SUM(view) AS total_views,
    SUM(cart) AS total_carts,
    SUM(purchase) AS total_purchases
FROM funnel;
-- Calculate conversion rate
SELECT 
    SUM(purchase) * 1.0 / SUM(visit) AS conversion_rate
FROM funnel;
-- Users who dropped between view and cart
SELECT 
    SUM(view) - SUM(cart) AS drop_view_to_cart
FROM funnel;
-- Analyze users by device
SELECT 
    device,
    COUNT(DISTINCT user_id) AS users
FROM raw_events
GROUP BY device;

   

