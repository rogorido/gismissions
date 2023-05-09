#!/bin/zsh

psql -d philippines -f ../sqls/rivers.sql
psql -d philippines -f ../sqls/rivers_polygons.sql
psql -d philippines -f ../sqls/rivers_inundations.sql
psql -d philippines -f ../sqls/rivers_buffers.sql

psql -d philippines -c 'VACUUM ANALYZE;'
