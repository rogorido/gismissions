---
--- Function rain_inbuffer
---
--- Calculates the rain data in a buffer taking only mountains 750
---

DROP FUNCTION IF EXISTS rain_inbuffer CASCADE;
CREATE OR REPLACE FUNCTION rain_inbuffer (buffer int)
    RETURNS TABLE (
    house_id INT,
    house_name VARCHAR,
    valleylocation text,
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
   ownview TEXT := 'vw_buffer' || $1 || '_montanas750';
 BEGIN

   --RAISE notice 'the view name is: %', ownview;

   RETURN query EXECUTE '
   SELECT b.house_id::INT, b.house_name, b.valleylocation,
          (ST_SummaryStats(ST_Clip(a.rast, 1, b.geom, TRUE))).*,
          b.area AS area,
          b.geom AS geom
   FROM raining A
   JOIN ' || ownview || ' b
        ON st_intersects(a.rast, b.geom)';

  END;
$$
LANGUAGE plpgsql;


-- SELECT * FROM rain_inbuffer(4000);
