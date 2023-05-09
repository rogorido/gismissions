This repository contains scripts and data for the paper 'Missionaries,
rivers and inundation. GIS and early modern religious globalization'
presented by me at the [Digital-History-Tagung
2023](https://dhistory.hypotheses.org/digital-history-tagung-2023). The
data and analysis are also available on my website [Early Modern
Dominicans](https://dominicans.georeligion.org).

![buffers-cagayan](images/buffers-bajo-cagayan.jpeg)

The code is released under the [GNU General Public License version
3.0](https://www.gnu.org/licenses/gpl-3.0.html). 

# Instructions

The code provided in this repository can be used for reproduce the
analysis presented in the paper mentioned above. 

There are two main directories: 

1. in the directory [scripts](scripts/) you find bash scripts necessary
   to automate the creation of the database: populate the database with
   data, create functions, create views, and so on. 
2. in the directory [sqls](sqls/) you find the SQL queries necessary to
   populate the database. 

A **warning**: to populate the database some data are necessary which
can **not** be included in this repository due to license issues (SRTM
data, etc.).

