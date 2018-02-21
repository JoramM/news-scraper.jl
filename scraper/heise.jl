# only use a function and no module to keep it simple
function scrape_heise(maxpages, ignore_year)
    host = "https://www.heise.de"
    hostname = split(host, ".")[2]

    # collect
    articles = []
    i = 1
    while i <= maxpages
        println("calling site $(i)")
        req = get("$host/thema/K%C3%BCnstliche-Intelligenz/seite-$i")
        html = parsehtml(convert(String, req.data))
        relevant = Gumbo.HTMLNode
        if i == 1   # skip first list of articles ("Top Artikel")
            relevant = matchall(Selector(".themenseite-thema__article-list"),html.root)[2]
        else
            relevant = matchall(Selector(".themenseite-thema__article-list"),html.root)[1]
        end
        nodes = matchall(Selector(".akwa-article-teaser"),relevant)
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
        date = matchall(Selector("time"), article)[1].attributes["datetime"]
        date = split(date, "T")[1]  # yyyy-dd-mm
        year = parse(Int, split(date, "-")[1])  # yyyy
        if year == ignore_year
            continue
        end

        if haskey(dates, year)
            dates[year] += 1
        else
            dates[year] = 1
        end

        title = nodeText(matchall(Selector("h1.akwa-article-teaser__title"), article)[1])
        title = strip(title)    # remove whitespaces
        link = host * matchall(Selector("a"), article)[1].attributes["href"]
        push!(out, [date, title, link])
    end

    # export
    println("writing data to csv")
    writecsv("output/$hostname.csv", out)

    # plot
    return dates
end
