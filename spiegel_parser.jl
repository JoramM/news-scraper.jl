using Cascadia
using Gumbo
using Requests
using Plots

host = "http://www.spiegel.de"
maxpages = 20

# collect
articles = []
i = 1
while i <= maxpages
    println("calling site $(i)")
    req = get("$host/thema/kuenstliche_intelligenz/dossierarchiv-$i.html")
    html = parsehtml(convert(String, req.data))
    nodes = matchall(Selector(".teaser"),html.root)
    if length(nodes) > 0
        append!(articles, nodes)
    else
        break
    end
    i += 1
end
println("found $(i) sites with $(length(articles)) articles")

# parse
println("extracting data from html")
out = []
dates = Dict()
for article in articles
    source = nodeText(matchall(Selector(".source-date"), article)[1])
    date = split(source, "-")[2][3:end]
    year = split(date, ".")[3]
    if haskey(dates, year)
        dates[year] += 1
    else
        dates[year] = 1
    end

    source = chop(split(source, "-")[1])
    title = nodeText(matchall(Selector("a .headline"), article)[1])
    link = string(host, matchall(Selector("a"), article)[1].attributes["href"])
    push!(out, [date, source, title, link])
end

# export
println("writing data to csv")
writecsv("output/spiegel.csv", out)

# plot
ordered_dates = sort(dates)
xs = [k for k = keys(ordered_dates)]
ys = [v for v = values(ordered_dates)]

println("plotting...")
plotlyjs()
plot(xs, ys, title="Spiegel-Artikel zum Thema KI")
