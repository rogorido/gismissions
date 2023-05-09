---
--- Extra infos about mountains and terrain
---
---

---
--- We want to create a elevation profile for the lines going from the house
--- to the points of the buffer (only 16000m).
---
--- This query could be probably be simplified... It is important that I create lines
--- to the buffers without mountains because they are much less lines.
---
--- CTE1: creates the points on the buffer's edges
--- CTE2: we make a line from the house to every point
--- CTE3: we unify the polygon of luzon (because of regions) for clipping
--- CTE4: we clipped the lines with Luzon
--- CTE5: we create a fid for every line (important for analysis)
--- CTE6: we interpolate 100 points in the lines and dump them

DROP materialized VIEW houselines_to_buffers CASCADE;
CREATE materialized VIEW houselines_to_buffers AS
WITH cte1 AS
  (SELECT house_id, (st_dumppoints(geom)).geom FROM vw_buffer16000),
cte2 AS
  (SELECT a.house_id, st_makeline(a.wkb_geometry, b.geom) AS geom
   FROM all_houses A
   JOIN cte1 b ON  a.house_id = b.house_id),
cte3 AS
  (SELECT st_union(wkb_geometry) AS wkb_geometry FROM luzon ),
cte4 AS
  (SELECT a.house_id, st_intersection(a.geom,  b.wkb_geometry) AS geom
   FROM cte2 A JOIN cte3 b ON st_contains(b.wkb_geometry, a.geom)),
cte5 AS
  (SELECT ROW_NUMBER() OVER () AS fid, house_id, geom FROM cte4),
cte6 AS
  (SELECT fid, house_id,
          (st_dump(ST_LineInterpolatePoints(geom, 0.01))).geom AS geom
 FROM cte5)
SELECT ROW_NUMBER() OVER() AS ogc_fid, house_id, fid,
       row_number() OVER(PARTITION BY fid) AS orden, geom
FROM cte6;

CREATE UNIQUE INDEX houselines_to_buffers_idx ON houselines_to_buffers(ogc_fid);
CREATE INDEX houselines_to_buffers_geom_idx ON houselines_to_buffers USING gist(geom);


---
--- We create a elevation profile from houselines_to_buffers
---
DROP MATERIALIZED VIEW IF EXISTS elevation_profile_lines;
CREATE MATERIALIZED VIEW elevation_profile_lines AS
SELECT house_id, fid, row_number() OVER(PARTITION BY fid) AS orden,
       st_value(b.rast, a.geom) AS height
FROM houselines_to_buffers  A
JOIN luzon_srtm b ON st_intersects(b.rast, a.geom);

----
---- We create a kind of mesh around a house to get areas of heights
----
---- we generate 6000 points for a territory of radius 16kms (c. 800km2)
----
---- We get also the difference bw the point and the house
----
DROP materialized VIEW mesh_elevation_buffer CASCADE;
CREATE materialized VIEW mesh_elevation_buffer AS

-- we generate the points
WITH cte1 AS
(SELECT a.house_id, (st_dump(st_generatepoints(a.geom, 6000))).geom AS geom,
        b.height AS househeight
 FROM vw_buffer24000 a
 JOIN all_houses b USING (house_id)),

--- we create luzon as union
cte2 AS
(SELECT st_union(wkb_geometry) AS wkb_geometry FROM luzon ),

--- we clip the points inside luzon
cte3 AS
(SELECT a.house_id, househeight, a.geom
 FROM cte1 A JOIN cte2 b ON st_intersects(b.wkb_geometry, a.geom)),

--- we get the heights
cte4 AS
(SELECT house_id, househeight,
        st_value(b.rast, a.geom) AS pointheight, geom
 FROM cte3 A
 JOIN luzon_srtm b ON st_intersects(b.rast, a.geom))

--- we put all together
SELECT ROW_NUMBER() OVER() AS ogc_fid, house_id,
       househeight, pointheight,
       pointheight - househeight AS heightdifference,
       geom
FROM cte4;
