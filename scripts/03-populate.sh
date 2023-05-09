#!/bin/zsh

#
# Data that I have already as sql files
#
psql -d philippines -f ../data/casas.sql
psql -d philippines -f ../data/luzon.sql
psql -d philippines -f ../data/valleys_polygons.sql
psql -d philippines -f ../data/rios.sql

raster2pgsql -s 3123 -I -C -M /home/igor/geschichte/tagungen/aphes2019/gis/precipitaciones/precipitacionesglobales.tif public.raining | psql -d philippines


# I have at the moment two mountains raster files:
# 1. the old onw (srtm_lugon-epsg3123) which I use for the buffers
# 2. the new luzon_3123 which is the modern one (with several lines).
#
# The reason: I have a problem to create vw_mountains with luzon_3123.
# I use luzon_3123 for calculate profiles, etc.
#

# for some reason I cannot use
# -t 128x128
raster2pgsql -s 3123 -I -C -M /home/igor/geschichte/tagungen/aphes2019/gis/srtm/srtm_luzon_epsg3123.tif public.alturas | psql -d philippines

#
raster2pgsql -I -C -M -t auto ../data/srtm/luzon_3123.tif public.luzon_srtm | psql -d philippines

#
# necesitamos transformar a epsg3123 todo lo de las precipitaciones
#
gdalwarp -t_srs EPSG:3123 /home/igor/geschichte/tagungen/aphes2019/gis/precipitaciones/prec1_ph.tif /tmp/prec01_3123.tif
gdalwarp -t_srs EPSG:3123 /home/igor/geschichte/tagungen/aphes2019/gis/precipitaciones/prec2_ph.tif /tmp/prec02_3123.tif
gdalwarp -t_srs EPSG:3123 /home/igor/geschichte/tagungen/aphes2019/gis/precipitaciones/prec3_ph.tif /tmp/prec03_3123.tif
gdalwarp -t_srs EPSG:3123 /home/igor/geschichte/tagungen/aphes2019/gis/precipitaciones/prec4_ph.tif /tmp/prec04_3123.tif
gdalwarp -t_srs EPSG:3123 /home/igor/geschichte/tagungen/aphes2019/gis/precipitaciones/prec5_ph.tif /tmp/prec05_3123.tif
gdalwarp -t_srs EPSG:3123 /home/igor/geschichte/tagungen/aphes2019/gis/precipitaciones/prec6_ph.tif /tmp/prec06_3123.tif
gdalwarp -t_srs EPSG:3123 /home/igor/geschichte/tagungen/aphes2019/gis/precipitaciones/prec7_ph.tif /tmp/prec07_3123.tif
gdalwarp -t_srs EPSG:3123 /home/igor/geschichte/tagungen/aphes2019/gis/precipitaciones/prec8_ph.tif /tmp/prec08_3123.tif
gdalwarp -t_srs EPSG:3123 /home/igor/geschichte/tagungen/aphes2019/gis/precipitaciones/prec9_ph.tif /tmp/prec09_3123.tif
gdalwarp -t_srs EPSG:3123 /home/igor/geschichte/tagungen/aphes2019/gis/precipitaciones/prec10_ph.tif /tmp/prec10_3123.tif
gdalwarp -t_srs EPSG:3123 /home/igor/geschichte/tagungen/aphes2019/gis/precipitaciones/prec11_ph.tif /tmp/prec11_3123.tif
gdalwarp -t_srs EPSG:3123 /home/igor/geschichte/tagungen/aphes2019/gis/precipitaciones/prec12_ph.tif /tmp/prec12_3123.tif

raster2pgsql -s 3123 -I -C -M /tmp/prec01_3123.tif public.rain_month01 | psql -d philippines
raster2pgsql -s 3123 -I -C -M /tmp/prec02_3123.tif public.rain_month02 | psql -d philippines
raster2pgsql -s 3123 -I -C -M /tmp/prec03_3123.tif public.rain_month03 | psql -d philippines
raster2pgsql -s 3123 -I -C -M /tmp/prec04_3123.tif public.rain_month04 | psql -d philippines
raster2pgsql -s 3123 -I -C -M /tmp/prec05_3123.tif public.rain_month05 | psql -d philippines
raster2pgsql -s 3123 -I -C -M /tmp/prec06_3123.tif public.rain_month06 | psql -d philippines
raster2pgsql -s 3123 -I -C -M /tmp/prec07_3123.tif public.rain_month07 | psql -d philippines
raster2pgsql -s 3123 -I -C -M /tmp/prec08_3123.tif public.rain_month08 | psql -d philippines
raster2pgsql -s 3123 -I -C -M /tmp/prec09_3123.tif public.rain_month09 | psql -d philippines
raster2pgsql -s 3123 -I -C -M /tmp/prec10_3123.tif public.rain_month10 | psql -d philippines
raster2pgsql -s 3123 -I -C -M /tmp/prec11_3123.tif public.rain_month11 | psql -d philippines
raster2pgsql -s 3123 -I -C -M /tmp/prec12_3123.tif public.rain_month12 | psql -d philippines

#
# We create with postgis the mountains
#
psql -d philippines -f ../sqls/mountains.sql

#
# We put into the database a geojson with the route
# from Lingayen to Manaoag created by openrouteservice
#
ogr2ogr -f "PostgreSQL" -t_srs "EPSG:3123" PG:"dbname=philippines user=igor" \
        ../data/lingayen-manaoag-apie.json \
        -nln lingayen-route \
        -lco GEOMETRY_NAME=geom

#
# Rivers as polygons
#
shp2pgsql -s 4326:3123 -I ../data/gis_osm_water_a_free_1.shp public.rivers_polygons | psql -d philippines
# o con ogr2ogr?

##
## I have extracted the rivers from with
## ogr2ogr -clipsrc luzon.shp hydrosheds-luzon.shp HydroRIVERS_v10.shp
##
## We need -nlt MULTILINESTRING because there are multilinestrings.
##

ogr2ogr -f "PostgreSQL" -t_srs "EPSG:3123" PG:"dbname=philippines user=igor" ../data/hydrosheds-luzon.shp \
        -nln luzon_rivers_hydrosheds \
        -lco GEOMETRY_NAME=geom \
        -nlt MULTILINESTRING

#
# Data from riveratlas: we analyze the data about inundation (variables cmn, cmx, clt, umn, umx, ult)
#
# See: https://data.hydrosheds.org/file/technical-documentation/RiverATLAS_Catalog_v10.pdf
#
# I extracted the data with:
# ogr2ogr -clipsrc /home/igor/geschichte/artikel/gismissions/gis/data/luzon.shp riveratlas-luzon.shp RiverATLAS_v10_au.shp
ogr2ogr -f "PostgreSQL" -t_srs "EPSG:3123" PG:"dbname=philippines user=igor" ../data/riveratlas-luzon.shp \
        -nln luzon_rivers_inundationdata \
        -lco GEOMETRY_NAME=geom \
        -nlt MULTILINESTRING

#
# Data from basinatlas: we analyze the data about inundation (variables cmn, cmx, clt, umn, umx, ult)
#
# See:
#
# I extracted the data with:
ogr2ogr -f "PostgreSQL" -t_srs "EPSG:3123" PG:"dbname=philippines user=igor" ../data/basinatlas-luzon.shp \
        -nln basin_rivers \
        -lco GEOMETRY_NAME=geom \
        -nlt MULTIPOLYGON

#
# vacuum is necessary after many new data
#
psql -d philippines -c 'VACUUM ANALYZE;'
