-- Modify Queries
CREATE DATABASE test_db;
CREATE EXTENSION plpython3u;  -- Will fail if PL/Python3 is not installed
CREATE TABLE test_tb_1(item VARCHAR,amount NUMERIC);
CREATE TABLE test_tb_2(item VARCHAR,amount NUMERIC);
INSERT INTO test_tb_1(item, amount) VALUES ('arrows',20),('skis',10),('SUPs',4);
INSERT INTO test_tb_2(item, amount) VALUES ('arrows',20),('skis',10),('SUPs',4);
UPDATE test_tb_1 SET amount=24 where item = 'arrows';
ALTER TABLE test_tb_2 RENAME item TO thing;
DELETE FROM test_tb_2 WHERE amount=10;
ALTER TABLE test_tb_2 DROP COLUMN amount;
DROP TABLE test_tb_2;
DROP DATABASE test_db;

-- Read Queries
SELECT datname FROM pg_database;
SELECT * from pg_extension;
SELECT * FROM test_tb_1;
SELECT * FROM test_tb_2;
SELECT * FROM test_tb_2 WHERE amount >= 10;
SELECT * from pg_catalog.pg_tables WHERE tablename='test_tb_2';