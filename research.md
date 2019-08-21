---
layout: page
title: Research
subtitle: 
show-avatar: false
---

I investigate groundwater quantity and quality. Global groundwater reserves are the largest store of freshwater resources not locked in frozen ice caps, glaciers, and continental ice sheets.[^fn1] Around the world, groundwater storage is in critical decline [^fn2] [^fn3], and groundwater quality faces equal if not more severe threats [^fn4] [^fn5] [^fn6].  

The motivation of my present research is to ensure that future generations have access to clean and abundant groundwater resources.  

I am grateful to my funding sources, without which the following projects would not be possible:  
* [National Science Foundation DGE #1069333, the Climate Change, Water, and Society IGERT, to UC Davis.](http://ccwas.ucdavis.edu/)  
* [Department of Energy - U.S./China Clean Energy Research Center for Water Energy Technologies (CERC-WET)](https://cerc-wet.berkeley.edu/)  

***
## Predicting Domestic Well Vulnerability to Drought with Statistical & Machine Learning
During the 2012-2016 drought, the state received more than 2,500 domestic well failure reports, the majority of which were in California's Central Valley [^fn7]. This left thousands of people without a reliable source of drinking water for months and, in some cases, years. Recent developments in California's Open and Transparent Water Data Platform (AB-1755) have made water data in California more transparent and available than ever before. In particular, well construction information, validation datasets of actual well failure, and groundwater level measurements are concurrently available, enabling the firstever regional-scale models of domestic well failure in California's Central Valley. This research utilizes big geospatial timeseries data to model domestic well failure, and machine learning models coupled with climate change predictors to predict future vulnerability to well failure.  

Questions:
* Which domestic wells will be vulnerable in the next drought?  
* Are disadvantaged households disproportionately affected by drought-vulnerable wells?  
* Can machine learning identify characteristics of the vulnerable wells that will worsen with climate change?  
 
[![domestic well failure to ](/img/cawdc_dash.png)](https://richpauloo.github.io/flexdash.html)  
*click on the picture to view the project*  

***
## Anthropogenic Basin Closure and Groundwater Salinization: An Unrecognized Threat to Water Quality Sustainability

Across the word, closed hydrologic basins form when basin outflow exceeds inflow and predominantly exits via evapotranspiration, leading to a subsequent accumulation of dissolved solids, and a decline in groundwater quality. Examples include the Dead Sea (Israel/Joran), the Great Salt Lake (Utah, USA), and Mono Lake (California, USA). Groundwater pumping and irrigation in agriculturally intensive regions of the world is closing basins, with unexplored consequences on groundwater quality and the energy required to halt or desalinate these resources. This research examines regional groundwater quality decline due to closed basin salinization in the Tulare Basin of California's Central Valley. 

Question:
* What are the depths, timescales, and contaminant budgets of closed basin groundwater salinization?  

[![groundwater salinization conceptual model](img/gw_sal.png)](https://github.com/richpauloo/Monte-Carlo-Mixing-Model)

*(A) Open basin, pre-groundwater development: surface and groundwater systems connect. Groundwater discharges dissolved solids into surface water which exit the basin. Groundwater at this stage is predominantly fresh (e.g., < 1,000 mg/L). (B) Partial basin closure: groundwater pumping causes reduction or elimination of baseflow to streams. Pumped groundwater returns to the basin via irrigation return flow. Dissolved solids begin to accumulate in shallow groundwater. (C) Closed basin: falling groundwater levels cause subsurface inflow to drain adjacent basins. Streams lose to groundwater. Water primarily exits via evapotranspiration (ET), which further concentrates dissolved solids in groundwater. Salts migrate into the deeper aquifer.*

***
## Regional Groundwater Quality Management Models

Nonpoint-source groundwater contamination threatens to gradually degrade the quality of vast quantities of groundwater on time scales of decades to centuries in many parts of the world. Hydrogeophysical models of fluid flow in porous media (aquifers), and the equations to solve contaminant transport problems were initially developed for field-scale point-source pollutants, and are computationally expensive to solve at regional scales. Emerging contaminants of concern from agricultural nutrient management and closed basin salinization threaten the sustainability of regional-scale groundwater resources, and demand groundwater quality management models that currently do not exisit.   

Here, we develop simplified (upscaled) numerical contaminant transport models that preserve 3D non-Fickian transport physics, for application towards modern regional-scale groundwater quality management.  

Core Question:

* Can non-Fickian contaminant transport effects produced by 3D heterogeneity be represented in 2D, and if so, what information is lost?  

The developed methods will allow hypothesis testing into currently unresearched phenomena in groundwater resources modeling and management:
* What effect will Managed Aquifer Recharge have on regional groundwater quality?  
* Can groundwater salinization be mitigated, and if so under what timescales, at what cost, and by which specific practices?  

![A statistical model of geologic heterogeneity](img/upscale.png)  

***

Most of this research involves simulating 3D particle motion in heterogeneous porous media under different hydraulic gradients, which make for cool results:   

[![contaminant transport](img/con_trans.png)](http://rpubs.com/richpauloo/rand_walk)  
*click on the picture to explore some results*  





***
#### References

[^fn1]: Gleick, P. H., 1996: Water resources. In Encyclopedia of Climate and Weather, ed. by S. H. Schneider, Oxford University Press, New York, vol. 2, pp.817-823.

[^fn2]: Döll, P., Hoffmann-Dobrev, H., Portmann, F.T., Siebert, S., Eicker, A., Rodell, M., Strassberg, G., Scanlon, B.R., 2012. Impact of water withdrawals from groundwater and surface water on continental water storage variations. J. Geodyn. 59–60, 143–156. doi:10.1016/j.jog.2011.05.001

[^fn3]: Famiglietti, J.S., 2014. The global groundwater crisis. Nat. Clim. Chang. 4, 945–948. doi:10.1038/nclimate2425

[^fn4]: Kang, M., Jackson, R.B., 2016. Salinity of deep groundwater in California: Water quantity, quality, and protection. doi:10.1073/pnas.1600400113

[^fn5]: MacDonald, A.M., Bonsor, H.C., Ahmed, K.M., Burgess, W.G., Basharat, M., Calow, R.C., Dixit, A., Foster, S.S.D., Gopal, K., Lapworth, D.J., Lark, R.M., Moench, M., Mukherjee, A., Rao, M.S., Shamsudduha, M., Smith, L., Taylor, R.G., Tucker, J., van Steenbergen, F., Yadav, S.K., 2016. Groundwater quality and depletion in the Indo-Gangetic Basin mapped from in situ observations. Nat. Geosci. 1. doi:10.1038/ngeo2791

[^fn6]: United States Geologic Survey, N.A.W.Q.A., 2010. Water Quality in Principal Aquifers of the United States, 1991 – 2010 Circular 1360.

[^fn7]: Department of Water Resources, 2018. Locally Reported Household Water Shortages for Drought Assistance. Accessed November 11, 2018. [Website](https://mydrywatersupply.water.ca.gov/report/publicpage)