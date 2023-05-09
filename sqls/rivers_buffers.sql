---
--- In cagayan valley we want to split the buffers by the river
--- because it is assumed that missionaries did not cross the river regularly
---

---
--- We need to know whether the polygon contains the house: this is a small trick
--- to get the right polygon!
---

CREATE OR REPLACE FUNCTION fn_buffer_contains_house (house_id INT, geom geometry)
    RETURNS BOOLEAN
AS $BODY$
SELECT ST_CONTAINS($2,
       (SELECT wkb_geometry FROM all_houses WHERE house_id = $1));
$BODY$
LANGUAGE SQL;

---
--- We divide the polygons by the Cagayan river
--- and calculate the area of th polygons
---
---
--- We have to st_union river_cagayan_line: otherwise some segments
--- do not split the polygon and I do not get the desired results...
---
--- We should create a function for not repeating code!
---
--- We only usee montanas750

DROP VIEW IF EXISTS vw_buffer4000_reduced_bycagayan_river CASCADE;
CREATE VIEW vw_buffer4000_reduced_bycagayan_river AS
--- we select  only buffers in the cagayan valley
WITH cte1 AS
  (SELECT *
  FROM vw_buffer4000_montanas750
  WHERE st_intersects(geom, (SELECT wkb_geometry
        fROM valleys_polygons WHERE nombre='cagayan_big'))),

---- we split the buffers by the st_union of cagayan_river_line
cte2 AS
(SELECT house_id,
        (st_dump(st_collectionextract(st_split(a.geom, b.geom)))).geom AS geom
FROM cte1 A
JOIN (SELECT st_union(geom) AS geom FROM river_cagayan_line) b
     ON st_intersects(a.geom, b.geom))

--- we create the main
SELECT row_number() OVER() AS ogc_fid,
       a.house_id, b.casa AS housename, geom,
       fn_buffer_contains_house(a.house_id, geom) AS polygon_to_evangelize,
       st_area(geom) AS bufferarea
FROM cte2 A
JOIN all_houses b USING (house_id);


---
--- idem for 8000
---
DROP VIEW IF EXISTS vw_buffer8000_reduced_bycagayan_river CASCADE;
CREATE VIEW vw_buffer8000_reduced_bycagayan_river AS
--- we select  only buffers in the cagayan valley
WITH cte1 AS
  (SELECT *
  FROM vw_buffer8000_montanas750
  WHERE st_intersects(geom, (SELECT wkb_geometry
        fROM valleys_polygons WHERE nombre='cagayan_big'))),

---- we split the buffers by the st_union of cagayan_river_line
cte2 AS
(SELECT house_id,
        (st_dump(st_collectionextract(st_split(a.geom, b.geom)))).geom AS geom
FROM cte1 A
JOIN (SELECT st_union(geom) AS geom FROM river_cagayan_line) b
     ON st_intersects(a.geom, b.geom))

--- we create the main
SELECT row_number() OVER() AS ogc_fid,
       a.house_id, b.casa AS housename, geom,
       fn_buffer_contains_house(a.house_id, geom) AS polygon_to_evangelize,
       st_area(geom) AS bufferarea
FROM cte2 A
JOIN all_houses b USING (house_id);

---
--- idem for 12000
---
DROP VIEW IF EXISTS vw_buffer12000_reduced_bycagayan_river CASCADE;
CREATE VIEW vw_buffer12000_reduced_bycagayan_river AS
--- we select  only buffers in the cagayan valley
WITH cte1 AS
  (SELECT *
  FROM vw_buffer12000_montanas750
  WHERE st_intersects(geom, (SELECT wkb_geometry
        fROM valleys_polygons WHERE nombre='cagayan_big'))),

---- we split the buffers by the st_union of cagayan_river_line
cte2 AS
(SELECT house_id,
        (st_dump(st_collectionextract(st_split(a.geom, b.geom)))).geom AS geom
FROM cte1 A
JOIN (SELECT st_union(geom) AS geom FROM river_cagayan_line) b
     ON st_intersects(a.geom, b.geom))

--- we create the main
SELECT row_number() OVER() AS ogc_fid,
       a.house_id, b.casa AS housename, geom,
       fn_buffer_contains_house(a.house_id, geom) AS polygon_to_evangelize,
       st_area(geom) AS bufferarea
FROM cte2 A
JOIN all_houses b USING (house_id);

---
--- idem for 13380
---
DROP VIEW IF EXISTS vw_buffer13380_reduced_bycagayan_river CASCADE;
CREATE VIEW vw_buffer13380_reduced_bycagayan_river AS
--- we select  only buffers in the cagayan valley
WITH cte1 AS
  (SELECT *
  FROM vw_buffer13380_montanas750
  WHERE st_intersects(geom, (SELECT wkb_geometry
        fROM valleys_polygons WHERE nombre='cagayan_big'))),

---- we split the buffers by the st_union of cagayan_river_line
cte2 AS
(SELECT house_id,
        (st_dump(st_collectionextract(st_split(a.geom, b.geom)))).geom AS geom
FROM cte1 A
JOIN (SELECT st_union(geom) AS geom FROM river_cagayan_line) b
     ON st_intersects(a.geom, b.geom))

--- we create the main
SELECT row_number() OVER() AS ogc_fid,
       a.house_id, b.casa AS housename, geom,
       fn_buffer_contains_house(a.house_id, geom) AS polygon_to_evangelize,
       st_area(geom) AS bufferarea
FROM cte2 A
JOIN all_houses b USING (house_id);

---
--- idem for 16000
---
DROP VIEW IF EXISTS vw_buffer16000_reduced_bycagayan_river CASCADE;
CREATE VIEW vw_buffer16000_reduced_bycagayan_river AS
--- we select  only buffers in the cagayan valley
WITH cte1 AS
  (SELECT *
  FROM vw_buffer16000_montanas750
  WHERE st_intersects(geom, (SELECT wkb_geometry
        fROM valleys_polygons WHERE nombre='cagayan_big'))),

---- we split the buffers by the st_union of cagayan_river_line
cte2 AS
(SELECT house_id,
        (st_dump(st_collectionextract(st_split(a.geom, b.geom)))).geom AS geom
FROM cte1 A
JOIN (SELECT st_union(geom) AS geom FROM river_cagayan_line) b
     ON st_intersects(a.geom, b.geom))

--- we create the main
SELECT row_number() OVER() AS ogc_fid,
       a.house_id, b.casa AS housename, geom,
       fn_buffer_contains_house(a.house_id, geom) AS polygon_to_evangelize,
       st_area(geom) AS bufferarea
FROM cte2 A
JOIN all_houses b USING (house_id);
---
--- idem for 24000
---
DROP VIEW IF EXISTS vw_buffer24000_reduced_bycagayan_river CASCADE;
CREATE VIEW vw_buffer24000_reduced_bycagayan_river AS
--- we select  only buffers in the cagayan valley
WITH cte1 AS
  (SELECT *
  FROM vw_buffer24000_montanas750
  WHERE st_intersects(geom, (SELECT wkb_geometry
        fROM valleys_polygons WHERE nombre='cagayan_big'))),

---- we split the buffers by the st_union of cagayan_river_line
cte2 AS
(SELECT house_id,
        (st_dump(st_collectionextract(st_split(a.geom, b.geom)))).geom AS geom
FROM cte1 A
JOIN (SELECT st_union(geom) AS geom FROM river_cagayan_line) b
     ON st_intersects(a.geom, b.geom))

--- we create the main
SELECT row_number() OVER() AS ogc_fid,
       a.house_id, b.casa AS housename, geom,
       fn_buffer_contains_house(a.house_id, geom) AS polygon_to_evangelize,
       st_area(geom) AS bufferarea
FROM cte2 A
JOIN all_houses b USING (house_id);
---

DROP VIEW IF EXISTS vw_buffers_reduced_bycagayan_river CASCADE;
CREATE VIEW vw_buffers_reduced_bycagayan_river AS
SELECT 'buffer4000' as buffersize, st_area(st_union(geom)) / 1000000 AS total
FROM vw_buffer4000_reduced_bycagayan_river
WHERE polygon_to_evangelize = FALSE
union all
SELECT 'buffer8000' as buffersize, st_area(st_union(geom)) / 1000000 AS total
FROM vw_buffer8000_reduced_bycagayan_river
WHERE polygon_to_evangelize = FALSE
union all
SELECT 'buffer12000' as buffersize, st_area(st_union(geom)) / 1000000 total
FROM vw_buffer12000_reduced_bycagayan_river
WHERE polygon_to_evangelize = FALSE
union all
SELECT 'buffer13380' as buffersize, st_area(st_union(geom)) / 1000000 AS total
FROM vw_buffer13380_reduced_bycagayan_river
WHERE polygon_to_evangelize = FALSE
union all
SELECT 'buffer16000' as buffersize, st_area(st_union(geom)) / 1000000 AS total
FROM vw_buffer16000_reduced_bycagayan_river
WHERE polygon_to_evangelize = FALSE
UNION all
SELECT 'buffer24000' as buffersize, st_area(st_union(geom)) / 1000000 AS total
FROM vw_buffer24000_reduced_bycagayan_river
WHERE polygon_to_evangelize = FALSE;
