CREATE TABLE event_counts AS
SELECT event_type, COUNT(*) AS event_count
FROM SOURCE_USER_EVENTS
GROUP BY event_type
EMIT CHANGES;

CREATE STREAM login_events AS
SELECT *
FROM SOURCE_USER_EVENTS
WHERE event_type = 'login'
EMIT CHANGES;

CREATE TABLE location_event_counts AS
SELECT location, COUNT(*) AS event_count
FROM SOURCE_USER_EVENTS
GROUP BY location
EMIT CHANGES;

SELECT * FROM event_counts EMIT CHANGES;

SELECT * FROM login_events EMIT CHANGES;

SELECT * FROM location_event_counts EMIT CHANGES;
