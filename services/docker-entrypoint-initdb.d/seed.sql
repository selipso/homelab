CREATE DATABASE IF NOT EXISTS sampledb;

\c sampledb

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50),
  email VARCHAR(100) UNIQUE
);

INSERT INTO users (name, email) VALUES
  ('Alpha', 'alpha@example.com'),
  ('Beta', 'beta@example.com'),
  ('Gamma', 'gamma@example.com');
