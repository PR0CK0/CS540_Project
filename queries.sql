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
-- END SECOND QUERY --





-- IGNORE THIS, JUST TESTING
-- AGAIN, IGNORE THIS ENTIRE QUERY (unless you are grading me or something lol)
-- This is another version of query 1 that promises better computational speed, it's from one of Lehr's announcements about looping in SQL
update volusia.parcel_elev set parcel_elevation = null;

DO
LANGUAGE plpgsql
$$
DECLARE
g1 geometry;
rec RECORD;
elev float;
i int = 1;

BEGIN
	for rec in select parid, geom from volusia.parcel_elev
		where parcel_elevation is NULL and geom IS NOT NULL loop
		g1:=rec.geom;
		
		select into elev c.elev
			from volusia.contours c
			order by ST_SetSRID(c.geom, 2236) <->(ST_Centroid(ST_Transform(g1, 2236)))
			limit 1;

		update volusia.parcel_elev set parcel_elevation = elev where parid=rec.parid ;
		RAISE NOTICE '% - set to % %', i, rec.parid, elev;
		i=i+1;
	END LOOP;
End;
$$;
