# only use a function and no module to keep it simple
function scrape_spiegel(maxpages, ignore_year)
    host = "http://www.spiegel-online.de"
    hostname = split(host, ".")[2]

    # collect
    articles = []
    i = 1
    while i <= maxpages
        println("calling site $i")
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
    println("found $(min(i,maxpages)) sites with $(length(articles)) articles")

    # parse
    println("extracting data from html")
    out = []
    dates = OrderedDict{Int, Int}()
    for article in articles
        source = nodeText(matchall(Selector(".source-date"), article)[1])
        date = split(source, "-")[2][3:end]
        year = parse(Int, split(date, ".")[3])
        if year == ignore_year
            continue
        end

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
    writecsv("output/$hostname.csv", out)

    # plot
    return dates
end
