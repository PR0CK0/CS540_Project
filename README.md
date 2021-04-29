# CS540_Project
**Tyler Procko**

For Professor Lehr, ERAU Daytona Spring 2021. 

## **Finding the elevation of each parcel in Volusia County FL, using GIS.**

Uses a few GIS functions to determine the nearest contour line on the map, and thereby deduce a "parcel's elevation". Initial efforts were with ST_Intersects, ST_Project, ST_MakePoint, ST_InterpolatePoint and so forth; the idea then was to cast out a ray in each cardinal direction from the centroid of a given parcel, and from these rays find all intersections with contour lines, then pick the closest intersecting contour line and choose it as the parcel's height. This was functional but vastly complex (on the order of quintuply-nested GIS function calls) for each direction (N, E, S, W)... 

So I thought about it some more, and ended up reducing all the effort to a simple call of ST_Distance, feeding the function parcel centroids and all contour lines in the zip codes 32114 and 32118. Each parcel centroid has a distance computed to every single contour line - and with some SQL magic (the min function lol) we can get the closest contour line, which is presumed to be the parcel's elevation. This is output into a table called contours_analysis. With this table, and parids in it, we can map to whatever we want, specifically sales_analysis. So now we can perform some sales analysis with respect to parcel elevation.

*The general assumption is that a higher elevation indicates more property value (because of the flood-resistance and impossibility of  cheap, below sea-level swamp land); but this is likely untrue for beachfront properties, which are generally right at sea-level and cost a ton.*

![QGIS contours](https://github.com/Psychobagger/CS540_Project/blob/main/media/contours.PNG)

## Note
* **ONLY 32114 AND 32118 ZIP CODES HAD ELEVATIONS POPULATED... all others ignored for time. RUN IT YOURSELF IF YOU NEED OTHER ZIP CODES.**
* **ENSURE YOU SWITCH TO 'IMPORT' (NOT EXPORT) WHEN IMPORTING A CSV FOR A TABLE, THEN CHECK 'HEADER' SO THE COLUMN NAMES ARE IMPORTED TOO**

## Easy Method
If you only care about ZIP codes 32114 and 32118, just do the following:

* Download my parcel table (**called parcel_elev.csv.zip**)
* PGAdmin makes you create a table first, so run [this create table statement in your volusia schema](https://github.com/Psychobagger/CS540_Project/blob/main/create_table.sql)
* Import this csv to the volusia schema by right-clicking the new table (after refreshing), click Import/Export, make sure it's on 'Import', then check 'Header'; now import it
* Let this table act as your parcel table in your experiments (it's the same, just with an *elevation* column)
* Done

Now we go onto the detailed steps of reproducing my work... remember, you don't have to do this unless you want other ZIP codes.

## Step 1 - Getting the Elevation/Contour Data
If you're lazy, just download the **contours.csv.zip** file in this Github, extract the CSV and make that a table in postgis with the table name contours. If you did this, skip to Step 2. Otherwise, read on.

Download this: http://maps.vcgov.org/gis/download/shpfiles/contours.zip. I put the .shp file into QGIS like we are taught (new vector layer). There are some ways to get the contours layer into your SQL server, but since we already have QGIS open, follow these steps:

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
Download the **queries.sql** file and run the queries one after another in PGAdmin - the SQL file is commented and it takes like 20 minutes, tops. Another way is to download my parcel table (**called parcel_elev.csv.zip**), put it in your volusia schema and you have all of the elevation numbers for the zip codes I chose (32114 and 32118). You'll basically duplicate your own parcel table, but it saves you the query time. The csv file may look empty in the elevation column, but it's because only 17000-ish parcels exist in those two zip codes.

The number 2236 you see in the first query is GIS' SRID for multi-point lines, which is what the contours are. That number shows up in my query because it acts like a cast for the centroid of the parcel, which is a lonlat, point SRID (4326). It's necessary to "cast" it so that the ST_Distance function works.

* The first query will take about 45 minutes
* The second query will take about 20 minutes (creates [this file](https://github.com/Psychobagger/CS540_Project/blob/main/contours_analysis2.csv))
* The third query will take about half a second
* The last query will take about ten seconds
* ***Total time of queries (for my PC and for just two ZIP codes): about an hour***

NOTE: If you only care about the ZIP codes 32114 and/or 32118, then you don't have to run anything. Just download the **parcel_elev** table, and let that act as your parcel table for your experiments.

That's it. It's rather straightforward.

## Step 3 - Visualizing in QGIS
Recall: you can do this right from the "easy method", skipping steps 2 and 3.

* You have to have a geom column in the parcel_elev table to be able to represent it in QGIS
* Run the following: `select AddGeometryColumn ('volusia', 'parcel_elev', 'geom', 2236, 'MULTIPOLYGON', 2);`
* And run this: `update volusia.parcel_elev a set geom = p.geom from volusia.gis_parcels p where a.parid=p.altkey;`
* Open QGIS and make sure you're connected to the server. Add a PostGIS layer and select parcel_elev. Right click the layer, go to properties. On Symbology do Graduated, for the symbol 'parcel_elevation'. Enter values for the elevation column like 0-5, 6-10, 10-20 etc., and give them each a color. You can specify a color graduation so it blends. 

![QGIS map finished](https://github.com/Psychobagger/CS540_Project/blob/main/media/gis2.PNG)
