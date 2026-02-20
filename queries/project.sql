-- CREATE DATABASE hotels;

-- CREATE SCHEMA analytics;

-- CREATE TABLE analytics.hotel_bookings (    
--     hotel TEXT,
--     country VARCHAR(10),
--     is_canceled INTEGER,
--     lead_time INTEGER,
    
--     arrival_date_year INTEGER,
--     arrival_date_month VARCHAR(20),
--     arrival_date_week_number INTEGER,
--     arrival_date_day_of_month INTEGER,
    
--     stays_in_weekend_nights INTEGER,
--     stays_in_week_nights INTEGER,
    
--     adults INTEGER,
--     children NUMERIC(3,1),
--     babies INTEGER,
    
--     meal VARCHAR(20),
--     market_segment VARCHAR(50),
--     distribution_channel VARCHAR(50),
    
--     reserved_room_type VARCHAR(5),
--     booking_changes INTEGER,
    
--     agent NUMERIC(10,2),
--     customer_type VARCHAR(50),
    
--     adr NUMERIC(10,2),
    
--     reservation_status VARCHAR(20),
--     reservation_status_date TIMESTAMP,
    
--     name VARCHAR(100),
--     email VARCHAR(100),
--     phone_number VARCHAR(30)
-- );

-- COPY analytics.hotel_bookings
-- FROM '/docker-entrypoint-initdb.d/data/hotels_schema/hotel_booking.csv'
-- CSV HEADER; 

-- SELECT * 
-- FROM analytics.hotel_bookings
-- LIMIT 50
-- created analytics.hotel_bookings 

-- DROP EXTENSION IF EXISTS postgis CASCADE;
-- CREATE EXTENSION postgis;
-- SELECT PostGIS_Version();
-- create postgis

-- CREATE TABLE analytics._stg_world_countries (
--     country_name TEXT NOT NULL,
--     country_code TEXT NOT NULL,
--     geom geometry(MULTIPOLYGON, 4326) NOT NULL
-- );

-- INSERT INTO analytics._stg_world_countries (country_name, country_code, geom)
-- SELECT
--     feature->'properties'->>'name' AS country_name,
--     feature->>'id' AS country_code,
--     ST_SetSRID(
--         ST_Multi(
--             ST_CollectionExtract(
--                 ST_Force2D(
--                     ST_MakeValid(
--                         ST_GeomFromGeoJSON(feature->>'geometry')
--                     )
--                 ),
--             3)
--         ),
--         4326
--     ) AS geom
-- FROM (
--     SELECT jsonb_array_elements(data->'features') AS feature
--     FROM (
-- 		SELECT pg_read_file('/docker-entrypoint-initdb.d/data/hotels_schema/countries.geo.json')::jsonb AS data
--     ) f
-- ) sub;

-- SELECT 
--     * 
-- FROM analytics._stg_world_countries
--  create _stg_world_countries

-- CREATE TABLE analytics.country (
-- 	country_id SERIAL PRIMARY KEY,
-- 	country_code VARCHAR(10) UNIQUE NOT NULL,
-- 	country_name VARCHAR(100),
-- 	geom geometry(MULTIPOLYGON, 4326)
-- );

-- INSERT INTO analytics.country(country_code, country_name, geom)
-- SELECT
--     hb.country_code,
--     s.country_name,
--     s.geom
-- FROM (
--     SELECT DISTINCT TRIM(country) AS country_code
--     FROM analytics.hotel_bookings
--     WHERE country IS NOT NULL
-- ) hb
-- LEFT JOIN analytics._stg_world_countries s
--     ON hb.country_code = s.country_code;

-- SELECT
-- 	*
-- FROM analytics.country;
-- create country 

-- CREATE TABLE analytics.hotel (
-- 	hotel_id SERIAL PRIMARY KEY,
-- 	hotel_type VARCHAR(50) UNIQUE NOT NULL
-- );

-- INSERT INTO analytics.hotel(hotel_type)
-- SELECT DISTINCT
-- 	SPLIT_PART(hotel, '-', 1)
-- FROM analytics.hotel_bookings
-- WHERE hotel IS NOT NULL;

-- SELECT
-- 	*
-- FROM analytics.hotel;
--  create hotel

-- CREATE TABLE analytics.meals (
-- 	meal_id SERIAL PRIMARY KEY,
-- 	meal_type VARCHAR(50) UNIQUE NOT NULL
-- );

-- INSERT INTO analytics.meals (meal_type)
-- SELECT DISTINCT
-- 	TRIM(meal)
-- FROM analytics.hotel_bookings
-- WHERE meal IS NOT NULL;

-- SELECT
-- 	*
-- FROM analytics.meals;
-- create meals

-- CREATE TABLE analytics.market_segments(
-- 	segment_id SERIAL PRIMARY KEY,
-- 	segment_name VARCHAR(100) UNIQUE NOT NULL
-- );

-- INSERT INTO analytics.market_segments (segment_name)
-- SELECT DISTINCT
-- 	TRIM(market_segment)
-- FROM analytics.hotel_bookings
-- WHERE market_segment IS NOT NULL

-- SELECT
-- 	*
-- FROM analytics.market_segments;
-- create market_segments

-- CREATE TABLE  analytics.distribution_channels (
-- 	channel_id SERIAL PRIMARY KEY,
-- 	channel_name VARCHAR(100) UNIQUE NOT NULL
-- );

-- INSERT INTO analytics.distribution_channels (channel_name)
-- SELECT DISTINCT
-- 	TRIM(distribution_channel)
-- FROM analytics.hotel_bookings
-- WHERE distribution_channel IS NOT NULL;

-- SELECT
-- 	*
-- FROM analytics.distribution_channels;
-- create distribution_channels	

-- CREATE TABLE analytics.room_types (
-- 	room_type_id SERIAL PRIMARY KEY,
-- 	room_type VARCHAR(10) UNIQUE NOT NULL
-- );

-- INSERT INTO analytics.room_types (room_type)
-- SELECT DISTINCT 
-- 	TRIM(reserved_room_type)
-- FROM analytics.hotel_bookings
-- WHERE reserved_room_type IS NOT NULL;

-- SELECT
-- 	*
-- FROM analytics.room_types;
-- create room_types

-- CREATE TABLE analytics.customer_types (
-- 	customer_type_id SERIAL PRIMARY KEY,
-- 	customer_type VARCHAR(50) UNIQUE NOT NULL
-- );

-- INSERT INTO analytics.customer_types (customer_type)
-- SELECT DISTINCT
-- 	TRIM(customer_type)
-- FROM analytics.hotel_bookings
-- WHERE customer_type IS NOT NULL;

-- SELECT
-- 	*
-- FROM analytics.customer_types;
-- create customer_types	

-- CREATE TABLE analytics.agents (
-- 	agent_id SERIAL PRIMARY KEY,
-- 	agent_code INTEGER UNIQUE
-- );

-- INSERT INTO analytics.agents (agent_code)
-- SELECT DISTINCT
-- 	agent
-- FROM analytics.hotel_bookings
-- WHERE agent IS NOT NULL;

-- SELECT
-- 	*
-- FROM analytics.agents;
-- -- create agents

-- DROP TABLE analytics.customers

-- CREATE TABLE analytics.customers (
-- 	customer_id SERIAL PRIMARY KEY,
-- 	customer_name VARCHAR(150),
-- 	customer_email VARCHAR(150),
-- 	phone_number VARCHAR(30),
-- 	UNIQUE (customer_name, customer_email, phone_number)
-- );

-- INSERT INTO analytics.customers (customer_name, customer_email, phone_number)
-- SELECT DISTINCT
-- 	INITCAP(name),
-- 	LOWER(email),
-- 	REPLACE(TRIM(phone_number), '-', '')
-- FROM analytics.hotel_bookings
-- WHERE name IS NOT NULL
-- 	AND email IS NOT NULL
-- 	AND phone_number IS NOT NULL;

-- SELECT
-- 	*
-- FROM analytics.customers;
-- create customers

-- DROP TABLE analytics.bookings

-- CREATE TABLE analytics.bookings (
--     booking_id SERIAL PRIMARY KEY,

--     hotel_id INTEGER REFERENCES analytics.hotel(hotel_id),
--     country_id INTEGER REFERENCES analytics.country(country_id),
--     meal_id INTEGER REFERENCES analytics.meals(meal_id),
--     segment_id INTEGER REFERENCES analytics.market_segments(segment_id),
--     channel_id INTEGER REFERENCES analytics.distribution_channels(channel_id),
--     room_type_id INTEGER REFERENCES analytics.room_types(room_type_id),
--     customer_type_id INTEGER REFERENCES analytics.customer_types(customer_type_id),
--     agent_id INTEGER REFERENCES analytics.agents(agent_id),
--     customer_id INTEGER REFERENCES analytics.customers(customer_id),

--     is_canceled BOOLEAN,
--     lead_time INTEGER,
--     arrival_date DATE,
--     stays_in_week_nights INTEGER,
--     stays_in_weekend_nights INTEGER,
--     adults INTEGER,
--     children INTEGER,
--     babies INTEGER,
--     booking_changes INTEGER,
--     adr NUMERIC(10,2),
--     reservation_status VARCHAR(30),
--     reservation_status_date DATE
-- );

-- INSERT INTO analytics.bookings (
--     hotel_id,
--     country_id,
--     meal_id,
--     segment_id,
--     channel_id,
--     room_type_id,
--     customer_type_id,
--     agent_id,
--     customer_id,
--     is_canceled,
--     lead_time,
--     arrival_date,
--     stays_in_week_nights,
--     stays_in_weekend_nights,
--     adults,
--     children,
--     babies,
--     booking_changes,
--     adr,
--     reservation_status,
--     reservation_status_date
-- )
-- SELECT
--     h.hotel_id,
--     c.country_id,
--     m.meal_id,
--     ms.segment_id,
--     dc.channel_id,
--     rt.room_type_id,
--     ct.customer_type_id,
--     a.agent_id,
--     cu.customer_id,
--     CASE hb.is_canceled
--     	WHEN 0 THEN FALSE
--     	WHEN 1 THEN TRUE
--     END AS is_canceled,
--     hb.lead_time,
--     MAKE_DATE(
--         hb.arrival_date_year,
--         CASE TRIM(hb.arrival_date_month)
--             WHEN 'January' THEN 1
--             WHEN 'February' THEN 2
--             WHEN 'March' THEN 3
--             WHEN 'April' THEN 4
--             WHEN 'May' THEN 5
--             WHEN 'June' THEN 6
--             WHEN 'July' THEN 7
--             WHEN 'August' THEN 8
--             WHEN 'September' THEN 9
--             WHEN 'October' THEN 10
--             WHEN 'November' THEN 11
--             WHEN 'December' THEN 12
--         END,
--         hb.arrival_date_day_of_month
--     ) AS arrival_date,
--     hb.stays_in_week_nights,
--     hb.stays_in_weekend_nights,
--     hb.adults,
--     hb.children,
--     hb.babies,
--     hb.booking_changes,
--     hb.adr,
--     hb.reservation_status,
--     hb.reservation_status_date
-- FROM analytics.hotel_bookings hb
-- LEFT JOIN analytics.hotel h ON SPLIT_PART(TRIM(hb.hotel), '-', 1) = h.hotel_type
-- LEFT JOIN analytics.country c ON TRIM(hb.country) = c.country_code
-- LEFT JOIN analytics.meals m ON TRIM(hb.meal) = m.meal_type
-- LEFT JOIN analytics.market_segments ms ON TRIM(hb.market_segment) = ms.segment_name
-- LEFT JOIN analytics.distribution_channels dc ON TRIM(hb.distribution_channel) = dc.channel_name
-- LEFT JOIN analytics.room_types rt ON TRIM(hb.reserved_room_type) = rt.room_type
-- LEFT JOIN analytics.customer_types ct ON TRIM(hb.customer_type) = ct.customer_type
-- LEFT JOIN analytics.agents a ON hb.agent = a.agent_code
-- LEFT JOIN analytics.customers cu ON LOWER(TRIM(hb.email)) = cu.customer_email;

-- SELECT
-- 	*
-- FROM analytics.bookings
-- LIMIT 100;
-- create analytics.bookings

-- SELECT
-- 	*
-- FROM analytics.country

-- SELECT COUNT(*) FROM analytics.country;
-- SELECT COUNT(*) FROM analytics.hotel;
-- SELECT COUNT(*) FROM analytics.meals;
-- SELECT COUNT(*) FROM analytics.market_segments;
-- SELECT COUNT(*) FROM analytics.distribution_channels;
-- SELECT COUNT(*) FROM analytics.room_types;
-- SELECT COUNT(*) FROM analytics.customer_types;
-- SELECT COUNT(*) FROM analytics.agents;
-- SELECT COUNT(*) FROM analytics.customers;
-- SELECT COUNT(*) FROM analytics.bookings;

SELECT * 
FROM analytics.room_types
LIMIT 50
-- Find the top 5 country for hotels
SELECT
	c.country_name,
	COUNT(b.booking_id) AS total_bookings
FROM analytics.bookings b
JOIN analytics.country c ON b.country_id = c.country_id
GROUP BY c.country_name
ORDER BY total_bookings DESC
LIMIT 5;

-- The most popular month for hotels
SELECT EXTRACT(YEAR FROM arrival_date) AS year,
       EXTRACT(MONTH FROM arrival_date) AS month,
       COUNT(*) AS bookings_count
FROM analytics.bookings
GROUP BY year, month
ORDER BY bookings_count DESC;

-- The most popular room type
SELECT
	rt.room_type,
	COUNT(*) AS bookings_count
FROM analytics.bookings	b
JOIN analytics.room_types rt ON b.room_type_id = rt.room_type_id
GROUP BY rt.room_type
ORDER BY bookings_count DESC
LIMIT 1;

-- The preferred meal type by customers
SELECT
	m.meal_type,
	COUNT(*) AS bookings_count
FROM analytics.bookings b
JOIN analytics.meals m ON b.meal_id = m.meal_id
GROUP BY m.meal_type
ORDER BY bookings_count DESC
LIMIT 1;

-- The most popular hotel type
SELECT
	h.hotel_type,
	COUNT(*) AS bookings_count
FROM analytics.bookings b
JOIN analytics.hotel h ON b.hotel_id = h.hotel_id
GROUP BY h.hotel_type
ORDER BY bookings_count DESC;

-- Bookings: self-booked or through travel agents
SELECT
	dc.channel_name,
	COUNT(*) AS bookings_count
FROM analytics.bookings b
JOIN analytics.distribution_channels dc ON b.channel_id = dc.channel_id
GROUP BY dc.channel_name
ORDER BY bookings_count DESC;
-- The majority of bookings are made through intermediaries (agents/tour operators), rather than directly.

-- Average room rate (ADR) by hotel type and country
SELECT
	h.hotel_type,
	c.country_name,
	AVG(adr) AS avg_adr
FROM analytics.bookings b
JOIN analytics.hotel h ON b.hotel_id = h.hotel_id
JOIN analytics.country c ON b.country_id = c.country_id
GROUP BY h.hotel_type, c.country_name
ORDER BY avg_adr DESC
LIMIT 5;

-- Total revenue by country
SELECT
	c.country_name,
	SUM(adr * (stays_in_week_nights + stays_in_weekend_nights)) AS total_revenue
FROM analytics.bookings b
JOIN analytics.country c ON b.country_id = c.country_id
GROUP BY c.country_name
ORDER BY total_revenue DESC
LIMIT 5;

-- Repeat guests vs. new ones
SELECT 
    guest_type,
    COUNT(*) AS number_of_guests,
    AVG(avg_adr) AS avg_adr
FROM (
    SELECT 
        customer_id,
        AVG(adr) AS avg_adr,
        CASE 
            WHEN COUNT(*) = 1 THEN 'New Guest'
            ELSE 'Repeat Guest'
        END AS guest_type
    FROM analytics.bookings
    GROUP BY customer_id
) sub
GROUP BY guest_type;

-- Cancellation rate by hotel type
SELECT
	h.hotel_type,
	COUNT(*) FILTER (WHERE is_canceled) * 100.0 / COUNT(*) AS cancel_rate
FROM analytics.bookings b
JOIN analytics.hotel h ON b.hotel_id = h.hotel_id
GROUP BY h.hotel_type
ORDER BY cancel_rate DESC;