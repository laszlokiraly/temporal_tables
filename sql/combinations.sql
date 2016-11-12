CREATE TABLE versioning (a bigint, "b b" date, sys_period tstzrange);

-- Insert some data before versioning is enabled.
INSERT INTO versioning (a, sys_period) VALUES (1, tstzrange('-infinity', NULL));
INSERT INTO versioning (a, sys_period) VALUES (2, tstzrange('2000-01-01', NULL));

CREATE TABLE versioning_history (a bigint, "b b" date, c date, sys_period tstzrange);

CREATE TRIGGER versioning_trigger
BEFORE INSERT OR UPDATE OR DELETE ON versioning
FOR EACH ROW EXECUTE PROCEDURE versioning('sys_period', 'versioning_history', false);

-- Insert + Update.
BEGIN;

INSERT INTO versioning (a) VALUES (3);

UPDATE versioning SET a = 4 WHERE a = 3;

SELECT a, "b b", lower(sys_period) = CURRENT_TIMESTAMP FROM versioning ORDER BY a, sys_period;

SELECT * FROM versioning_history ORDER BY a, sys_period;

COMMIT;

-- Make sure that the next transaction's CURRENT_TIMESTAMP is different.
SELECT pg_sleep(0.1);

-- Multiple updates.
BEGIN;

UPDATE versioning SET a = 5 WHERE a = 4;

UPDATE versioning SET "b b" = '2012-01-01' WHERE a = 5;

SELECT a, "b b", lower(sys_period) = CURRENT_TIMESTAMP FROM versioning ORDER BY a, sys_period;

SELECT a, "b b", c, upper(sys_period) = CURRENT_TIMESTAMP FROM versioning_history ORDER BY a, sys_period;

COMMIT;

-- Make sure that the next transaction's CURRENT_TIMESTAMP is different.
SELECT pg_sleep(0.1);

-- Insert + Delete.
BEGIN;

INSERT INTO versioning (a) VALUES (6);

DELETE FROM versioning WHERE a = 6;

SELECT a, "b b", lower(sys_period) = CURRENT_TIMESTAMP FROM versioning ORDER BY a, sys_period;

SELECT a, "b b", c, upper(sys_period) = CURRENT_TIMESTAMP FROM versioning_history ORDER BY a, sys_period;

END;

-- Make sure that the next transaction's CURRENT_TIMESTAMP is different.
SELECT pg_sleep(0.1);

-- Update + Delete.
BEGIN;

UPDATE versioning SET "b b" = '2015-01-01' WHERE a = 5;

DELETE FROM versioning WHERE a = 5;

SELECT a, "b b", lower(sys_period) = CURRENT_TIMESTAMP FROM versioning ORDER BY a, sys_period;

SELECT a, "b b", c, upper(sys_period) = CURRENT_TIMESTAMP FROM versioning_history ORDER BY a, sys_period;

END;

DROP TABLE versioning;
DROP TABLE versioning_history;
