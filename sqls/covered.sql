
---
--- Function covered_cagayan
---
--- returns the kms2 covered also as % of total territory
--- arguments: buffer, montains and valleytype
---
---
--- There are many ''' because we have to put in string such as "buffer4000", "cagayan_small", etc.
---
--- The main prolbem is that in all_houses (and then in vw_buffers) we have as valleylocation
--- only plain or cagayan, but in valleys_polygons we have cagayan_small and cagayan_big
--- Therefore we create valleylocation and assign to it a value cagayan/plain according
--- to the parameter "valley".

DROP FUNCTION IF EXISTS fn_covered_territory CASCADE;
CREATE OR REPLACE FUNCTION fn_covered_territory (buffer VARCHAR,
       mountainsheights VARCHAR, valley varchar)
    RETURNS TABLE (
    buffercovered TEXT, -- buffer4000, etc.
    mountains TEXT, -- montanas750
    valleytype TEXT, -- reducido/amplio
    covered DOUBLE precision,
    valleyarea DOUBLE PRECISION,
    coveredperc DOUBLE precision)
AS $BODY$
DECLARE
   bufferview TEXT := 'vw_' || $1 || '_' || $2;
   valleylocation TEXT; -- value in vw_buffers (is only cagayan or plain or no_valley)
 BEGIN

   IF valley = 'cagayan_small' OR valley = 'cagayan_big' THEN
      valleylocation := 'cagayan';
   ELSE
      valleylocation := valley;
   END IF;

   RAISE notice 'el valor es %s', valleylocation;

   RETURN query EXECUTE '
   SELECT ''' || buffer || ''' AS buffercovered, ''' || mountainsheights || ''' AS mountains, ''' || valley || ''' as valleytype,
        ST_AREA(ST_UNION(geom)) / 1000000 AS covered,
       (SELECT ST_AREA(wkb_geometry) / 1000000
           FROM valleys_polygons WHERE nombre = ''' || valley || ''') AS valleyarea,
       (ST_AREA(ST_UNION(geom)) / (SELECT ST_AREA(wkb_geometry)
        FROM valleys_polygons WHERE nombre = ''' || valley || ''')) * 100 AS porcentaje
    FROM ' || bufferview || ' WHERE valleylocation = ''' || valleylocation || '''';

  END;
$BODY$
LANGUAGE plpgsql;


DROP MATERIALIZED VIEW IF EXISTS covered_territory;
CREATE MATERIALIZED VIEW covered_territory AS
SELECT * FROM fn_covered_territory('buffer4000', 'montanas750', 'cagayan_small')
UNION
SELECT * FROM fn_covered_territory('buffer4000', 'montanas1000', 'cagayan_small')
UNION
SELECT * FROM fn_covered_territory('buffer4000', 'montanas1250', 'cagayan_small')
UNION
SELECT * FROM fn_covered_territory('buffer8000', 'montanas750', 'cagayan_small')
UNION
SELECT * FROM fn_covered_territory('buffer8000', 'montanas1000', 'cagayan_small')
UNION
SELECT * FROM fn_covered_territory('buffer8000', 'montanas1250', 'cagayan_small')
UNION
SELECT * FROM fn_covered_territory('buffer11430', 'montanas750', 'cagayan_small')
UNION
SELECT * FROM fn_covered_territory('buffer11430', 'montanas1000', 'cagayan_small')
UNION
SELECT * FROM fn_covered_territory('buffer11430', 'montanas1250', 'cagayan_small')
UNION
SELECT * FROM fn_covered_territory('buffer12000', 'montanas750', 'cagayan_small')
UNION
SELECT * FROM fn_covered_territory('buffer12000', 'montanas1000', 'cagayan_small')
UNION
SELECT * FROM fn_covered_territory('buffer12000', 'montanas1250', 'cagayan_small')
UNION
SELECT * FROM fn_covered_territory('buffer13380', 'montanas750', 'cagayan_small')
UNION
SELECT * FROM fn_covered_territory('buffer13380', 'montanas1000', 'cagayan_small')
UNION
SELECT * FROM fn_covered_territory('buffer13380', 'montanas1250', 'cagayan_small')
UNION
SELECT * FROM fn_covered_territory('buffer16000', 'montanas750', 'cagayan_small')
UNION
SELECT * FROM fn_covered_territory('buffer16000', 'montanas1000', 'cagayan_small')
UNION
SELECT * FROM fn_covered_territory('buffer16000', 'montanas1250', 'cagayan_small')
UNION
SELECT * FROM fn_covered_territory('buffer24000', 'montanas750', 'cagayan_small')
UNION
SELECT * FROM fn_covered_territory('buffer24000', 'montanas1000', 'cagayan_small')
UNION
SELECT * FROM fn_covered_territory('buffer24000', 'montanas1250', 'cagayan_small')
UNION ---- todo valle
SELECT * FROM fn_covered_territory('buffer4000', 'montanas750', 'cagayan_big')
UNION
SELECT * FROM fn_covered_territory('buffer4000', 'montanas1000', 'cagayan_big')
UNION
SELECT * FROM fn_covered_territory('buffer4000', 'montanas1250', 'cagayan_big')
UNION
SELECT * FROM fn_covered_territory('buffer8000', 'montanas750', 'cagayan_big')
UNION
SELECT * FROM fn_covered_territory('buffer8000', 'montanas1000', 'cagayan_big')
UNION
SELECT * FROM fn_covered_territory('buffer8000', 'montanas1250', 'cagayan_big')
UNION
SELECT * FROM fn_covered_territory('buffer11430', 'montanas750', 'cagayan_big')
UNION
SELECT * FROM fn_covered_territory('buffer11430', 'montanas1000', 'cagayan_big')
UNION
SELECT * FROM fn_covered_territory('buffer11430', 'montanas1250', 'cagayan_big')
UNION
SELECT * FROM fn_covered_territory('buffer12000', 'montanas750', 'cagayan_big')
UNION
SELECT * FROM fn_covered_territory('buffer12000', 'montanas1000', 'cagayan_big')
UNION
SELECT * FROM fn_covered_territory('buffer12000', 'montanas1250', 'cagayan_big')
UNION
SELECT * FROM fn_covered_territory('buffer13380', 'montanas750', 'cagayan_big')
UNION
SELECT * FROM fn_covered_territory('buffer13380', 'montanas1000', 'cagayan_big')
UNION
SELECT * FROM fn_covered_territory('buffer13380', 'montanas1250', 'cagayan_big')
UNION
SELECT * FROM fn_covered_territory('buffer16000', 'montanas750', 'cagayan_big')
UNION
SELECT * FROM fn_covered_territory('buffer16000', 'montanas1000', 'cagayan_big')
UNION
SELECT * FROM fn_covered_territory('buffer16000', 'montanas1250', 'cagayan_big')
UNION
SELECT * FROM fn_covered_territory('buffer24000', 'montanas750', 'cagayan_big')
UNION
SELECT * FROM fn_covered_territory('buffer24000', 'montanas1000', 'cagayan_big')
UNION
SELECT * FROM fn_covered_territory('buffer24000', 'montanas1250', 'cagayan_big')
UNION -- plain
SELECT * FROM fn_covered_territory('buffer4000', 'montanas750', 'plain')
UNION
SELECT * FROM fn_covered_territory('buffer4000', 'montanas1000', 'plain')
UNION
SELECT * FROM fn_covered_territory('buffer4000', 'montanas1250', 'plain')
UNION
SELECT * FROM fn_covered_territory('buffer8000', 'montanas750', 'plain')
UNION
SELECT * FROM fn_covered_territory('buffer8000', 'montanas1000', 'plain')
UNION
SELECT * FROM fn_covered_territory('buffer8000', 'montanas1250', 'plain')
UNION
SELECT * FROM fn_covered_territory('buffer11430', 'montanas750', 'plain')
UNION
SELECT * FROM fn_covered_territory('buffer11430', 'montanas1000', 'plain')
UNION
SELECT * FROM fn_covered_territory('buffer11430', 'montanas1250', 'plain')
UNION
SELECT * FROM fn_covered_territory('buffer12000', 'montanas750', 'plain')
UNION
SELECT * FROM fn_covered_territory('buffer12000', 'montanas1000', 'plain')
UNION
SELECT * FROM fn_covered_territory('buffer12000', 'montanas1250', 'plain')
UNION
SELECT * FROM fn_covered_territory('buffer13380', 'montanas750', 'plain')
UNION
SELECT * FROM fn_covered_territory('buffer13380', 'montanas1000', 'plain')
UNION
SELECT * FROM fn_covered_territory('buffer13380', 'montanas1250', 'plain')
UNION
SELECT * FROM fn_covered_territory('buffer16000', 'montanas750', 'plain')
UNION
SELECT * FROM fn_covered_territory('buffer16000', 'montanas1000', 'plain')
UNION
SELECT * FROM fn_covered_territory('buffer16000', 'montanas1250', 'plain')
UNION
SELECT * FROM fn_covered_territory('buffer24000', 'montanas750', 'plain')
UNION
SELECT * FROM fn_covered_territory('buffer24000', 'montanas1000', 'plain')
UNION
SELECT * FROM fn_covered_territory('buffer24000', 'montanas1250', 'plain');
