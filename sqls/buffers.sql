-- seleccionamos solo las casas de cagayán
-- Tengo realmente dos polígonos por eso es necesario el WHERE
--
-- Appointments comes form misonando_casas and gives only the number of
-- people who were appointed, but without dates, rank, etc.
--

DROP MATERIALIZED VIEW IF EXISTS all_houses CASCADE;
CREATE MATERIALIZED VIEW all_houses AS
SELECT A.*,
       CASE
        WHEN (SELECT wkb_geometry FROM valleys_polygons WHERE nombre = 'cagayan_big') &&  a.wkb_geometry THEN 'cagayan'
        WHEN (SELECT wkb_geometry FROM valleys_polygons WHERE nombre = 'plain') &&  a.wkb_geometry THEN 'plain'
        ELSE 'no_valley'
       END AS valleylocation,
      st_value(rast, wkb_geometry) AS height,
      c.total AS appointments
FROM casas A
JOIN alturas b ON st_intersects(b.rast, a.wkb_geometry)
JOIN (SELECT casaid, COUNT(*) AS total  FROM misionando_casas GROUP BY 1) C
      ON c.casaid = a.house_id;

---
--- At which height are the houses located?
---

DROP VIEW IF EXISTS all_houses_heights;
CREATE VIEW all_houses_heights AS
SELECT house_id, lugar, height, valleylocation
FROM all_houses
ORDER BY valleylocation;

---
--- we define a function to create buffers around
---
DROP FUNCTION IF EXISTS buffers_house CASCADE;
CREATE OR REPLACE FUNCTION buffers_house (buffer int)
    RETURNS TABLE (
    house_id INT,
    house_name VARCHAR,
    valleylocation text,
    geom geometry,
    area DOUBLE precision)
AS $BODY$
DECLARE
 BEGIN

   RETURN query EXECUTE format('
   SELECT a.house_id::int, a.casa, valleylocation,
       st_buffer(a.wkb_geometry, %s)::geometry(POLYGON, 3123) AS geom,
       st_area(st_buffer(a.wkb_geometry, %s)::geometry(POLYGON, 3123)) AS area
   FROM all_houses A', buffer, buffer);

  END;
$BODY$
LANGUAGE plpgsql STABLE;


---
--- We create a fucntion to calculate a circle including all houses of the two valleys
---
--- Some comments
--- 1. we have to st_collect luzon because there are polygons for each province and the join
--- creates several joins
--- 2. we create the areaclipped clipping by the coast
--- 3. but probably most important is the radius. I have the calculation from here
--- https://stackoverflow.com/questions/31501009/determining-the-radius-or-diameter-of-a-minimum-bounding-circle
--- and we adapt to 4326 for using st_distancespheroid()
--- 4. we remove the house 335 in case of plain bc is very far away...
---

DROP FUNCTION IF EXISTS circle_in_valley CASCADE;
CREATE OR REPLACE FUNCTION circle_in_valley (valley VARCHAR)
    RETURNS TABLE (
    ogc_fid bigint,
    valleylocation text,
    area DOUBLE PRECISION,
    areaclipped DOUBLE PRECISION,
    radius DECIMAL)

AS $BODY$
DECLARE
   removehouse TEXT := ''; -- is empty if valley is cagayan...

 BEGIN

  IF valley = 'plain' THEN
      removehouse := 'AND house_id != 335';
  END IF;

   RETURN query EXECUTE '
   WITH radio AS
    (SELECT valleylocation,
       ST_MinimumBoundingCircle(st_collect(wkb_geometry)) AS geom
     FROM all_houses
     WHERE valleylocation = ''' || valley || ''' ' || removehouse || '
     GROUP BY 1),
     luzonisland AS
      (SELECT st_collect(wkb_geometry) AS geom FROM luzon)
     SELECT ROW_NUMBER() OVER() AS ogc_fid, r.valleylocation,
       st_area(r.geom) / 1000000 AS area,
       st_area(st_intersection(r.geom, b.geom)) / 1000000 AS areaclipped,
       ROUND(
        ST_distancespheroid(
            ST_Centroid(st_transform(r.geom, 4326)),
            ST_PointN(ST_Boundary(st_transform(r.geom, 4326)), 1)
        )::DECIMAL / 1000, 2
       )  AS radius
      FROM radio r
      JOIN luzonisland b ON st_intersects(r.geom, b.geom)';

  END;
$BODY$
LANGUAGE plpgsql STABLE ROWS 1;

--- and then:
-- SELECT * FROM circle_in_valley('plain');
-- SELECT * FROM circle_in_valley('cagayan');


---
--- We create some views with specific distances
---
DROP VIEW IF EXISTS vw_buffer4000 CASCADE;
CREATE VIEW vw_buffer4000 AS 
SELECT * FROM buffers_house(4000);

DROP VIEW IF EXISTS vw_buffer8000 CASCADE;
CREATE VIEW vw_buffer8000 AS
SELECT * FROM buffers_house(8000);

DROP VIEW IF EXISTS vw_buffer11430 CASCADE;
CREATE VIEW vw_buffer11430 AS
SELECT * FROM buffers_house(11430);

DROP VIEW IF EXISTS vw_buffer12000 CASCADE;
CREATE VIEW vw_buffer12000 AS
SELECT * FROM buffers_house(12000);

DROP VIEW IF EXISTS vw_buffer13380 CASCADE;
CREATE VIEW vw_buffer13380 AS
SELECT * FROM buffers_house(13380);

DROP VIEW IF EXISTS vw_buffer16000 CASCADE;
CREATE VIEW vw_buffer16000 AS
SELECT * FROM buffers_house(16000);

DROP VIEW IF EXISTS vw_buffer24000 CASCADE;
CREATE VIEW vw_buffer24000 AS
SELECT * FROM buffers_house(24000);
