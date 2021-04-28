# CS540_Project
For Professor Lehr, ERAU Daytona Spring 2021. Finding the elevation of each parcel in Volusia County FL, using GIS.

Uses a few GIS functions to determine the nearest contour line on the map, and thereby deduce a "parcel's elevation". Initial efforts were with ST_Intersects, ST_Project, ST_MakePoint, ST_InterpolatePoint and so forth; the idea then was to cast out a ray in each cardinal directions from the centroid of a given parcel, and from these rays find all intersections with contour lines, then pick the closest intersecting contour line and choose it as the parcel's height. This was functional but vastly complex (on the order of quintuply-nested GIS function calls) for each direction (N, E, S, W)... 

So I thought about it some more, and ended up reducing all the effort to a simple call of ST_Distance, feeding the function parcel centroids and all contour lines in the zip codes 32114 and 32118. This is output into a table called contours_analysis. With this table, and parids in it, we can map to whatever we want, specifically sales_analysis. So now we can perform some sales analysis with respect to parcel elevation.

*The general assumption is that a higher elevation indicates more property value (because of the flood-resistance and impossibility of  cheap, below sea-level swamp land); but this is likely untrue for beachfront properties, which are generally right at sea-level and cost a ton.*

![QGIS contours](https://github.com/Psychobagger/CS540_Project/blob/main/media/contours.PNG)

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
Download the .sql file and run the queries one after another. It's commented. NOTE: You don't have to run the first query if you only care about the zip codes 32114 and 32118... otherwise, you have to re-run the queries yourself.
* The first query will take about 15m
* The second query will take a while...
* The last query will take ...

That's it. It's rather straightforward.
