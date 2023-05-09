---
--- Function heights_inbuffer
---
--- Max, min, mean, etc. in heights in every buffer
---

DROP FUNCTION IF EXISTS heights_inbuffer CASCADE;
CREATE OR REPLACE FUNCTION heights_inbuffer (buffer int)
    RETURNS TABLE (
    house_id INT,
    valleylocation TEXT,
    counting bigINT,
    summing DOUBLE precision,
    meaning DOUBLE precision,
    stddeving DOUBLE precision,
    mining DOUBLE precision,
    maxing DOUBLE precision,
    area DOUBLE precision,
    geom geometry)
AS $$
DECLARE
   ownview TEXT := 'vw_buffer' || $1;
 BEGIN

   -- RAISE notice 'the view name is: %', ownview;

   RETURN query EXECUTE '
   SELECT b.house_id::INT, b.valleylocation,
          (ST_SummaryStats(ST_Clip(a.rast, 1, b.geom, TRUE))).*,
          b.area AS area,
          b.geom AS geom
   FROM alturas A
   JOIN ' || ownview || ' b
        ON st_intersects(a.rast, b.geom)';

  END;
$$
LANGUAGE plpgsql;

--- we create some materialized views

DROP MATERIALIZED VIEW IF EXISTS vw_heights_buffer4000 CASCADE;
CREATE materialized VIEW vw_heights_buffer4000 AS
SELECT * FROM heights_inbuffer(4000);

DROP MATERIALIZED VIEW IF EXISTS vw_heights_buffer8000 CASCADE;
CREATE materialized VIEW vw_heights_buffer8000 AS
SELECT * FROM heights_inbuffer(8000);

DROP MATERIALIZED VIEW IF EXISTS vw_heights_buffer11430 CASCADE;
CREATE materialized VIEW vw_heights_buffer11430 AS
SELECT * FROM heights_inbuffer(11430);


DROP MATERIALIZED VIEW IF EXISTS vw_heights_buffer12000 CASCADE;
CREATE materialized VIEW vw_heights_buffer12000 AS
SELECT * FROM heights_inbuffer(12000);

DROP MATERIALIZED VIEW IF EXISTS vw_heights_buffer13380 CASCADE;
CREATE materialized VIEW vw_heights_buffer13380 AS
SELECT * FROM heights_inbuffer(13380);

DROP MATERIALIZED VIEW IF EXISTS vw_heights_buffer16000 CASCADE;
CREATE materialized VIEW vw_heights_buffer16000 AS
SELECT * FROM heights_inbuffer(16000);

DROP MATERIALIZED VIEW IF EXISTS vw_heights_buffer24000 CASCADE;
CREATE materialized VIEW vw_heights_buffer24000 AS
SELECT * FROM heights_inbuffer(24000);

---
--- creamos una tabla general
---
DROP VIEW IF EXISTS vw_heights_summary;
CREATE VIEW vw_heights_summary AS
SELECT a.house_id, a.geom,
       round(a.meaning::numeric, 1) AS heightbuffer4000,
       round(b.meaning::numeric, 1) AS heightbuffer8000,
       round(c.meaning::numeric, 1) AS heightbuffer11430,
       round(d.meaning::numeric, 1) AS heightbuffer12000,
       round(e.meaning::numeric, 1) AS heightbuffer13380,
       round(f.meaning::numeric, 1) AS heightbuffer16000,
       round(g.meaning::numeric, 1) AS heightbuffer24000
FROM vw_heights_buffer4000 a
JOIN vw_heights_buffer8000 b USING (house_id)
JOIN vw_heights_buffer11430 c USING (house_id)
JOIN vw_heights_buffer12000 d USING (house_id)
JOIN vw_heights_buffer13380 e USING (house_id)
JOIN vw_heights_buffer16000 f USING (house_id)
JOIN vw_heights_buffer24000 g USING (house_id);
