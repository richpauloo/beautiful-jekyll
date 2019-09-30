# acknowledge: 
# shaed relief scale_alpha trick: https://timogrossenbacher.ch/2016/12/beautiful-thematic-maps-with-ggplot2-only/#relief
# WCR: https://data.ca.gov/dataset/well-completion-reports


library(raster)
library(tidyverse)
library(sp)
library(sf)
library(scales)
library(cowplot)


# well completion report data
dat <- read_csv("~/Desktop/wcr/wellcompletionreports.csv")

# first make a copy of the column names
dat_colnames <- colnames(dat) 

dat <- dat %>% rename(lat = DecimalLatitude, lon = DecimalLongitude, 
                      type = PlannedUseFormerUse, driller_name = DrillerName,
                      township = Township, range = Range, section = Section,
                      top = TopOfPerforatedInterval, bot = BottomofPerforatedInterval)

##########################################################################
# cleaning from https://richpauloo.github.io/oswcr_1.html
#
# clean for ag, public, domestic
# cleaning function
replace_words <- function(vec, detect_this, replace_with){
  if(!is.vector(vec)){
    stop("`vec` must be a vector of words to search within")
  }
  if(!is.vector(detect_this)){
    stop("`detect_this` must be a vector of words to search for")
  }
  
  my_list = list() # temporary list to fill
  
  # fill out lists of indices with words to detect
  for(i in 1:length(detect_this)){
    my_list[[i]] = str_which(vec, detect_this[i])
  }
  do.call(c, my_list) -> temp # combine lists into one vector (with duplicates, which is okay)
  vec[temp] <- replace_with # replace incides with detected words with replacement word
  
  # return vector with replaced values
  return(vec)
}

# get vector of well types
well_types <- dat %>% .[["type"]] %>% tolower() 


# agriculture 
ag_words <- c("agriculture","agricultural","irrigation","iriigation","irrigation - landscape")
well_types <- replace_words(well_types, ag_words, "agriculture")

# domestic
dom_words <- "domestic"
well_types <- replace_words(well_types, dom_words, "domestic")

# Sparging - Vapor Extraction
remed_words <- c("vapor","sparging","sparge","oxygen","multi-phase","remediation")
well_types <- replace_words(well_types, remed_words, "remediation")

# public
public_words <- c("public","municipal","municipial","city") # humans spell things wrong 
well_types <- replace_words(well_types, public_words, "public")

# monitoring 
mon_words <- c("monitoring","observation","piezometer","oberservation") # humans spell things wrong 
well_types <- replace_words(well_types, mon_words, "monitoring")

# NA
na_words <- c("not specified","unknown","other na","other n/a")
well_types <- replace_words(well_types, na_words, "missing")
well_types <- replace_na(well_types, "missing")

# animal/stock
animal_words <- c("animal","stock","stockwater","dairy")
well_types <- replace_words(well_types, animal_words, "stock")

# unused
unused_words <- c("unused","destroyed","destruction")
well_types <- replace_words(well_types, unused_words, "unused")

# injection
injection_words <- "injection"
well_types <- replace_words(well_types, injection_words, "injection")

# industrial
ind_words <- c("industrial")
well_types <- replace_words(well_types, ind_words, "industrial")

# test well
unused_words <- c("unused","destroyed","destruction")
well_types <- replace_words(well_types, unused_words, "unused")

# cathodic
cat_words <- c("cathodic")
well_types <- replace_words(well_types, cat_words, "cathodic")

# geothermal
geo_words <- c("geothermal")
well_types <- replace_words(well_types, geo_words, "geothermal")

# other
oth_words <- c("other", "dewatering", "water supply")
well_types <- replace_words(well_types, oth_words, "other")

dat$type = well_types

dat %>% 
  filter(is.na(lat) | is.na(lon)) %>% nrow() / nrow(dat)

dat %>% filter(is.na(lat) | is.na(lon)) %>% nrow() - 
  dat %>% filter(is.na(lat) | is.na(lon) & !is.na(township) & !is.na(range) & !is.na(section)) %>% nrow()


lat_min <- 32.5343 - 1
lat_max <- 42.0095 + 1
lon_min <- -124.4096 - 1
lon_max <- -114.1308 + 1

# Longitude
dat %>% 
  filter(!is.na(lon)) %>% 
  filter(lon < lon_max  & lon > lon_min) %>% 
  nrow() / nrow(dat %>% filter(!is.na(lon))) * 100


# Latitude
dat %>% 
  filter(!is.na(lat)) %>% 
  filter(lat < lat_max | lat > lat_min) %>% 
  nrow() / nrow(dat %>% filter(!is.na(lat))) * 100

dat %>% 
  filter(lon > 0) %>%
  select(lat, lon)


dat %>% 
  filter(lat > lat_max) %>% 
  select(lat, lon)

# get index of big latitude
big_lat <- dat %>% rownames_to_column() %>% filter(lat > lat_max) %>% select(rowname) %>% `[[`("rowname") %>% as.numeric()

dat$lat[big_lat] <- 38.777 # fix the incorrect value



##########################################################################
# california basemap
states <- sf::st_as_sf(maps::map("state", plot = FALSE, fill = TRUE)) # state level polygon data
cabm <- states %>% filter(ID == "california") # subset to include only california
casp <- as(cabm, "Spatial")
#geom_sf(data = cabm, alpha = 0, color = "black", size = .5) + # ca basemap
#ggca <- map_data("state") %>% filter(region == "california")
# geom_polygon(data = ggca, 
#                aes(long, lat, group = group), 
#                alpha = 0, color = "black", size = .5)

# select only relevatn cols
dat <- dplyr::select(dat, WCRNumber, PermitDate, lat, DateWorkEnded,
              lon, type, driller_name, TotalCompletedDepth)

# convert spatial pts to sf object
pts <- st_as_sf(dat %>% filter(!is.na(lon) & !is.na(lat)),
                coords = c("lon","lat"), # for point data
                remove = F, # don't remove these lat/lon cols from df
                # tried: 4326 (pts too far west), 4269 (same), 4267 (same)
                crs = 4269) 
# define projection (crs)
pts <- pts %>% sf::st_transform(4269) 
pts <- as(pts, "Spatial")

# trim to california
#ca <- shapefile("~/Desktop/wcr/ca-state-boundary/CA_State_TIGER2016.shp")
#ca <- spTransform(ca, crs(pts))

#pts2 <- pts[ca, ] # trim lost pots outside of state


# p <- pts %>% ggplot() + 
#   geom_point(aes(lon, lat), size = 0.001, alpha = 0.2) + 
#   geom_polygon(data = ggca, 
#                aes(long, lat, group = group), 
#                alpha = 0, color = "black", size = .5) +
#   coord_fixed(1.3) + 
#   labs(x = "Longitude", y = "Latitude") + 
#   theme_void(base_size = 20) 
# ggsave(filename = "~/Desktop/wcr/p2.png", p, dpi = 300, height = 10, width = 10)

# 
# r <- getData('alt', country='USA', mask=TRUE)
# mainland <- r[[1]]
# casp <- spTransform(ca, crs(mainland))
# r2 <- mask(crop(mainland, casp), casp)
# r2 <- projectRaster(r2, crs = crs(ca))
# r2d <- as.data.frame(r2, xy=TRUE)
# colnames(r2d) <- c("x","y","z")


# p2 <- ggplot() +
#   geom_raster(data = filter(r2d, !is.na(z)), 
#               aes(x=x, y=y, alpha = z)) +
#   scale_alpha(name = "", range = c(0, 0.6), guide = FALSE) +
#   # geom_polygon(data = ggca,
#   #              aes(long, lat, group = group), 
#   #              alpha = 0, color = "black", size = 1) +
#   geom_point(data = pts@data, aes(lon, lat), size = 0.001, alpha = 0.2) + 
#   coord_fixed(1.3) +
#   theme_void() 
# ggsave(filename = "~/Desktop/wcr/p2.png", p2, dpi = 300, height = 13, width = 13)

# shaded terrain https://nationalmap.gov/small_scale/atlasftp.html#srgy48i
gt <- raster("~/Desktop/wcr/nat_map/srgy48i200l.tif")
caspt <- spTransform(casp, crs(gt))

#plot(caspt)
#pts <- spTransform(pts, crs(gt))
#plot(pts[pts@data$type == "agriculture", ], cex = 0.1, pch = 16, add=TRUE)
# nrow(pts[pts@data$type == "agriculture", ]) - 
#   nrow(pts[pts@data$type == "agriculture", ][caspt, ])

gtca <- mask(crop(gt, caspt), caspt)
gtca <- projectRaster(gtca, crs = crs(casp))


# convert raster to data frame
rdf <- #as.data.frame(aggregate(gtca, 5), xy = TRUE) %>% 
  as.data.frame(gtca, xy = TRUE) %>% 
  rename(z = srgy48i200l) %>% 
  filter(!is.na(z)) 

# trim pts to ca
pts <- spTransform(pts, crs(casp))
pts <- pts[casp, ]

# p3 <- ggplot() + 
#   geom_raster(data = rdf, aes(x, y, alpha = z)) + 
#   scale_alpha(name="", range=c(0.6, 0), guide=FALSE) + 
#   geom_point(data = pts_trim@data, mapping = aes(lon, lat), size = 0.001, alpha = 0.2) + 
#   coord_fixed(1.3) +
#   theme_void()
# ggsave(filename = "~/Desktop/wcr/p3.png", p3, dpi = 300, height = 13, width = 13)


##########################################################################
# California droughts defined by the USGS (see Appendix)
ca_droughts <- data.frame(xmin = c(1976, 1987, 2012),
                          xmax = c(1977, 1992, 2016),
                          ymin = 0, ymax = 10000, drought = "drought")
ca_droughts2 <- data.frame(xmin = c(1976, 1987, 2012),
                          xmax = c(1977, 1992, 2016),
                          ymin = 0, ymax = 90000, drought = "drought")


pts@data <- pts@data %>% 
  mutate(PermitDate = ifelse(PermitDate == "None", NA, PermitDate))
pts@data %>% filter(is.na(PermitDate)) %>% nrow()
pts@data %>% filter(is.na(DateWorkEnded)) %>% nrow()
pts@data %>% filter(is.na(PermitDate) & is.na(DateWorkEnded)) %>% nrow()

# PLOT OF WELLS DRILLED V TIME  
p <- pts@data %>% 
  filter(!is.na(DateWorkEnded) & !is.na(TotalCompletedDepth) &
         type %in% c("agriculture")) %>%
  mutate(year = lubridate::year(DateWorkEnded)) %>% 
  count(year) %>% 
  filter(year <= 2018 & year >= 1940) %>% 
  mutate(cs = cumsum(n), 
         dy = ifelse(year %in% c(1977,1991,2015), TRUE, FALSE)) %>%
  ggplot() +
  geom_line(aes(year, n)) +
  geom_point(aes(year, n), size = 2, color = "white") +
  geom_point(aes(year, n, color = dy), size = 1) +
  geom_rect(data = ca_droughts, 
            aes(xmin=xmin,xmax=xmax+1,ymin=ymin,
                ymax=ymax, fill = drought), alpha=0.2) +
  coord_cartesian(ylim = c(-100, 5300), xlim = c(1935,2025),
                  expand = c(0,0)) +
  theme_minimal() +
  guides(fill = FALSE, color = FALSE) +
  scale_color_manual(values = c("black","red")) +
  labs(x = NULL, y = NULL, 
       title = "Too hot to handle",
       subtitle = "Agricultural wells drilled per year",
       caption = "1977, 1991, and 2015 are among the driest years on California record, according to the USGS [3].") +
  theme(panel.grid.minor = element_blank(), 
        panel.grid.major.x = element_blank(),
        axis.ticks.x = element_line(size=0.5, color = "grey"),
        plot.title = element_text(face = "bold", size = 15),
        plot.subtitle = element_text(size = 10)) +
  scale_y_continuous(labels = comma) +
  annotate(geom = "text", x = 1974, y = 4250, 
           label = "1977", color = "red") +
  annotate(geom = "text", x = 1994, y = 2530, 
           label = "1991", color = "red") +
  annotate(geom = "text", x = 2012, y = 3250, 
           label = "2015", color = "red") +
  
  annotate(geom="text", x = 1977, y = 5000, 
           label = "'76-'77\n drought") +
  annotate(geom="text", x = 1989, y = 5000, 
           label = "'87-'92\n drought") +
  annotate(geom="text", x = 2014, y = 5000, 
           label = "'12-'16\n drought") 

# ggsave(filename = "~/Desktop/wcr/p1.png", dpi = 300, width = 8, height = 4.5)

# PLOT OF WELL DEPTH OVER TIME
x <- pts@data %>% 
  filter(!is.na(DateWorkEnded)& !is.na(TotalCompletedDepth) &
           type %in% c("agriculture")) %>%
  mutate(year = lubridate::year(DateWorkEnded)) %>% 
  group_by(year) %>% 
  summarise(td = mean(TotalCompletedDepth, na.rm=TRUE)) %>% 
  filter(year <= 2018 & year >= 1940)
  
p <- ggplot() +
  geom_rect(data = ca_droughts, 
            aes(xmin=xmin,xmax=xmax+1,ymin=ymin,
                ymax=ymax, fill = drought), alpha=0.2) +
  geom_line(data = x, aes(year, td)) +
  geom_point(data = x, aes(year, td), size = 2, color = "white") +
  geom_point(data = x, aes(year, td),size = 1, color = "black") +
  geom_smooth(data = x, aes(year, td), method = "lm", se=FALSE) +
  labs(x = NULL, y = NULL,
       title = "Race to the Bottom",
       subtitle = "Average depth of agricultural wells, feet below land surface") +
  theme_minimal() +
  coord_cartesian(ylim = c(250, 700)) +
  guides(fill=FALSE) +
  theme(panel.grid.minor = element_blank(), 
        panel.grid.major.x = element_blank(),
        axis.ticks.x = element_line(size=0.5, color = "grey"),
        plot.title = element_text(face = "bold", size = 15),
        plot.subtitle = element_text(size = 10)) +
  
  annotate(geom="text", x = 1977, y = 670, 
           label = "'76-'77\n drought") +
  annotate(geom="text", x = 1990, y = 670, 
           label = "'87-'92\n drought") +
  annotate(geom="text", x = 2014, y = 670, 
           label = "'12-'16\n drought") 

# ggsave(filename = "~/Desktop/wcr/p2.png", dpi = 300, width = 8, height = 4.5)

##########################################################################
# GIF OF AG WELLS OVER TIME
pts2<- pts[!is.na(pts@data$DateWorkEnded) & 
             !is.na(pts@data$TotalCompletedDepth) &
             pts@data$type == "agriculture", ]

pts2@data$year = lubridate::year(pts2@data$DateWorkEnded)
pts2 <- pts2[pts2@data$year <= 2018 & 
               pts2@data$year >= 1940, ]

uy <- sort(unique(pts2@data$year))
uy <- uy + 1

# smaller raster for testing adn iteration
rdfs <- as.data.frame(aggregate(gtca, 100), xy = TRUE) %>% 
  rename(z = srgy48i200l) %>% 
  filter(!is.na(z)) 

for(i in seq_along(uy)){
  ss <- pts2[pts2@data$year <= uy[i], ]
  
  # map
  pmap <- ggplot() + 
    
    # small raster for iteration and testing
    #geom_raster(data = rdfs, aes(x, y, alpha = z)) + 
    
    # full size raster for final product
    geom_raster(data = rdf, aes(x, y, alpha = z)) + 
    
    scale_alpha(name="", range=c(0.6, 0), guide=FALSE) + 
    geom_point(data = ss@data, mapping = aes(lon, lat), 
               size = 0.001, alpha = 0.2, color = "red") + 
    coord_fixed(1.3) +
    theme_nothing() +
    labs(x=NULL,y=NULL) +
    theme(plot.margin = margin(-10,200,-10,-10))
  
  # scatter plot
  psp <- ss@data %>% 
    filter(year <= uy[i]) %>% 
    count(year) %>% 
    mutate(cs = cumsum(n)) %>% 
    ggplot() +
    geom_line(aes(year, cs)) +
    geom_point(aes(year, cs), size = 2, color = "white") +
    geom_point(aes(year, cs), size = 1, color = "black") +
    geom_rect(data = ca_droughts2, 
              aes(xmin=xmin,xmax=xmax+1,ymin=ymin,
                  ymax=ymax, fill = drought), alpha=0.2) +
    coord_cartesian(ylim = c(-1000, 80000), 
                    xlim = c(1935,2025), expand = c(0,0)) +
    theme_minimal(base_size = 22) +
    guides(fill = FALSE) +
    labs(x = "Year", y = "Total wells drilled") +
    theme(panel.grid.minor = element_blank(), 
          panel.grid.major.x = element_blank(),
          axis.ticks.x = element_line(size=0.5, color = "grey"),
          plot.margin = margin(0,50,0,0)) +
    scale_y_continuous(labels = comma) 
    
    
  # conditional drought labels
  if(uy[i] >= 1977)
    psp <- psp + 
    annotate(geom="text", x = 1958, y = 28500,
             label = "'76-'77 drought", size = 6)

  if(uy[i] >= 1988)
    psp <- psp + 
    annotate(geom="text", x = 1958, y = 28500,
             label = "'76-'77 drought", size = 6) +
    annotate(geom="text", x = 1972, y = 44200,
             label = "'87-'92 drought", size = 6)
  
  if(uy[i] >= 2013)
    psp <- psp +
    annotate(geom="text", x = 1958, y = 28500, 
             label = "'76-'77 drought", size = 6) +
    annotate(geom="text", x = 1972, y = 44200, 
             label = "'87-'92 drought", size = 6) +
    annotate(geom="text", x = 1997, y = 71500, 
             label = "'12-'16 drought", size = 6)
  
  # inset p2 into p1
  pc <- ggdraw(pmap) +
    draw_plot(psp, .475, .55, .525, .4)
  
  # title
  title <- ggdraw() + 
    draw_label(
      glue::glue("Agricultural wells drilled before { uy[i] }"),
      fontface = 'bold',
      x = 0,
      hjust = 0,
      size = 40
    ) +
    theme(
      # add margin on the left of the drawing canvas,
      # so title is aligned with left edge of first plot
      plot.margin = margin(0, 0, 0, 125)
    )
  
  # combine title and inset plot
  pf <- plot_grid(
    title, pc,
    ncol = 1,
    # rel_heights values control vertical title margins
    rel_heights = c(0.1, 1)
  )
  
  ggsave(filename = glue::glue("~/Desktop/wcr/time/p{uy[i]}.png"), 
         pf, dpi = 300, height = 13, width = 13)
}
textme()

# make gif in Gif Brewery 


