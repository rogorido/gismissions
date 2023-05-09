-- tengo q coger los buffers recortados pq si no lo del área sale mal.
-- El asunto es q de todas formas no merece la pena coger cada buffer
-- con lo de la montañas pq tp debe de haber tanta diferencia. Por eso
-- cojo solo el de montanas750 q es el q menos quita.

--- NOTE: using vw_buffer4000_montanas750 I only get cagayan!

--- FUNCTION: waterways_length_inbuffer
--- we create a function which calculates for a given buffer in ms
--- the length of waterways, differentiating between rivers and streams

DROP FUNCTION IF EXISTS waterways_length_inbuffer CASCADE;
CREATE OR REPLACE FUNCTION waterways_length_inbuffer (buffer int)
    RETURNS TABLE (
    house_id INT,
    house_name VARCHAR,
    valleylocation text,
    bufferarea NUMERIC,
    housebuffer geometry,
    total numeric,
    waterindex numeric,
    streamtotal numeric,
    rivertotal numeric,
    streamperc numeric,
    riverperc numeric)
AS $$
DECLARE
   ownview TEXT := 'vw_buffer' || $1 || '_montanas750';
 BEGIN

   --RAISE notice 'the view name is: %', ownview;

   RETURN query EXECUTE 'WITH j AS
     (SELECT b.house_id, b.house_name, b.valleylocation,
             b.area AS bufferarea, b.geom AS housebuffer,
             r.ogc_fid, r.fid, r.fclass,
       (st_dump(st_intersection(wkb_geometry, b.geom))).geom AS geom
     FROM rios r
     JOIN ' || ownview || ' b
         ON st_intersects(b.geom, r.wkb_geometry )),
     calculations as
     (SELECT house_id::int, house_name, valleylocation, bufferarea, housebuffer,
       SUM(st_length(geom)) AS total,
       SUM(st_length(geom)) FILTER (WHERE fclass = ''stream'') AS streamtotal,
       SUM(st_length(geom)) FILTER (WHERE fclass = ''river'') AS rivertotal
     FROM j
    GROUP BY 1, 2, 3, 4, 5)
    SELECT c.house_id, c.house_name, c.valleylocation,
           round(c.bufferarea::decimal, 2) as bufferarea,
           c.housebuffer,
           round(c.total::decimal, 2) as total,
           round(c.total::decimal / c.bufferarea::decimal, 3) as waterindex,
           round(c.streamtotal::decimal, 2) as streamtotal,
           round(c.rivertotal::decimal, 2) as rivertotal,
           round(((streamtotal * 100) / total)::decimal, 2) as streamperc,
           round(((rivertotal * 100) / total)::decimal, 2) as riverperc
    FROM calculations c';

  END;
$$
LANGUAGE plpgsql;

---
--- we create some materialized views to speed things up
---
DROP MATERIALIZED VIEW IF EXISTS vw_buffer4000_waterways CASCADE;
CREATE materialized VIEW vw_buffer4000_waterways AS
SELECT * FROM waterways_length_inbuffer(4000);

DROP MATERIALIZED VIEW IF EXISTS vw_buffer8000_waterways CASCADE;
CREATE materialized VIEW vw_buffer8000_waterways AS
SELECT * FROM waterways_length_inbuffer(8000);

DROP MATERIALIZED VIEW IF EXISTS vw_buffer11430_waterways CASCADE;
CREATE materialized VIEW vw_buffer11430_waterways AS
SELECT * FROM waterways_length_inbuffer(11430);

DROP MATERIALIZED VIEW IF EXISTS vw_buffer12000_waterways CASCADE;
CREATE materialized VIEW vw_buffer12000_waterways AS
SELECT * FROM waterways_length_inbuffer(12000);

DROP MATERIALIZED VIEW IF EXISTS vw_buffer13380_waterways CASCADE;
CREATE materialized VIEW vw_buffer13380_waterways AS
SELECT * FROM waterways_length_inbuffer(13380);

DROP MATERIALIZED VIEW IF EXISTS vw_buffer16000_waterways CASCADE;
CREATE materialized VIEW vw_buffer16000_waterways AS
SELECT * FROM waterways_length_inbuffer(16000);

DROP MATERIALIZED VIEW IF EXISTS vw_buffer24000_waterways CASCADE;
CREATE materialized VIEW vw_buffer24000_waterways AS
SELECT * FROM waterways_length_inbuffer(24000);

---
--- General view summarizing all data
---
DROP MATERIALIZED VIEW IF EXISTS buffers_waterways_summary;
CREATE MATERIALIZED VIEW buffers_waterways_summary AS
SELECT a.house_id, a.house_name, a.housebuffer AS geom,
       round(a.waterindex::numeric, 3) AS buffer4000,
       round(b.waterindex::numeric, 3) AS buffer8000,
       round(c.waterindex::numeric, 3) AS buffer11430,
       round(d.waterindex::numeric, 3) AS buffer12000,
       round(e.waterindex::numeric, 3) AS buffer13380,
       round(f.waterindex::numeric, 3) AS buffer16000,
       round(g.waterindex::numeric, 3) AS buffer24000
FROM vw_buffer4000_waterways a
JOIN vw_buffer8000_waterways b USING (house_id)
JOIN vw_buffer11430_waterways c USING (house_id)
JOIN vw_buffer12000_waterways d USING (house_id)
JOIN vw_buffer13380_waterways e USING (house_id)
JOIN vw_buffer16000_waterways f USING (house_id)
JOIN vw_buffer24000_waterways g USING (house_id);
