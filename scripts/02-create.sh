#!/bin/zsh

set -e 

dropdb philippines && createdb philippines && \
    psql -d philippines -c 'CREATE EXTENSION postgis;' && \
    psql -d philippines -c 'CREATE EXTENSION postgis_raster;' && \
    psql -d philippines -c 'CREATE EXTENSION postgres_fdw;'

psql -d philippines <<EOF
  CREATE SERVER missions
  FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (host 'localhost', dbname 'dominicos');

  CREATE USER MAPPING FOR igor SERVER missions OPTIONS (user 'igor');

  IMPORT FOREIGN SCHEMA filipinas LIMIT TO (misionando_casas)
  FROM SERVER missions INTO PUBLIC;
EOF
