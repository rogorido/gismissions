DROP VIEW IF EXISTS missions_cagayan_appointments CASCADE;
CREATE VIEW missions_cagayan_appointments AS
SELECT person_id, nombre, cargo, casaid, casa_nombre, place, coord,
       ano, duracion
FROM misionando_casas A
JOIN (SELECT a.house_id, a.casa, a.date_foundation, a.lugar, a.valleylocation,
       a.appointments
       FROM all_houses a
       WHERE valleylocation = 'cagayan') b
     ON a.casaid = b.house_id
ORDER BY casa, ano NULLS FIRST;


DROP VIEW IF EXISTS missions_plain_appointments CASCADE;
CREATE VIEW missions_plain_appointments AS
SELECT person_id, nombre, cargo, casaid, casa_nombre, place, coord,
       ano, duracion
FROM misionando_casas A
JOIN (SELECT a.house_id, a.casa, a.date_foundation, a.lugar, a.valleylocation,
       a.appointments
       FROM all_houses a
       WHERE valleylocation = 'plain') b
     ON a.casaid = b.house_id
ORDER BY casa, ano NULLS FIRST;


---
--- we create a chronological series for the appointments in Cagayan
---
DROP VIEW IF EXISTS missions_cagayan_chronological_series;
CREATE VIEW missions_cagayan_chronological_series AS
WITH cte1 AS
  (SELECT MIN(ano) AS minimo, MAX(ano) AS maximo
  FROM missions_cagayan_appointments),
cte2 AS
  (SELECT generate_series(minimo, maximo, 1) AS chronologicalyear FROM cte1)
SELECT chronologicalyear,
       (SELECT COUNT(*) from missions_cagayan_appointments
       WHERE ano = chronologicalyear) AS total
FROM cte2
GROUP BY 1
ORDER BY chronologicalyear ASC;
