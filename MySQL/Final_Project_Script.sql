# CREATE SCHEMA `final_project_energy` ;

CREATE DATABASE IF NOT EXISTS `final_project_energy` ;
USE `final_project_energy` ;

# We used pyMysql to load the datasets

# Let's take a lookt to the data :
SELECT * FROM holidays;
SELECT * FROM weather;
SELECT * FROM electricity_consumption;

# Let's check the characteristics 

DESCRIBE electricity_consumption;
DESCRIBE weather;
DESCRIBE holidays;

# The data types are not good so we need to fix this

# DATA CLEANING

-- Modifying the data type of columns of holidays table
ALTER TABLE holidays MODIFY COLUMN date date NOT NULL;
ALTER TABLE holidays MODIFY COLUMN Year int NOT NULL;
ALTER TABLE holidays MODIFY COLUMN Month int NOT NULL;
ALTER TABLE holidays MODIFY COLUMN Day int NOT NULL;
ALTER TABLE holidays MODIFY COLUMN Weekday int NOT NULL;
ALTER TABLE holidays MODIFY COLUMN `Flag Holiday` int NOT NULL;

-- Adding Primary Key constraint to the date column
ALTER TABLE holidays ADD PRIMARY KEY (date);

-- Modifying the data type of columns of weather table

ALTER TABLE weather
MODIFY date date NOT NULL,
MODIFY Year int NOT NULL,
MODIFY Month int NOT NULL,
MODIFY Day int NOT NULL,
MODIFY Weekday int NOT NULL,
MODIFY `Average temperature (°C)` float NOT NULL,
MODIFY `Reference temperature (°C)` float NOT NULL,
MODIFY `Temperature Deviation (°C)` float NOT NULL,
ADD PRIMARY KEY (date),
ADD CONSTRAINT `fk_weather_holidays` FOREIGN KEY (date) REFERENCES holidays(date);

-- Modifying the data type of columns of electricity_consumption table

ALTER TABLE electricity_consumption
MODIFY Datetime datetime NOT NULL,
MODIFY Year int NOT NULL,
MODIFY Month int NOT NULL,
MODIFY Day int NOT NULL,
MODIFY Hour int NOT NULL,
MODIFY Weekday int NOT NULL,
MODIFY `Consumption (MW)` float NOT NULL,
MODIFY `Fuel oil (MW)` float NOT NULL,
MODIFY `Coal (MW)` float NOT NULL,
MODIFY `Gas (MW)` float NOT NULL,
MODIFY `Nuclear (MW)` float NOT NULL,
MODIFY `Wind (MW)` float NOT NULL,
MODIFY `Solar (MW)` float NOT NULL,
MODIFY `Hydroelectric (MW)` float NOT NULL,
MODIFY `Pumped storage (MW)` float NOT NULL,
MODIFY `Bioenergy (MW)` float NOT NULL,
MODIFY `Physical exchanges (MW)` float NOT NULL,
MODIFY `CO2 emissions intensity (g/kWh)` float NOT NULL,
MODIFY `Trading with England (MW)` float NOT NULL,
MODIFY `Trading with Spain (MW)` float NOT NULL,
MODIFY `Trading with Italy (MW)` float NOT NULL,
MODIFY `Trading with Switzerland (MW)` float NOT NULL,
MODIFY `Trading with Germany-Belgium (MW)` float NOT NULL,
ADD PRIMARY KEY (Datetime);

/* The table electricity_consumption is not connected to the other tables by datetime PM to date PM of holidays table and weather table 
because datetime and date are different data types. The datetime column in the electricity_consumption table stores both date and time 
information, while the date column in the holidays and weather tables stores only date information. */

SELECT * FROM electricity_consumption;

-- I am going to extract the date from datetime column and create a new column date to be able to connect all the table in the ERM
ALTER TABLE electricity_consumption ADD COLUMN date DATE;
UPDATE electricity_consumption SET date = DATE(Datetime);

ALTER TABLE electricity_consumption ADD CONSTRAINT fk_weather_date FOREIGN KEY (date) REFERENCES weather(date);
ALTER TABLE electricity_consumption ADD CONSTRAINT fk_holidays_date FOREIGN KEY (date) REFERENCES holidays(date);

-- putting the date column just after Datetime column in the table
ALTER TABLE electricity_consumption
CHANGE COLUMN date date DATE NOT NULL AFTER Datetime;

-- The average electricity consumption by year

SELECT Year, AVG(`Consumption (MW)`) AS avg_consumption
FROM electricity_consumption 
GROUP BY Year ORDER BY avg_consumption DESC;

-- The average electricity consumption by month

SELECT Month, AVG(`Consumption (MW)`) AS avg_consumption
FROM electricity_consumption 
GROUP BY Month ORDER BY avg_consumption DESC;

-- The average electricity consumption by weekday

SELECT Weekday, AVG(`Consumption (MW)`) AS avg_consumption
FROM electricity_consumption 
GROUP BY Weekday ORDER BY avg_consumption DESC;

-- The average electricity consumption by hour

SELECT Hour, AVG(`Consumption (MW)`) AS avg_consumption
FROM electricity_consumption 
GROUP BY Hour ORDER BY avg_consumption DESC;

-- The average electricity consumption by sources of energy

SELECT 'Fuel oil' AS source, AVG(`Fuel oil (MW)`) AS average_consumption 
FROM electricity_consumption 
UNION ALL 
SELECT 'Coal' AS source, AVG(`Coal (MW)`) AS average_consumption 
FROM electricity_consumption 
UNION ALL 
SELECT 'Gas' AS source, AVG(`Gas (MW)`) AS average_consumption 
FROM electricity_consumption 
UNION ALL 
SELECT 'Nuclear' AS source, AVG(`Nuclear (MW)`) AS average_consumption 
FROM electricity_consumption 
UNION ALL 
SELECT 'Wind' AS source, AVG(`Wind (MW)`) AS average_consumption 
FROM electricity_consumption 
UNION ALL 
SELECT 'Solar' AS source, AVG(`Solar (MW)`) AS average_consumption 
FROM electricity_consumption 
UNION ALL 
SELECT 'Hydroelectric' AS source, AVG(`Hydroelectric (MW)`) AS average_consumption 
FROM electricity_consumption 
UNION ALL 
SELECT 'Pumped storage' AS source, AVG(`Pumped storage (MW)`) AS average_consumption 
FROM electricity_consumption 
UNION ALL 
SELECT 'Bioenergy' AS source, AVG(`Bioenergy (MW)`) AS average_consumption 
FROM electricity_consumption 
GROUP BY source 
ORDER BY average_consumption DESC;

-- The average trading (MW) exchanges with other countries

SELECT 'Trading with England (MW)' AS country, AVG(`Trading with England (MW)`) AS average_trading
FROM electricity_consumption 
UNION ALL 
SELECT 'Trading with Spain (MW)' AS country, AVG(`Trading with Spain (MW)`) AS average_trading
FROM electricity_consumption 
UNION ALL 
SELECT 'Trading with Italy (MW)' AS country, AVG(`Trading with Italy (MW)`) AS average_trading
FROM electricity_consumption 
UNION ALL 
SELECT 'Trading with Switzerland (MW)' AS country, AVG(`Trading with Switzerland (MW)`) AS average_trading
FROM electricity_consumption
UNION ALL 
SELECT 'Trading with Germany-Belgium (MW)' AS country, AVG(`Trading with Germany-Belgium (MW)`) AS average_trading
FROM electricity_consumption
GROUP BY country
ORDER BY average_trading DESC;

-- The average physical exchanges by Year

SELECT Year, AVG(`Physical exchanges (MW)`) AS average_physical_exchanges
FROM electricity_consumption
GROUP BY Year
ORDER BY average_physical_exchanges DESC;

-- The average CO2 emission by year 

SELECT Year, AVG(`CO2 emissions intensity (g/kWh)`) AS average_CO2_emission_g_kWh
FROM electricity_consumption
GROUP BY Year
ORDER BY average_CO2_emission_g_kWh DESC;

-- The average CO2 emission by Month

SELECT Month, AVG(`CO2 emissions intensity (g/kWh)`) AS average_CO2_emission_g_kWh
FROM electricity_consumption
GROUP BY Month
ORDER BY average_CO2_emission_g_kWh DESC;

-- The Average temperature (°C) and the date of the top 10 days with the higher average Consumption (MW)

SELECT weather.`date`, AVG(weather.`Average temperature (°C)`) AS `Average temperature (°C)`, 
AVG(electricity_consumption.`Consumption (MW)`) AS `Average Consumption (MW)`
FROM electricity_consumption
INNER JOIN weather ON electricity_consumption.`date` = weather.`date`
GROUP BY weather.`date`
ORDER BY `Average Consumption (MW)` DESC
LIMIT 10;

-- The average energy consumption (MW) and average CO2 emission (g/kWh) by flag holiday 

SELECT holidays.`Flag Holiday`, AVG(electricity_consumption.`Consumption (MW)`) AS avg_consumption, 
AVG(electricity_consumption.`CO2 emissions intensity (g/kWh)`) AS avg_co2
FROM holidays
INNER JOIN electricity_consumption ON holidays.`date` = electricity_consumption.`date`
GROUP BY holidays.`Flag Holiday`;

-- Creating a temporary table that merges all the tables using the date information in order extract it for the next steps of the project

CREATE TEMPORARY TABLE temp_electricity_consumption AS
SELECT ec.*,
       h.`Flag Holiday`,
       w.`Average temperature (°C)`,
       w.`Reference temperature (°C)`,
       w.`Temperature Deviation (°C)`
FROM electricity_consumption AS ec
JOIN holidays AS h ON ec.date = h.date
JOIN weather AS w ON ec.date = w.date;

SELECT * FROM temp_electricity_consumption;
