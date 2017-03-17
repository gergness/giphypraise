
<!-- README.md is generated from README.Rmd. Please edit that file -->
giphypraise
===========

giphypraise is an R package that combines the [praise package](https://github.com/rladies/praise) with the [giphy api](https://github.com/Giphy/GiphyAPI). It parses a string to add positive words using the praise package, then searches giphy for a gif using one of those words.

``` r
library(giphypraise)

# See the Giphy API Github page for more information on keys (https://github.com/Giphy/GiphyAPI)
set_giphy_api_key(readLines("giphy_api_key.txt"))

praise_with_giphy("You are a ${adjective} person, keep up the ${adjective} work!")
```

<!--html_preserve-->
<p>
<strong>You are a stylish person, keep up the hunky-dory work!</strong>
</p>
<img width="600" height="338" src="http://media2.giphy.com/media/l46CdoZqbJxQMOvjW/giphy.gif"/> <br/> <small> <a href="http://giphy.com/gifs/findingdory-adorable-finding-dory-baby-l46CdoZqbJxQMOvjW">Powered by giphy.</a> </small>

<!--/html_preserve-->
