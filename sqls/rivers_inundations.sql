---
--- Analyzing the basins and the inundations in them
---
--- Data from Basinatlas
---
--- Details:
---
--- I take only the vw_buffer16000.


---
--- Simple query
--- 1. CTE1: We get the basins which are in the vw_buffer16000
--- 2. CTE2: we calculate the areas affected by inundations: we have the percentages
--- and have to calculate teh area
---
---
DROP VIEW IF EXISTS basins_inundations CASCADE;
CREATE VIEW basins_inundations AS
WITH cte1 AS
  (SELECT DISTINCT a.*
  FROM basin_rivers a
  JOIN vw_buffer16000 b
       ON st_intersects(a.geom, b.geom)),
--- CTE2
cte2 AS
  (SELECT a.*, b.hyriv_id, b.catch_skm, st_area(a.geom) / 1000000 AS catcharea_skm,
         inu_pc_cmn, inu_pc_cmx, inu_pc_clt,
         b.catch_skm * inu_pc_cmn / 100 AS catch_skm_mn,
         b.catch_skm * inu_pc_cmx / 100 AS catch_skm_mx
  FROM cte1 A
  JOIN luzon_rivers_inundationdata b
       ON a.hybas_id = b.hybas_l12)
--- we combine all
SELECT ogc_fid, hybas_id, geom,
       catcharea_skm,
       SUM(catch_skm_mn) AS catch_skm_mn,
       SUM(catch_skm_mx) AS catch_skm_mx,
       SUM(catch_skm_mn) * 100 / catcharea_skm AS catch_perc_mn,
       SUM(catch_skm_mx) * 100 / catcharea_skm AS catch_perc_mx
FROM cte2 GROUP BY 1, 2, 3, 4;

---
--- For every house get all hthe basins inside the vw_buffer16000
----
DROP VIEW IF EXISTS basins_inundations_houses_buffer16000 CASCADE;
CREATE VIEW basins_inundations_houses_buffer16000 AS
WITH cte1 AS
(SELECT a.house_id, a.house_name,
       b.hybas_id, b.geom,
       b.catcharea_skm,
       b.catch_skm_mn, b.catch_skm_mx,
       b.catch_perc_mn, b.catch_perc_mx
FROM vw_buffer16000_montanas750 a
JOIN basins_inundations b ON st_intersects(a.geom, b.geom))
SELECT ROW_NUMBER() OVER() AS ogc_fid,
       A.*
FROM cte1 A;
