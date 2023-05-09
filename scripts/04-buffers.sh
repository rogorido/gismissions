#!/bin/zsh

psql -d philippines -f ../sqls/buffers.sql 
psql -d philippines -f ../sqls/buffers-clipped.sql
psql -d philippines -f ../sqls/covered.sql
psql -d philippines -f ../sqls/commonareas.sql
psql -d philippines -f ../sqls/houses_distances.sql

psql -d philippines -c 'VACUUM ANALYZE;'
