---
--- ATTENTION: for some reason are the values from postgis and from qgis
--- different. Moreover in plain_heights_percentages I get very strange results.
---

---
--- We create the mountains with postgis
---
--- We create the mountains with raster alturas since luzon_3123 has problems (creating polygons?)
---
---

DROP MATERIALIZED VIEW IF EXISTS vw_mountains CASCADE;
CREATE MATERIALIZED VIEW vw_mountains AS
---
--- create a simplified version of the raster with DEMs
---
WITH simplerast AS
  (SELECT (ST_Contour(rast, 1, fixed_levels => ARRAY[750.0, 1000.0, 1250.0])).*
   FROM alturas WHERE rid = 1),

---
--- We polygonize the raster
---
polys AS
   (SELECT id, VALUE, st_polygonize(geom) AS geom
    FROM simplerast GROUP BY 1, 2)

---
--- We create IDs and dump the polygons
---
SELECT ROW_NUMBER() OVER () AS ogc_fid,
       id, VALUE AS height,
       (st_dump(geom)).geom
FROM polys;

---
--- View: cagayan_small_heights_percentages
---
--- We calculate how much territory is above 100, 200, 300ms in Cagayan
---
--- the code seems a little bit scareful but it is not

DROP VIEW IF EXISTS cagayan_small_heights_percentages;
CREATE  VIEW cagayan_small_heights_percentages AS
---
--- CTE simplerast, polys, polys2 is the same such as vw_mountains!
---
WITH simplerast AS
  (SELECT (ST_Contour(rast, 1,
          fixed_levels => ARRAY[0.0, 100.0, 200.0, 300.0, 400.0, 500.0,
                                600.0, 700.0, 800.0, 900.0, 1000.0,
                                1100.0, 1200.0, 1300.0, 1400.0, 1500.0])).*
   FROM alturas WHERE rid = 1),
polys AS
   (SELECT id, VALUE, st_polygonize(geom) AS geom
    FROM simplerast GROUP BY 1, 2),
polys2 AS
(SELECT ROW_NUMBER() OVER () AS ogc_fid,
       id, VALUE AS height,
       (st_dump(geom)).geom
  FROM polys),

---
--- CTE clipped: clipped by the valley polygon
---
clipped AS
  (SELECT st_intersection(a.geom,  b.wkb_geometry) AS geom, height
   FROM polys2 A
   JOIN valleys_polygons  b ON st_intersects(a.geom, b.wkb_geometry)
   WHERE nombre = 'cagayan_small')
---
--- We create the data group by heights
---
--- In FROM we make a st_union of the polygons
---
SELECT height, st_area(geom) / 1000000 AS area,
       (SELECT st_area(wkb_geometry) FROM valleys_polygons WHERE nombre = 'cagayan_small') /  1000000 AS valleyarea,
       st_area(geom) * 100 / (SELECT st_area(wkb_geometry)
       FROM valleys_polygons
       WHERE nombre = 'cagayan_small') AS perc
FROM
  (SELECT height, st_union(geom) AS geom FROM clipped GROUP BY 1) AS k
GROUP BY 1, 2, 4; -- I do not know why I have to group by 4...

---
--- View: cagayan_big_heights_percentages
---
--- We calculate how much territory is above 100, 200, 300ms in Cagayan
---
--- the code seems a little bit scareful but it is not

DROP VIEW IF EXISTS cagayan_big_heights_percentages;
CREATE  VIEW cagayan_big_heights_percentages AS
---
--- CTE simplerast, polys, polys2 is the same such as vw_mountains!
---
WITH simplerast AS
  (SELECT (ST_Contour(rast, 1,
          fixed_levels => ARRAY[0.0, 100.0, 200.0, 300.0, 400.0, 500.0,
                                600.0, 700.0, 800.0, 900.0, 1000.0,
                                1100.0, 1200.0, 1300.0, 1400.0, 1500.0])).*
   FROM alturas WHERE rid = 1),
polys AS
   (SELECT id, VALUE, st_polygonize(geom) AS geom
    FROM simplerast GROUP BY 1, 2),
polys2 AS
(SELECT ROW_NUMBER() OVER () AS ogc_fid,
       id, VALUE AS height,
       (st_dump(geom)).geom
  FROM polys),

---
--- CTE clipped: clipped by the valley polygon
---
clipped AS
  (SELECT st_intersection(a.geom,  b.wkb_geometry) AS geom, height
   FROM polys2 A
   JOIN valleys_polygons  b ON st_intersects(a.geom, b.wkb_geometry)
   WHERE nombre = 'cagayan_big')
---
--- We create the data group by heights
---
--- In FROM we make a st_union of the polygons
---
SELECT height, st_area(geom) /  1000000 AS area,
       (SELECT st_area(wkb_geometry) FROM valleys_polygons WHERE nombre = 'cagayan_big') / 1000000 AS valleyarea,
       st_area(geom) * 100 / (SELECT st_area(wkb_geometry)
       FROM valleys_polygons
       WHERE nombre = 'cagayan_big') AS perc
FROM
  (SELECT height, st_union(geom) AS geom FROM clipped GROUP BY 1) AS k
GROUP BY 1, 2, 4; -- I do not know why I have to group by 4...


---
--- View: plain_big_heights_percentages
---
--- We calculate how much territory is above 100, 200, 300ms in Plain
---
--- the code seems a little bit scareful but it is not

DROP VIEW plain_heights_percentages CASCADE;
CREATE  VIEW plain_heights_percentages AS
---
--- CTE simplerast, polys, polys2 is the same such as vw_mountains!
---
WITH simplerast AS
  (SELECT (ST_Contour(rast, 1,
          fixed_levels => ARRAY[0.0, 100.0, 200.0, 300.0, 400.0, 500.0,
                                600.0, 700.0, 800.0, 900.0, 1000.0,
                                1100.0, 1200.0, 1300.0, 1400.0, 1500.0])).*
   FROM alturas WHERE rid = 1),
polys AS
   (SELECT id, VALUE, st_polygonize(geom) AS geom
    FROM simplerast GROUP BY 1, 2),
polys2 AS
(SELECT ROW_NUMBER() OVER () AS ogc_fid,
       id, VALUE AS height,
       (st_dump(geom)).geom
  FROM polys),

---
--- CTE clipped: clipped by the valley polygon
---
clipped AS
  (SELECT st_intersection(a.geom,  b.wkb_geometry) AS geom, height
   FROM polys2 A
   JOIN valleys_polygons  b ON st_intersects(a.geom, b.wkb_geometry)
   WHERE nombre = 'plain')
---
--- We create the data group by heights
---
--- In FROM we make a st_union of the polygons
---
SELECT height, st_area(geom) / 1000000 AS area,
       (SELECT st_area(wkb_geometry) FROM valleys_polygons WHERE nombre = 'plain') / 1000000 AS valleyarea,
       st_area(geom) * 100 / (SELECT st_area(wkb_geometry)
       FROM valleys_polygons
       WHERE nombre = 'plain') AS perc
FROM
  (SELECT height, st_union(geom) AS geom FROM clipped GROUP BY 1) AS k
GROUP BY 1, 2, 4; -- I do not know why I have to group by 4...
