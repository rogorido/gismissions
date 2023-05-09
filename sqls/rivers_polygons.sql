---
--- (see explanations in 4e16ebae-1d0b-41ec-b247-90b9656f8818 in analisis.org)

---
--- We create a line with the river Cagayan
---
DROP VIEW IF EXISTS river_cagayan_line cascade;
CREATE VIEW river_cagayan_line AS
WITH cte1 AS
(SELECT * FROM rios
WHERE name = 'Cagayan River' and osm_id not in ('206136459', '82161414', '82198670'))
SELECT 1 AS ogc_fid, st_linemerge(st_collect(wkb_geometry)) AS geom
FROM cte1;

-- DROP VIEW IF EXISTS river_cagayan_line cascade;
-- CREATE VIEW river_cagayan_line AS
-- SELECT * FROM rios
-- WHERE name = 'Cagayan River';

---
--- We create a polygon with the river Cagayan
---

DROP VIEW IF EXISTS river_cagayan_polygon CASCADE;
CREATE VIEW river_cagayan_polygon AS
SELECT * FROM rivers_polygons
WHERE name = 'Cagayan River';

---
--- We create points on the line and add also the "direction" using st_azimuth
--- taking the present and the next point
---
--- https://gis.stackexchange.com/questions/338037/obtain-best-fit-bearing-for-sequence-of-points)

DROP VIEW IF EXISTS points_on_cagayan_river cascade;
CREATE VIEW points_on_cagayan_river AS
WITH cte1 AS
(SELECT (st_dumppoints(ST_LineInterpolatePoints(geom, 0.001))).geom AS geom
FROM river_cagayan_line),
cte2 AS
(SELECT ROW_NUMBER() OVER() AS ogc_fid,
       geom FROM cte1)
SELECT ogc_fid, geom,
       degrees(ST_Azimuth(geom, LEAD(geom) OVER(ORDER BY ogc_fid))) AS azm
from cte2;

---
--- We create the lines
---

DROP VIEW IF EXISTS lines_on_cagayan_river;
CREATE VIEW lines_on_cagayan_river AS
SELECT ROW_NUMBER() OVER() AS ogc_fid,
       st_transform(st_makeline(
       st_project(st_transform(geom, 4326)::geography, 1000, radians(azm + 90))::geometry,
       st_project(st_transform(geom, 4326)::geography, 1000, radians(azm - 90))::geometry), 3123) AS geom
FROM points_on_cagayan_river;

---
--- We clip the lines
---

DROP MATERIALIZED VIEW IF EXISTS widths_cagayan_river;
CREATE MATERIALIZED VIEW widths_cagayan_river AS
SELECT ROW_NUMBER() OVER() AS ogc_fid,
       st_intersection(a.geom, b.geom) AS geom
FROM lines_on_cagayan_river A
JOIN river_cagayan_polygon b ON st_intersects(a.geom, b.geom);

CREATE INDEX widths_cagayan_river_geom_idx ON widths_cagayan_river USING gist(geom);

-- ---
-- --- we drop some of the views that we do not need any more
-- ---
-- DROP VIEW IF EXISTS lines_on_cagayan_river;
-- DROP VIEW IF EXISTS points_on_cagayan_river;

---
--- we get the avg widths of the river cagayan in buffers12000kms around the
--- houses
---

DROP VIEW IF EXISTS avgwidths_cagayan_river_buffer12000 cascade;
CREATE VIEW avgwidths_cagayan_river_buffer12000 AS
WITH cte1 AS
  (SELECT A.*, b.house_id
  FROM widths_cagayan_river a
  JOIN vw_buffer12000_montanas750 b ON st_contains(b.geom, a.geom))
SELECT a.house_id, b.casa, b.wkb_geometry, AVG(st_length(a.geom)) AS avglength
FROM cte1 A
JOIN all_houses b USING (house_id)
GROUP BY 1, 2, 3;

----
---- Watersheds: discharges of rivers around houses
----
DROP VIEW IF EXISTS rivers_discharges_buffer12000 cascade;
CREATE VIEW rivers_discharges_buffer12000 AS
WITH cte1 AS
  (SELECT A.*, b.house_id
  FROM luzon_rivers_hydrosheds a
  JOIN vw_buffer12000_montanas750 b ON st_contains(b.geom, a.geom))
SELECT ROW_NUMBER() OVER() AS ogc_fid,
       a.house_id, b.casa, dis_av_cms,
       a.ord_stra, a.ord_clas, a.ord_flow,
       a.geom
FROM cte1 A
JOIN all_houses b USING (house_id);
