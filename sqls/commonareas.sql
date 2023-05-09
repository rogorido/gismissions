--
-- Atención: lo hago solo con montanas750 pq tp tiene mucho sentido
-- hacerlo con las otras.

-- para la explicación del SQL ver en analisis.org

DROP FUNCTION IF EXISTS common_area_table CASCADE;
CREATE OR REPLACE FUNCTION common_area_table (buffer int)
    RETURNS TABLE (
    house_id INT,
    house_name VARCHAR,
    valleytype TEXT, -- cagayan/plain
    initialarea DOUBLE PRECISION,
    commonarea_total DOUBLE PRECISION,
    commonarea_perc DOUBLE PRECISION)
AS $$
DECLARE
    ownview TEXT := 'vw_buffer' || $1 || '_montanas750';
 BEGIN

   RETURN query EXECUTE format('
   WITH comun AS
    (select a.house_id AS house_id1, a.house_name AS house_name1, a.valleylocation,
            b.house_id AS house_id2, b.house_name AS house_name2,
            ST_INTERSECTION(a.geom, b.geom) commonarea
      FROM %s A
      JOIN %s b ON a.house_id <> b.house_id
      WHERE ST_OVERLAPS(a.geom, b.geom)),
    unido AS
    (SELECT house_id1 AS house_id, house_name1 AS house_name, valleylocation,
            st_union(commonarea) AS commonarea_union
      FROM comun GROUP BY 1, 2, 3)
    SELECT a.house_id::int, a.house_name, a.valleylocation,
       st_area(b.geom) / 1000000 AS areainicial,
       st_area(a.commonarea_union) / 1000000 AS commonarea_total,
       st_area(a.commonarea_union) / st_area(b.geom) AS commonarea_perc
    FROM unido A
    JOIN %s b ON a.house_id = b.house_id', ownview, ownview, ownview);

  END;
$$
LANGUAGE plpgsql;

---
--- Esto son las tablas, luego viene los datos gis para QGIS
--- 

--- SELECT * FROM common_area_table(4000);


---
--- Esto son los datos gis para QGIS
--- 

-- DROP VIEW IF EXISTS vw_buffer4000_areacomun_gis;
-- CREATE  VIEW vw_buffer4000_areacomun_gis AS
-- WITH comun AS
--     (select a.house_id AS id1, a.house_name AS house_name1,
--             b.house_id AS id2, b.house_name AS house_name2,
--             ST_INTERSECTION(a.geom, b.geom) areacomun
--     from vw_buffer4000_montanas750 a
--     JOIN vw_buffer4000_montanas750 b ON a.house_id <> b.house_id
--     WHERE ST_Overlaps(a.geom, b.geom))
-- SELECT id1 AS id, house_name1 AS house_name,
--        st_union(areacomun) AS areacomununida
-- FROM comun
-- GROUP BY id1, house_name1;
