using Cascadia
using Gumbo
using Requests
using PlotlyJS
using DataStructures: OrderedDict

include("scraper/heise.jl")
include("scraper/golem.jl")
include("scraper/spiegel.jl")

ignore_year = 2018

data = Dict()
#               scrape_...(maxpages, ignore_year)
data["heise"] = scrape_heise(39, ignore_year)
data["golem"] = scrape_golem(6, ignore_year)
data["spiegel"] = scrape_spiegel(20, ignore_year)

# plotting the results
trace_heise = scatter(;x=collect(keys(data["heise"])), y=collect(values(data["heise"])), name= "heise.de")
trace_golem = scatter(;x=collect(keys(data["golem"])), y=collect(values(data["golem"])), name= "golem.de")
trace_spiegel = scatter(;x=collect(keys(data["spiegel"])), y=collect(values(data["spiegel"])), name="spiegel-online.de")

records = [trace_heise, trace_golem, trace_spiegel]

layout = Layout(;
    xaxis = Dict(
        :title => "Year of publication",
        :range => [2000, ignore_year-1],
        :dtick => 2
    ),
    margin = Dict(
        :l => 50,
        :r => 10,
        :b => 60,
        :t => 50
    ),
    yaxis = Dict(
        :title => "Number of Articles"
    ),
    title = "Articles about artificial intelligence per year"
)

println("plotting...")
plot(records, layout)
