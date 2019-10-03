# depth of all ag wells with outliers removed
well_ft <- pts@data %>% 
  mutate(year = lubridate::year(DateWorkEnded)) %>%
  filter(TotalCompletedDepth < 3000 & type == "agriculture") %>% 
  pull(TotalCompletedDepth) %>%
  sum()

# convert ft to miles and divide by circumference of earth
(well_ft / 5280) / 24901

# 25% of earth's circumference. wow.

library(threejs)


earth <- "http://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73909/world.topo.bathy.200412.3x5400x2700.jpg"

# seattle to guangzhou = 6,453 mi = about 25% of earth's circumference
latlong = data.frame(lat = c(47.6062, 23.1291), long = c(-122.3321, 113.2644))
arcsdf = data.frame(origin_lat  = latlong[1,1],
                    origin_long = latlong[1,2],
                    dest_lat    = latlong[2,1],
                    dest_long   = latlong[2,2]) 

wid <- globejs(img=earth, lat=latlong[,1], long=latlong[,2], arcs=arcsdf, color = "red",
        arcsHeight=0.3, arcsLwd=30, arcsColor="red", arcsOpacity=0.8,
        atmosphere=FALSE, bg = "white",
        rotationlong = (180/3.14),
        rotationlat = (180/3.14))

htmlwidgets::saveWidget(wid, "globe.html")

