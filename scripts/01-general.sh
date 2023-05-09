#!/bin/zsh

set -e 

sh ./02-create.sh
sh ./03-populate.sh
sh ./04-buffers.sh
sh ./06-heights.sh
sh ./07-raining.sh
sh ./08-rivers.sh
sh ./05-hexagons.sh
sh ./09-delete.sh

# last vacuum

psql -d philippines -c 'VACUUM ANALYZE;'
