
DROP VIEW IF EXISTS houses_cagayan_distances;
CREATE VIEW houses_cagayan_distances AS
---
--- We calculate distances with ST_DISTANCESPHEROID() and have to transform to 4326
---
WITH calculate AS
(SELECT a.house_id AS house_id1, a.casa AS house_name1, a.wkb_geometry AS geom1,
       b.house_id AS house_id2, b.casa AS house_name2, b.wkb_geometry AS geom2,
       ST_DISTANCESPHEROID(st_transform(a.wkb_geometry, 4326), st_transform(b.wkb_geometry, 4326)) / 1000 AS dist
FROM all_houses A, all_houses b
WHERE a.valleylocation = 'cagayan' AND b.valleylocation = 'cagayan'
ORDER BY a.wkb_geometry <-> b.wkb_geometry)
---
--- We create a line between the houses
---
SELECT ROW_NUMBER() OVER() AS fid,
       house_id1, house_name1, house_id2, house_name2,
       st_makeline(geom1, geom2) AS linebetweenhouses,
       dist
FROM calculate;


---
--- Houses in the plain of Luzon
---
DROP VIEW IF EXISTS houses_plain_distances;
CREATE VIEW houses_plain_distances AS
---
--- We calculate distances with ST_DISTANCESPHEROID() and have to transform to 4326
---
WITH calculate AS
(SELECT a.house_id AS house_id1, a.casa AS house_name1, a.wkb_geometry AS geom1,
       b.house_id AS house_id2, b.casa AS house_name2, b.wkb_geometry AS geom2,
       ST_DISTANCESPHEROID(st_transform(a.wkb_geometry, 4326), st_transform(b.wkb_geometry, 4326)) / 1000 AS dist
FROM all_houses A, all_houses b
WHERE a.valleylocation = 'plain' AND b.valleylocation = 'plain'
ORDER BY a.wkb_geometry <-> b.wkb_geometry)
---
--- We create a line between the houses
---
SELECT ROW_NUMBER() OVER() AS fid,
       house_id1, house_name1, house_id2, house_name2,
       st_makeline(geom1, geom2) AS linebetweenhouses,
       dist
FROM calculate;
