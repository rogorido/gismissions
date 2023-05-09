---
--- We create hexagons (5000ms) for the Cagayan valley
---

DROP VIEW IF EXISTS hexagons_cagayan CASCADE;
CREATE VIEW hexagons_cagayan AS
--- we create the hexes
WITH hexes AS (
 SELECT ST_SETSRID(geom, 3123) AS geom
 FROM ST_HEXAGONGRID(5000,
         (SELECT ST_EXTENT(wkb_geometry)
          FROM valleys_polygons WHERE nombre = 'cagayan_big'))),

--- we clipped with the extent of the valley
hexesclipped AS
(
  SELECT ST_INTERSECTION(a.geom, b.wkb_geometry) AS geom
  FROM hexes a
  JOIN valleys_polygons b ON ST_INTERSECTS(a.geom, b.wkb_geometry)
  WHERE nombre = 'cagayan_big')

--- we generate IDs for QGIS
SELECT ROW_NUMBER() OVER() AS ogc_fid,
       geom
FROM hexesclipped;

---
--- We create hexagons (5000ms) for the plain
---

DROP VIEW IF EXISTS hexagons_plain CASCADE;
CREATE VIEW hexagons_plain AS
--- we create the hexes
WITH hexes AS (
 SELECT ST_SETSRID(geom, 3123) AS geom
 FROM ST_HEXAGONGRID(5000,
         (SELECT ST_EXTENT(wkb_geometry)
          FROM valleys_polygons WHERE nombre = 'plain'))),

--- we clipped with the extent of the valley
hexesclipped AS
(
  SELECT ST_INTERSECTION(a.geom, b.wkb_geometry) AS geom
  FROM hexes a
  JOIN valleys_polygons b ON ST_INTERSECTS(a.geom, b.wkb_geometry)
  WHERE nombre = 'plain')

--- we generate IDs for QGIS
SELECT ROW_NUMBER() OVER() AS ogc_fid,
       geom
FROM hexesclipped;

---
--- View hexagons_cagayan_raining
---

DROP MATERIALIZED VIEW IF EXISTS hexagons_cagayan_raining CASCADE;
CREATE MATERIALIZED VIEW hexagons_cagayan_raining AS
SELECT ogc_fid,
       (ST_SummaryStats(ST_Clip(a.rast, 1, b.geom, TRUE))).*,
       b.geom AS geom
FROM raining A
JOIN hexagons_cagayan b
     ON st_intersects(a.rast, b.geom);

---
--- View hexagons_plain_raining
---

DROP MATERIALIZED VIEW IF EXISTS hexagons_plain_raining CASCADE;
CREATE MATERIALIZED VIEW hexagons_plain_raining AS
SELECT ogc_fid,
       (ST_SummaryStats(ST_Clip(a.rast, 1, b.geom, TRUE))).*,
       b.geom AS geom
FROM raining A
JOIN hexagons_plain b
     ON st_intersects(a.rast, b.geom);
