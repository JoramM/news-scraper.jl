# only use a function and no module to keep it simple
function scrape_golem(maxpages, ignore_year)
    host = "http://www.golem.de"
    hostname = split(host, ".")[2]

    # collect
    articles = []
    i = 1
    while i <= maxpages
        println("calling site $(i)")
        req = get("$host/specials/ki/v50-$i.html")
        html = parsehtml(convert(String, req.data))
        nodes = matchall(Selector(".list-articles li"),html.root)
        if (length(nodes) > 0)
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
        date = nodeText(matchall(Selector(".text1"), article)[1])[1:10]
        year = parse(Int, split(date, ".")[3])
        if year == ignore_year
            continue
        end

        if haskey(dates, year)
            dates[year] += 1
        else
            dates[year] = 1
        end

        title = nodeText(matchall(Selector(".dh2"), article)[1])
        link = matchall(Selector("a"), article)[1].attributes["href"]
        push!(out, [date, title, link])
    end

    # export
    println("writing data to csv")
    writecsv("output/$hostname.csv", out)

    # plot
    return dates
end
