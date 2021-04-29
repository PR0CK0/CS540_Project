-- RUN THIS QUERY FIRST --
-- IF YOU HAVE the contours_analysis2 table, you can skip this query and start at the third query
-- Makes the contours_analysis table, finds all distances from parcel centroids to all contour lines
select gp.altkey as parid,
ST_Distance(
  ST_Centroid(
    ST_Transform(
      gp.geom, 2236
    )
  ), 
  ST_Transform(
    ST_SetSRID(c.geom, 2236), 2236
  )
) as parcel_elevation_contour_distance,		 
c.elev
into volusia.contours_analysis
from volusia.gis_parcels gp, volusia.contours c, volusia.situs s

-- Update the zipcodes here to the ones you care about, or remove the ZIP code statements to do ALL of volusia (will take forever)
where s.parid = gp.altkey and (s.zip1 ilike '32114' or s.zip1 ilike '32118');
-- END FIRST QUERY --



-- RUN THIS SECOND --
-- IF YOU HAVE the contours_analysis2 table, you can skip this query and start at the third query
-- Makes the contours_analysis2 table, just has one parid corresponding to the closest elevation
select ca.parid, ca.elev
into volusia.contours_analysis2
from volusia.contours_analysis ca inner join
(
  select parid, min(parcel_elevation_contour_distance) as min_distance
  from volusia.contours_analysis
  group by parid
) t
on ca.parid = t.parid and ca.parcel_elevation_contour_distance = t.min_distance;
-- END FIRST QUERY --



-- RUN THIS THIRD --
-- Adds the needed column to the parcel table
alter table volusia.parcel add column parcel_elevation integer;
-- END THIRD QUERY --



-- RUN THIS LAST --
-- Updates the parcel table with elevation numbers
update volusia.parcel p 
set parcel_elevation = c.elev 
from volusia.contours_analysis2 c
where p.parid = c.parid;
-- END LAST QUERY --
