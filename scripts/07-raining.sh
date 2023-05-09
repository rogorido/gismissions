#!/bin/zsh

psql -d philippines -f ../sqls/raining.sql
psql -d philippines -f ../sqls/raining_month.sql
