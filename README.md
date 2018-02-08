# Simple Scraper

I was wondering how much articles about "Artificial Intelligence" where published in the last few years. So I wrote this scraper to extract some data from [Golem](https://www.golem.de) and [Spiegel](http://www.spiegel.de). Of course this is no scientific research. You can see this little project as an example for a simple scraper written in Julia.

## Dependencies

I recommend using the [Juno IDE](http://junolab.org) (or add some packages to Atom: [uber-juno](https://github.com/JunoLab/uber-juno)) to run the code. A plotting tool is also integrated.

Add the following packages to Julia
```Julia
julia> Pkg.add("Cascadia")
julia> Pkg.add("Plots")
julia> Pkg.add("PlotlyJS")
```
