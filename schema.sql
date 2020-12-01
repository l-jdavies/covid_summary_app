DROP TABLE IF EXISTS state_current_data;
DROP TABLE IF EXISTS state_seven_day_data;
DROP TABLE IF EXISTS state_fourteen_day_data;

CREATE TABLE state_current_data (
  id serial PRIMARY KEY,
  positive_cases text NOT NULL,
  hospitalizations text NOT NULL,
  deaths text NOT NULL,
  total_test_results text NOT NULL
);

CREATE TABLE state_seven_day_data (
  id serial PRIMARY KEY,
  positive_cases text NOT NULL,
  hospitalizations text NOT NULL,
  deaths text NOT NULL,
  total_test_results text NOT NULL
);

CREATE TABLE state_fourteen_day_data (
  id serial PRIMARY KEY,
  positive_cases text NOT NULL,
  hospitalizations text NOT NULL,
  deaths text NOT NULL,
  total_test_results text NOT NULL
);
