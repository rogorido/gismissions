
---
--- Function: rain_inbuffer_permonth
---
--- only in buffers with mountains750

DROP FUNCTION IF EXISTS rain_inbuffer_permonth CASCADE;
CREATE OR REPLACE FUNCTION rain_inbuffer_permonth (buffer INT, monthcode varchar)
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
   bufferview TEXT := 'vw_buffer' || $1 || '_montanas750';
   monthview TEXT := 'rain_month' || $2;
 BEGIN

   --RAISE notice 'the view name is: %', ownview;

   RETURN query EXECUTE '
   SELECT b.house_id::INT, b.house_name, b.valleylocation,
          (ST_SummaryStats(ST_Clip(a.rast, 1, b.geom, TRUE))).*,
          b.area AS area,
          b.geom AS geom
   FROM ' || monthview || ' A
   JOIN ' || bufferview || ' b
        ON st_intersects(a.rast, b.geom)';

  END;
$$
LANGUAGE plpgsql;

-- DROP VIEW IF EXISTS vw_buffer12000_prec01 CASCADE;
-- CREATE VIEW vw_buffer12000_prec01 AS
-- SELECT * FROM rain_inbuffer_permonth(4000, '01');;


--
-- Format long for analysis with R
--

DROP VIEW IF EXISTS vw_buffer8000_rain_month_summary;
CREATE VIEW vw_buffer8000_rain_month_summary AS
SELECT house_id, house_name, valleylocation, meaning, '01' AS mes
FROM rain_inbuffer_permonth(8000, '01')
UNION
SELECT house_id, house_name, valleylocation, meaning, '02' AS mes
FROM rain_inbuffer_permonth(8000, '02')
UNION
SELECT house_id, house_name, valleylocation, meaning, '03' AS mes
FROM rain_inbuffer_permonth(8000, '03')
UNION 
SELECT house_id, house_name, valleylocation, meaning, '04' AS mes
FROM rain_inbuffer_permonth(8000, '04')
UNION
SELECT house_id, house_name, valleylocation, meaning, '05' AS mes
FROM rain_inbuffer_permonth(8000, '05')
UNION
SELECT house_id, house_name, valleylocation, meaning, '06' AS mes
FROM rain_inbuffer_permonth(8000, '06')
UNION
SELECT house_id, house_name, valleylocation, meaning, '07' AS mes
FROM rain_inbuffer_permonth(8000, '07')
UNION
SELECT house_id, house_name, valleylocation, meaning, '08' AS mes
FROM rain_inbuffer_permonth(8000, '08')
UNION
SELECT house_id, house_name, valleylocation, meaning, '09' AS mes
FROM rain_inbuffer_permonth(8000, '09')
UNION
SELECT house_id, house_name, valleylocation, meaning, '10' AS mes
FROM rain_inbuffer_permonth(8000, '10')
UNION
SELECT house_id, house_name, valleylocation, meaning, '11' AS mes
FROM rain_inbuffer_permonth(8000, '11')
UNION
SELECT house_id, house_name, valleylocation, meaning, '12' AS mes
FROM rain_inbuffer_permonth(8000, '12');
