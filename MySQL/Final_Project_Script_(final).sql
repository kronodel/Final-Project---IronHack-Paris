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

-- We need at least 4 entities for our project, so let's split electricity_consumption table into 2 tables 
-- Create the electricity_consumption table
CREATE TABLE electricity_consumption_fr (
  Datetime datetime NOT NULL,
  date date NOT NULL,
  Year int NOT NULL,
  Month int NOT NULL,
  Day int NOT NULL,
  Hour int NOT NULL,
  Weekday int NOT NULL,
  `Consumption (MW)`float NOT NULL,
  `Fuel oil (MW)` float NOT NULL,
  `Coal (MW)` float NOT NULL,
  `Gas (MW)` float NOT NULL,
  `Nuclear (MW)` float NOT NULL,
  `Wind (MW)` float NOT NULL,
  `Solar (MW)` float NOT NULL,
  `Hydroelectric (MW)` float NOT NULL,
  `Pumped storage (MW)` float NOT NULL,
  `Bioenergy (MW)` float NOT NULL,
  `CO2 emissions intensity (g/kWh)` float NOT NULL,
  PRIMARY KEY (Datetime)
);


-- Create the physical_exchanges table
CREATE TABLE physical_exchanges (
  Datetime datetime NOT NULL,
  date date NOT NULL,
  Year int NOT NULL,
  `Physical exchanges (MW)` float NOT NULL,
  `Trading with England (MW)` float NOT NULL,
  `Trading with Spain (MW)` float NOT NULL,
  `Trading with Italy (MW)`float NOT NULL,
  `Trading with Switzerland (MW)` float NOT NULL,
  `Trading with Germany-Belgium (MW)` float NOT NULL,
  PRIMARY KEY (Datetime)
);

-- Insert data into the two tables by selecting from the original table
INSERT INTO electricity_consumption_fr
SELECT Datetime, date, Year, Month, Day, Hour, Weekday, `Consumption (MW)`, `Fuel oil (MW)`, `Coal (MW)`, `Gas (MW)`, `Nuclear (MW)`, 
`Wind (MW)`, `Solar (MW)`, `Hydroelectric (MW)`, `Pumped storage (MW)`, `Bioenergy (MW)`, `CO2 emissions intensity (g/kWh)`
FROM electricity_consumption;

INSERT INTO physical_exchanges
SELECT Datetime, date, Year, `Physical exchanges (MW)`, `Trading with England (MW)`, `Trading with Spain (MW)`, 
`Trading with Italy (MW)`, `Trading with Switzerland (MW)`, `Trading with Germany-Belgium (MW)`
FROM electricity_consumption;

-- Checking the tables :
SELECT * FROM electricity_consumption_fr;
SELECT * FROM physical_exchanges;

-- Fixing the relation between the tables (keys) :
-- Modify the physical_exchanges table to add the foreign key constraint
ALTER TABLE physical_exchanges
ADD CONSTRAINT fk_physical_exchanges_electricity_consumption_fr
FOREIGN KEY (Datetime)
REFERENCES electricity_consumption_fr(Datetime);

-- Modify the electricity_consumption_fr table to add the foreign key constraint
ALTER TABLE electricity_consumption_fr
ADD CONSTRAINT fk_electricity_consumption_fr_date
FOREIGN KEY (date)
REFERENCES holidays(date);

ALTER TABLE electricity_consumption_fr
ADD CONSTRAINT fk_electricity_consumption_fr_weather_date
FOREIGN KEY (date)
REFERENCES weather(date);

-- Modify the physical_exchanges table to add the foreign key constraint
ALTER TABLE physical_exchanges
ADD CONSTRAINT fk_physical_exchanges_date
FOREIGN KEY (date)
REFERENCES holidays(date);

ALTER TABLE physical_exchanges
ADD CONSTRAINT fk_physical_exchanges_weather_date
FOREIGN KEY (date)
REFERENCES weather(date);

ALTER TABLE physical_exchanges
DROP COLUMN date;

-- Now we can drop the electricity_consumption table.

-- There too much relations between the table, let's delete remove the relations between physical exchanges, weather & holidays
-- in order too keep it simple.

-- Drop the foreign key constraint between physical_exchanges table and weather table
ALTER TABLE physical_exchanges DROP FOREIGN KEY fk_physical_exchanges_weather_date;

-- Drop the foreign key constraint between physical_exchanges table and holidays table
ALTER TABLE physical_exchanges DROP FOREIGN KEY fk_physical_exchanges_date;

-- Let's start the EDA with SQL
DESCRIBE electricity_consumption_fr;
DESCRIBE physical_exchanges;
DESCRIBE weather;
DESCRIBE holidays;

-- The average electricity consumption by year
SELECT Year, AVG(`Consumption (MW)`) AS avg_consumption
FROM electricity_consumption_fr 
GROUP BY Year ORDER BY avg_consumption DESC;

-- The average electricity consumption by month
SELECT Month, AVG(`Consumption (MW)`) AS avg_consumption
FROM electricity_consumption_fr 
GROUP BY Month ORDER BY avg_consumption DESC;

-- The average electricity consumption by weekday
SELECT Weekday, AVG(`Consumption (MW)`) AS avg_consumption
FROM electricity_consumption_fr 
GROUP BY Weekday ORDER BY avg_consumption DESC;

-- The average electricity consumption by hour
SELECT Hour, AVG(`Consumption (MW)`) AS avg_consumption
FROM electricity_consumption_fr 
GROUP BY Hour ORDER BY avg_consumption DESC;

-- The average electricity consumption by sources of energy
SELECT 'Fuel oil' AS source, ROUND(AVG(`Fuel oil (MW)`)) AS average_consumption 
FROM electricity_consumption_fr
UNION ALL 
SELECT 'Coal' AS source, ROUND(AVG(`Coal (MW)`)) AS average_consumption 
FROM electricity_consumption_fr
UNION ALL 
SELECT 'Gas' AS source, ROUND(AVG(`Gas (MW)`)) AS average_consumption 
FROM electricity_consumption_fr
UNION ALL 
SELECT 'Nuclear' AS source, ROUND(AVG(`Nuclear (MW)`)) AS average_consumption 
FROM electricity_consumption_fr
UNION ALL 
SELECT 'Wind' AS source, ROUND(AVG(`Wind (MW)`)) AS average_consumption 
FROM electricity_consumption_fr
UNION ALL 
SELECT 'Solar' AS source, ROUND(AVG(`Solar (MW)`)) AS average_consumption 
FROM electricity_consumption_fr
UNION ALL 
SELECT 'Hydroelectric' AS source, ROUND(AVG(`Hydroelectric (MW)`)) AS average_consumption 
FROM electricity_consumption_fr
UNION ALL 
SELECT 'Pumped storage' AS source, ROUND(AVG(`Pumped storage (MW)`)) AS average_consumption 
FROM electricity_consumption_fr
UNION ALL 
SELECT 'Bioenergy' AS source, ROUND(AVG(`Bioenergy (MW)`)) AS average_consumption 
FROM electricity_consumption_fr
GROUP BY source 
ORDER BY average_consumption DESC;

-- The average trading (MW) exchanges with other countries
SELECT 'Trading with England (MW)' AS country, ROUND(AVG(`Trading with England (MW)`)) AS average_trading
FROM physical_exchanges
UNION ALL 
SELECT 'Trading with Spain (MW)' AS country, ROUND(AVG(`Trading with Spain (MW)`)) AS average_trading
FROM physical_exchanges 
UNION ALL 
SELECT 'Trading with Italy (MW)' AS country, ROUND(AVG(`Trading with Italy (MW)`)) AS average_trading
FROM physical_exchanges 
UNION ALL 
SELECT 'Trading with Switzerland (MW)' AS country, ROUND(AVG(`Trading with Switzerland (MW)`)) AS average_trading
FROM physical_exchanges
UNION ALL 
SELECT 'Trading with Germany-Belgium (MW)' AS country, ROUND(AVG(`Trading with Germany-Belgium (MW)`)) AS average_trading
FROM physical_exchanges
GROUP BY country
ORDER BY average_trading DESC;


-- The average physical exchanges by Year
SELECT Year, ROUND(AVG(`Physical exchanges (MW)`)) AS average_physical_exchanges
FROM physical_exchanges
GROUP BY Year
ORDER BY average_physical_exchanges DESC;

-- The average CO2 emission by year 
SELECT Year, ROUND(AVG(`CO2 emissions intensity (g/kWh)`)) AS average_CO2_emission_g_kWh
FROM electricity_consumption_fr
GROUP BY Year
ORDER BY average_CO2_emission_g_kWh DESC;

-- The average CO2 emission by Month
SELECT Month, ROUND(AVG(`CO2 emissions intensity (g/kWh)`)) AS average_CO2_emission_g_kWh
FROM electricity_consumption_fr
GROUP BY Month
ORDER BY average_CO2_emission_g_kWh DESC;

-- The Average temperature (°C) and the date of the top 10 days with the higher average Consumption (MW)
SELECT weather.`date`, ROUND(AVG(weather.`Average temperature (°C)`), 1) AS `Average temperature (°C)`, 
ROUND(AVG(electricity_consumption_fr.`Consumption (MW)`), 1) AS `Average Consumption (MW)`
FROM electricity_consumption_fr
INNER JOIN weather ON electricity_consumption_fr.`date` = weather.`date`
GROUP BY weather.`date`
ORDER BY `Average Consumption (MW)` DESC
LIMIT 10;

-- The average energy consumption (MW) and average CO2 emission (g/kWh) by flag holiday 
SELECT holidays.`Flag Holiday`, 
    ROUND(AVG(electricity_consumption_fr.`Consumption (MW)`) ,0) AS avg_consumption, 
    ROUND(AVG(electricity_consumption_fr.`CO2 emissions intensity (g/kWh)`) ,0) AS avg_co2
FROM holidays
INNER JOIN electricity_consumption_fr ON holidays.`date` = electricity_consumption_fr.`date`
GROUP BY holidays.`Flag Holiday`;

-- Creating a temporary table that merges all the tables using the date information in order extract it for the next steps of the project
CREATE TEMPORARY TABLE temp_electricity_consumption AS
SELECT ecf.*,
       h.`Flag Holiday`,
       w.`Average temperature (°C)`,
       w.`Reference temperature (°C)`,
       w.`Temperature Deviation (°C)`
FROM electricity_consumption_fr AS ecf
JOIN holidays AS h ON ecf.date = h.date
JOIN weather AS w ON ecf.date = w.date;

SELECT * FROM temp_electricity_consumption;