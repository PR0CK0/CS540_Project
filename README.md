# CS540_Project
For Professor Lehr, ERAU Daytona Spring 2021. Finding the elevation of each parcel in Volusia County FL, using GIS.

## Step 1 - Getting the Elevation/Contour Data
Download this: http://maps.vcgov.org/gis/download/shpfiles/contours.zip. I put the .shp file into QGIS like we are taught. There are some ways to get the contours layer into your SQL server, but since we already have QGIS open, follow these steps:

* Click the Processing tab up top
* Click Toolbox
* A menu will pop up on the right of QGIS
* Click Database
* Click Export to PostgreSQL
* Select the contours layer (should already be selected)
* Type in your login info and the schema you're adding to (volusia)
* Leave the table name blank, it will default to "contours"
* Don't touch anything else
* Scroll down and click Run
* Go to PGAdmin and refresh the volusia schema; the contours table should be there

## Step 2 - Queries
Download the .sql file and run the queries one after another. It's commented.
* The first query will take about 15m
* The second query will take at least an hour, even though it's just a simple column addition to sales_analysis
* The last query will take ...
