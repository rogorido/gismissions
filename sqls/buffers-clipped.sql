--- Creamos los buffers clippeados con montañas y costa

--- no me he apuntado por qué hago este lío!

DROP FUNCTION IF EXISTS buffer_house_mountains CASCADE;
CREATE OR REPLACE FUNCTION buffer_house_mountains (buffer INT, mountains int)
    RETURNS TABLE (
    house_id INT,
    house_name VARCHAR,
    valleylocation TEXT,
    geom geometry,
    area DOUBLE PRECISION)
AS $$
DECLARE
    bufferview TEXT := 'vw_buffer' || $1;
 BEGIN

   RETURN query EXECUTE format('
   WITH clipped AS
    (SELECT house_id, house_name, valleylocation,
            ST_INTERSECTION(a.geom, st_union(b.wkb_geometry)) AS geom
     FROM (SELECT house_id, house_name, valleylocation,
                  COALESCE(ST_Difference(geom, (SELECT ST_union(geom)
                                            FROM vw_mountains WHERE height = %s))) AS geom
       FROM %s) AS A
     JOIN luzon b ON st_intersects(a.geom, b.wkb_geometry)
     GROUP BY a.house_id, a.house_name, a.valleylocation, a.geom)
    SELECT a.*, st_area(a.geom) / 1000000 AS area
    FROM clipped A;', mountains, bufferview);

  END;
$$
LANGUAGE plpgsql;

---
--- we create materialized views
---

DROP MATERIALIZED VIEW IF EXISTS vw_buffer4000_montanas750 CASCADE;
CREATE materialized VIEW vw_buffer4000_montanas750 AS
SELECT * FROM buffer_house_mountains(4000, 750);

DROP MATERIALIZED VIEW IF EXISTS vw_buffer4000_montanas1000 CASCADE;
CREATE materialized VIEW vw_buffer4000_montanas1000 AS
SELECT * FROM buffer_house_mountains(4000, 1000);

DROP MATERIALIZED VIEW IF EXISTS vw_buffer4000_montanas1250 CASCADE;
CREATE materialized VIEW vw_buffer4000_montanas1250 AS
SELECT * FROM buffer_house_mountains(4000, 1250);

-- ahora con los de 8000

DROP MATERIALIZED VIEW IF EXISTS vw_buffer8000_montanas750 CASCADE;
CREATE materialized VIEW vw_buffer8000_montanas750 AS
SELECT * FROM buffer_house_mountains(8000, 750);

DROP MATERIALIZED VIEW IF EXISTS vw_buffer8000_montanas1000 CASCADE;
CREATE materialized VIEW vw_buffer8000_montanas1000 AS
SELECT * FROM buffer_house_mountains(8000, 1000);

DROP MATERIALIZED VIEW IF EXISTS vw_buffer8000_montanas1250 CASCADE;
CREATE materialized VIEW vw_buffer8000_montanas1250 AS
SELECT * FROM buffer_house_mountains(8000, 1250);

-- ahora con los de 11430

DROP MATERIALIZED VIEW IF EXISTS vw_buffer11430_montanas750 CASCADE;
CREATE materialized VIEW vw_buffer11430_montanas750 AS
SELECT * FROM buffer_house_mountains(11430, 750);

DROP MATERIALIZED VIEW IF EXISTS vw_buffer11430_montanas1000 CASCADE;
CREATE materialized VIEW vw_buffer11430_montanas1000 AS
SELECT * FROM buffer_house_mountains(11430, 1000);

DROP MATERIALIZED VIEW IF EXISTS vw_buffer11430_montanas1250 CASCADE;
CREATE materialized VIEW vw_buffer11430_montanas1250 AS
SELECT * FROM buffer_house_mountains(11430, 1250);

-- ahora con los de 12000

DROP MATERIALIZED VIEW IF EXISTS vw_buffer12000_montanas750 CASCADE;
CREATE materialized VIEW vw_buffer12000_montanas750 AS
SELECT * FROM buffer_house_mountains(12000, 750);

DROP MATERIALIZED VIEW IF EXISTS vw_buffer12000_montanas1000 CASCADE;
CREATE materialized VIEW vw_buffer12000_montanas1000 AS
SELECT * FROM buffer_house_mountains(12000, 1000);

DROP MATERIALIZED VIEW IF EXISTS vw_buffer12000_montanas1250 CASCADE;
CREATE materialized VIEW vw_buffer12000_montanas1250 AS
SELECT * FROM buffer_house_mountains(12000, 1250);

-- ahora con los de 13380

DROP MATERIALIZED VIEW IF EXISTS vw_buffer13380_montanas750 CASCADE;
CREATE materialized VIEW vw_buffer13380_montanas750 AS
SELECT * FROM buffer_house_mountains(13380, 750);

DROP MATERIALIZED VIEW IF EXISTS vw_buffer13380_montanas1000 CASCADE;
CREATE materialized VIEW vw_buffer13380_montanas1000 AS
SELECT * FROM buffer_house_mountains(13380, 1000);

DROP MATERIALIZED VIEW IF EXISTS vw_buffer13380_montanas1250 CASCADE;
CREATE materialized VIEW vw_buffer13380_montanas1250 AS
SELECT * FROM buffer_house_mountains(13380, 1250);

-- ahora con los de 16000

DROP MATERIALIZED VIEW IF EXISTS vw_buffer16000_montanas750 CASCADE;
CREATE materialized VIEW vw_buffer16000_montanas750 AS
SELECT * FROM buffer_house_mountains(16000, 750);

DROP MATERIALIZED VIEW IF EXISTS vw_buffer16000_montanas1000 CASCADE;
CREATE materialized VIEW vw_buffer16000_montanas1000 AS
SELECT * FROM buffer_house_mountains(16000, 1000);

DROP MATERIALIZED VIEW IF EXISTS vw_buffer16000_montanas1250 CASCADE;
CREATE materialized VIEW vw_buffer16000_montanas1250 AS
SELECT * FROM buffer_house_mountains(16000, 1250);

-- ahora con los de 24000

DROP MATERIALIZED VIEW IF EXISTS vw_buffer24000_montanas750 CASCADE;
CREATE materialized VIEW vw_buffer24000_montanas750 AS
SELECT * FROM buffer_house_mountains(24000, 750);

DROP MATERIALIZED VIEW IF EXISTS vw_buffer24000_montanas1000 CASCADE;
CREATE materialized VIEW vw_buffer24000_montanas1000 AS
SELECT * FROM buffer_house_mountains(24000, 1000);

DROP MATERIALIZED VIEW IF EXISTS vw_buffer24000_montanas1250 CASCADE;
CREATE materialized VIEW vw_buffer24000_montanas1250 AS
SELECT * FROM buffer_house_mountains(24000, 1250);
