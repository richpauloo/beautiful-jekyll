## Summary

**For those short on** ⏰:  

When we travel somewhere new, checking the weather is simple. But checking the water quality is not.  

To make water quality data in California easy to access and understand, I built a “weather app for water quality,” that enables users to easily check public drinking water quality in their hometown, place of work, school, and anywhere they may travel.  

🔗 [Learn about your water quality here.](caccr.github.io).  

![California consumer confidence reports for public water quality data.](_posts/img/example.gif)


***  

## Challenge = Opportunity

Present sources of water quality information (i.e. - consumer confidence reports) are fragmented across thousands of water utilities in the state, and lack consistency and clarity. These reports do not always effectively communicate water quality data, are only updated once per year, and vary in quality (here's an [example of one](_posts/img/valverde2017.pdf), [another](_posts/img/CCR2016CA0103041.pdf), [and another](_posts/img/2017PierpointSpringsCCR-Cert)). Near-real-time, standardized, and easy to understand water quality reports would improve the public’s understanding of the water they buy and consume.  

Data isn’t available for all California water systems, notably “state smalls” which service between 5 and 15 connections. However, data availability is much better for community water systems (15 or more connections).   

This project aimed to build a “weather app” for California community water system water quality. The benefits of this approach include standardization, consistency across agencies, ease of use, and near-real-time water quality information.  

[The project is visible here](caccr.github.io).

The website aggregates publicly available water quality data for California community water systems and reports key information: 

* compliance status  
* chemicals detected within the past 2 years  
* average detection levels for all contaminants tested for   
* water quality indicators  
* local water and health system contact information  

I imagine that users will use this tool to learn more about water quality in their places of residence, work, school, and recreation. If they wish to learn more, they should find it easy to contact their water system.   


***  

## Open water data

I turn on the tap every day to drink, shower, cook, and water the plants, generally taking for granted that clean water flows out. If I were to trace the water back through the pipe, I'd find a complex network of water utilities, treatment plants, and regulatory bodies all working together to acquire, treat, and deliver that water. This is one of the privileges of living in a wealthy country that’s easy to forget. If you asked me to tell you about the quality of the water coming out of my tap, about the different chemicals tested for and the levels detected, I wouldn't be able to. I might search the internet to search for this information, but I would find it difficult to find and make sense of.  

Water in California is provided by a federated system of independent utilities. Some water agencies are so small that they slip through the cracks of state-mandated water quality testing, and others, like Metropolitan water district, are so large that they make up a majority of the water users in the state (see bubble chart below, created by [Avery Kreuger](https://twitter.com/averymkruger?lang=en).  

<meta charset="utf-8">

<!-- Load d3.js -->
<script src="https://d3js.org/d3.v4.js"></script>

<!-- Color palette -->
<script src="https://d3js.org/d3-scale-chromatic.v1.min.js"></script>

<!-- Create a div where the graph will take place -->
<div id="my_dataviz"></div>

<style>
.node:hover{
  stroke-width: 7px !important;
  opacity: 1 !important;
}
</style>

<script>
// set the dimensions and margins of the graph
var width = 1200
var height = 600
// append the svg object to the body of the page
var svg = d3.select("#my_dataviz")
  .append("svg")
    .attr("width", width)
    .attr("height", height)
    //.attr("preserveAspectRatio", "xMinYMin meet")
    //.attr("viewBox", "0 0 960 500")
// Read data
d3.csv("https://raw.githubusercontent.com/akrugercws/cdc2019/master/WSPops.csv", function(data) {
  // Filter a bit the data -> more than 1 million inhabitants
  data = data.filter(function(d){ return d.value>0 })
  // Color palette for continents?
  var color = d3.scaleOrdinal()
    .domain(["ALAMEDA", "LOS ANGELES", "SAN FRANCISCO", "ORANGE", "SAN JOAQUIN", "ALPINE", 
    "AMADOR", "BUTTE", "NA", "CALAVERAS", "COLUSA", "CONTRA COSTA", "DEL NORTE","EL DORADO","FRESNO","GLENN","HUMBOLDT","IMPERIAL","INYO","MADERA","MARIN","MARIPOSA","MENDOCINO","MERCED"])
    .range(d3.schemeSet1);
  // Size scale for countries
  var size = d3.scaleLinear()
    .domain([0, 100000])
    .range([3,60])  // circle will be between 7 and 55 px wide
  // create a tooltip
  var Tooltip = d3.select("#my_dataviz")
    .append("div")
    .style("opacity", 0)
    .attr("class", "tooltip")
    .style("background-color", "white")
    .style("border", "solid")
    .style("border-width", "2px")
    .style("border-radius", "5px")
    .style("padding", "5px")
  // Three function that change the tooltip when user hover / move / leave a cell
  var mouseover = function(d) {
    Tooltip
      .style("opacity", 1)
  }
  var mousemove = function(d) {
    Tooltip
      .html('<b>' + d.name + '</b>' + "<br>" + d.county + " county" + "<br>" + (1*d.value).toLocaleString() + " inhabitants")
      .style("left", (d3.mouse(this)[0]+20) + "px")
      .style("top", (d3.mouse(this)[1]) + "px")
  }
  var mouseleave = function(d) {
    Tooltip
      .style("opacity", 0)
  }
  // Initialize the circle: all located at the center of the svg area
  var node = svg.append("g")
    .selectAll("circle")
    .data(data)
    .enter()
    .append("circle")
      .attr("class", "node")
      .attr("r", function(d){ return Math.sqrt(size(d.value))})
      .attr("cx", width / 2)
      .attr("cy", height / 2)
      .style("fill", function(d){ return color(d.county)})
      .style("fill-opacity", 0.5)
      .attr("stroke", "black")
      .style("stroke-width", 1)
      .on("mouseover", mouseover) // What to do when hovered
      .on("mousemove", mousemove)
      .on("mouseleave", mouseleave)
      .call(d3.drag() // call specific function when circle is dragged
           .on("start", dragstarted)
           .on("drag", dragged)
           .on("end", dragended));
  // Features of the forces applied to the nodes:
  var simulation = d3.forceSimulation()
      .force("center", d3.forceCenter().x(width / 2).y(height / 2)) // Attraction to the center of the svg area
      .force("charge", d3.forceManyBody().strength(.6)) // Nodes are attracted one each other of value is > 0
      .force("collide", d3.forceCollide().strength(.2).radius(function(d){ return (Math.sqrt(size(d.value))+3) }).iterations(1)) // Force that avoids circle overlapping
  // Apply these forces to the nodes and update their positions.
  // Once the force algorithm is happy with positions ('alpha' value is low enough), simulations will stop.
  simulation
      .nodes(data)
      .on("tick", function(d){
        node
            .attr("cx", function(d){ return d.x; })
            .attr("cy", function(d){ return d.y; })
      });
  // What happens when a circle is dragged?
  function dragstarted(d) {
    if (!d3.event.active) simulation.alphaTarget(.03).restart();
    d.fx = d.x;
    d.fy = d.y;
  }
  function dragged(d) {
    d.fx = d3.event.x;
    d.fy = d3.event.y;
  }
  function dragended(d) {
    if (!d3.event.active) simulation.alphaTarget(.03);
    d.fx = null;
    d.fy = null;
  }
})
</script>


Water quality sustainability is threatened by [political challenges](https://www.nytimes.com/2019/09/12/climate/trump-administration-rolls-back-clean-water-protections.html), [aging infrastructure](https://www.nytimes.com/2019/07/24/us/the-crisis-lurking-in-californians-taps-how-1000-water-systems-may-be-at-risk.html), and [historical contamination](https://www.nytimes.com/2018/03/26/lens/the-superfund-sites-of-silicon-valley.html), thus it is vital that citizens have a pulse on water quality data. 


***   


## Open data as democracy

It's the year 2019. Worldwide, water resources are threatened by [over-extraction from underground aquifers](https://www.nature.com/articles/nclimate2425), [increasing climate variability and population growth](https://science.sciencemag.org/content/289/5477/284), and [aging infrastructure](https://www.nytimes.com/2019/04/25/us/flint-water-crisis.html).  

About a decade ago, in 2010, the UN recognized [water as a human right](https://www.un.org/waterforlifedecade/human_right_to_water.shtml), and in 2012, the state of [California followed suit](https://oehha.ca.gov/water/report/human-right-water-california). If the leaders of California and the constituents they represent agree that water is vital, we must answer the question, "how do we go from where we're at today to the future we envision? How do we actually **secure** water as a human right?"    

If the government is to play a key role in regulating water availability and quality, then policy is the answer. Policy is blind without supporting information, thus, open and transparent data is the most reasonable approach towards the goal of securing clean and accessible water. We need to measure the systems we manage, thus, we need open, accurate, and up-to-date information.

Efforts to make previously-private data public domain are relatively new. In 2016, California legislators passed the [Open and transparent water data act](https://water.ca.gov/ab1755), the technical implementation of which can be found in [California's open data portal](data.ca.gov). It’s hard to emphasize just how significant of a shift this is. 

Just 4 years ago, I started a PhD in hydrogeology at the University of California Davis, and found it nearly impossible to find publicly available water data. Water data was valuable, and hence, guarded. Private consulting firms collected, curated and sold services using those data. Why would a self-interested firm then release work that took them years to create, only to be stolen by another competing firm? Furthermore, to some, open data was synonymous with more regulation, so it was feared and opposed. For example, although [well construction data](https://data.ca.gov/dataset/well-completion-reports) has been collected for over 100 years by the state, it was only made public in 2017, enabling some of the first estimates of the [population served by private domestic wells](https://www.sciencebase.gov/catalog/item/58e25974e4b09da67996a6c6).  

Although much more data is available in 2019 than it was 4 years ago, let alone a decade ago, not all water data is measured. Groundwater pumping data for example, is still private, and inferred by models developed by the [Department of Water Resources](https://water.ca.gov/Library/Modeling-and-Analysis/Central-Valley-models-and-tools/C2VSim), the [United States Geological Survey](https://ca.water.usgs.gov/projects/central-valley/central-valley-hydrologic-model.html), and [NASA satellites](https://grace.jpl.nasa.gov/resources/9/grace-sees-groundwater-losses-around-the-world/). I’m not arguing that we should measure **everything** -- that’s wasteful. However, we should think critically about our policy objectives and the decisions we need to make as a society, (whether that’s some human right to water, or avoiding an undesirable result), and then reverse-engineer the problem to determine what data we need to inform that critical decision.  

Does the data that informs these critical policy objectives **need** to be open? Will it actually be in the best interest of the public? In some cases, the answer is no. For instance, consider information that may compromise the privacy of certain individuals, threaten national security, or be used in other perverse ways to disenfranchise marginalized communities. However, transitioning closed to open and transparent data systems has the potential to create new possibilities. For one, open data allows researchers to answer problems outside of the scope of government and industry that might otherwise remain neglected. Secondly, open data is very similar to the free press, in that it provides information which allows people to develop informed opinions, and put political pressure on our representatives. An informed society is critical to a functioning and healthy democracy, and this fundamentally depends on the openness of public domain data. 


***


## Final thoughts

While working on this project, the following thought returned again and again to me:

> The responsibility of reporting water quality information to customers currently falls on water systems. Is this reporting paradigm more aligned with public interest, or bureaucratic expedience? 

There are clear benefits to requiring water systems to report water quality information to their customers, such as expedience and granting local control. However, as mentioned above, the drawbacks of this approach include infrequent and inconsistent reports, and information that’s hard to find. It’s also not inconceivable that utilities with lackluster water quality may be hesitant to make this information visible, something that an impartial third party wouldn’t suffer from.  

With the rise of data technologies, automated reporting is breeze. Water quality data is a perfect example of a public dataset that can benefit from automated reporting. To ensure quality control, such a reporting pipeline would require government or private supervision. This comes at some cost, but ultimately, I believe this cost is outweighed by the benefit such a system offers to the public. To this end, this project aimed not only to create a use-case of how automated reporting can transform open data into a useful public resource, but also, to develop a re-usable data pipeline that can accommodate new data, and serve as a model for similar efforts in other domains. 


