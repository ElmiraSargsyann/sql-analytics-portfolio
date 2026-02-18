CREATE SCHEMA analysis;

CREATE TABLE analytics.hotel_bookings (
    hotel VARCHAR(100),
    country VARCHAR(100),
    city VARCHAR(100),
    
    is_canceled BOOLEAN,
    lead_time INTEGER,
    
    arrival_date_year INTEGER,
    arrival_date_month VARCHAR(20),
    arrival_date_week_number INTEGER,
    arrival_date_day_of_month INTEGER,
    
    stays_in_weekend_nights INTEGER,
    stays_in_week_nights INTEGER,
    
    adults INTEGER,
	
    market_segment VARCHAR(50),
    distribution_channel VARCHAR(50),
    
    reserved_room_type VARCHAR(10),
    assigned_room_type VARCHAR(10),
    
    booking_changes INTEGER,
    deposit_type VARCHAR(50),
    
    agent NUMERIC(10,2),
    company NUMERIC(10,2),
    
    customer_type VARCHAR(50),
    adr NUMERIC(10,2),
    
    reservation_status VARCHAR(50),
    reservation_status_date DATE,
    
    name VARCHAR(150),
    email VARCHAR(150),
    phone_number VARCHAR(30),
    credit_card VARCHAR(50)
);

COPY analytics.hotel_bookings
FROM '/docker-entrypoint-initdb.d/data/hotels_schema/hotel_booking.csv'
CSV HEADER; 

SELECT * 
FROM analytics.hotel_bookings
-- created analytics.hotel_bookings 

CREATE TABLE analytics.rooms AS 
SELECT
	ROW_NUMBER() OVER () AS room_id,
	reserved_room_type
FROM (
	SELECT DISTINCT 
	TRIM(reserved_room_type) AS reserved_room_type
	FROM analytics.hotel_bookings
	WHERE reserved_room_type IS NOT NULL
)

ALTER TABLE analytics.rooms
ADD PRIMARY KEY (room_id)

SELECT * 
FROM analytics.rooms
-- created analytics.rooms table

CREATE TABLE analytics.agents AS
SELECT
	ROW_NUMBER() OVER () AS agent_id,
	agent
FROM (
	SELECT DISTINCT 
	agent
	FROM analytics.hotel_bookings
	WHERE agent IS NOT NULL
);

ALTER TABLE analytics.agents
ADD PRIMARY KEY (agent_id)

SELECT * 
FROM analytics.agents
-- created analytics.agents table

CREATE TABLE analytics.customers AS 
SELECT
	ROW_NUMBER() OVER () AS customer_id,
	customer_name,
	customer_email UNIQUE,
	phone_number
FROM(
	SELECT DISTINCT
	TRIM(name) AS customer_name,
	TRIM(email) AS customer_email,
	phone_number
	FROM analytics.hotel_bookings
	WHERE name IS NOT NULL
		AND email IS NOT NULL
		AND phone_number IS NOT NULL
)

ALTER TABLE analytics.customers
ADD PRIMARY KEY (customer_id)

SELECT * 
FROM analytics.customers
-- created analytics.customers table

CREATE TABLE analytics.countries AS
SELECT
    ROW_NUMBER() OVER () AS country_id,
    country_name
FROM (
    SELECT DISTINCT TRIM(country) AS country_name
    FROM analytics.hotel_bookings
    WHERE country IS NOT NULL
) 

ALTER TABLE analytics.countries
ADD PRIMARY KEY (country_id)

SELECT * 
FROM analytics.countries
-- created analytics.countries table

DROP TABLE analytics.cities

CREATE TABLE analytics.cities AS
SELECT
	ROW_NUMBER() OVER () AS city_id,
	TRIM(t.city) AS city_name,
	c.country_id
FROM(
	SELECT DISTINCT
	city,
	country
	FROM analytics.hotel_bookings
    WHERE city IS NOT NULL 
) t
JOIN analytics.countries c
    ON t.country = c.country_name;

ALTER TABLE analytics.cities
ADD PRIMARY KEY (city_id)

-- ALTER TABLE analytics.cities
-- ADD COLUMN country_id BIGINT;

ALTER TABLE analytics.cities
ADD CONSTRAINT fk_cities_country
FOREIGN KEY (country_id)
REFERENCES analytics.countries(country_id);

SELECT
	* 
FROM analytics.cities
-- created analytics.cities table

CREATE TABLE analytics.hotels AS(
SELECT
	DISTINCT
	ROW_NUMBER () OVER () AS hotel_id,
	hotel AS hotel_name
FROM analytics.hotel_bookings
)

ALTER TABLE analytics.hotels
ADD PRIMARY KEY (hotel_id);

ALTER TABLE analytics.hotels
ADD COLUMN city_id INT;

ALTER TABLE analytics.hotels
ADD CONSTRAINT fk_hotels_city
FOREIGN KEY (city_id)
REFERENCES analytics.cities (city_id)
-- created analytics.hotels table

CREATE TABLE analytics.bookings AS (
SELECT
	DISTINCT
	ROW_NUMBER () OVER () AS booking_id,
	lead_time,
	arrival_date_year,
	arrival_date_month,
	stays_in_weekend_nights,
	stays_in_week_nights,
	adults,
	market_segment AS customer_segment,
	distribution_channel,
	booking_changes,
	deposit_type,
	customer_type,
	adr AS average_daily_rate
FROM analytics.hotel_bookings
)

ALTER TABLE analytics.bookings 
ADD PRIMARY KEY (booking_id);

ALTER TABLE analytics.bookings
ADD COLUMN hotel_id INT,
ADD COLUMN customer_id INT,
ADD COLUMN room_id INT, 
ADD COLUMN agent_id INT;

ALTER TABLE analytics.bookings
ADD CONSTRAINT fk_bookings_hotel
FOREIGN KEY (hotel_id)
REFERENCES analytics.hotels (hotel_id);

ALTER TABLE analytics.bookings
ADD CONSTRAINT fk_bookings_customer
FOREIGN KEY (customer_id)
REFERENCES analytics.customers (customer_id);


ALTER TABLE analytics.bookings
ADD CONSTRAINT fk_bookings_room
FOREIGN KEY (room_id)
REFERENCES analytics.rooms (room_id);

ALTER TABLE analytics.rooms
DROP CONSTRAINT fk_bookings_room; 

ALTER TABLE analytics.bookings
ADD CONSTRAINT fk_bookings_agent
FOREIGN KEY (agent_id)
REFERENCES analytics.agents (agent_id);
-- created analytics.booking table

CREATE TABLE analytics.payments AS (
SELECT
	DISTINCT
	ROW_NUMBER () OVER ()  AS payment_id,
	deposit_type
FROM analytics.hotel_bookings
);

ALTER TABLE analytics.payments
ADD PRIMARY KEY (payment_id);

ALTER TABLE analytics.payments
ADD COLUMN booking_id INT;

ALTER TABLE analytics.payments
ADD CONSTRAINT fk_payments_booking
FOREIGN KEY (booking_id)
REFERENCES analytics.bookings (booking_id);
-- created analytics.payments table

CREATE TABLE analytics.reservation_status AS (
SELECT
	DISTINCT
	ROW_NUMBER () OVER () AS status_id,
	reservation_status,
	reservation_status_date,
	is_canceled
FROM analytics.hotel_bookings
);

ALTER TABLE analytics.reservation_status
ADD PRIMARY KEY (status_id);

ALTER TABLE analytics.reservation_status
ADD COLUMN booking_id INT;

ALTER TABLE analytics.reservation_status
ADD CONSTRAINT fk_reservation_booking
FOREIGN KEY (booking_id)
REFERENCES analytics.bookings (booking_id);

SELECT
	* 
FROM analytics.cities

SELECT 
  COUNT(*) 
FROM analytics.hotel_bookings;