#' Get a praise template with a gif
#'
#' Pairs [praise::praise] with a gif using giphy's search. Returns a `praise_giphy`
#' object, which prints the html needed to embed the document (and prints in a knitr
#' document).
#'
#' @param template
#'   The template string. See [praise::praise] for more details.
#' @param rating
#'   Giphy's MPAA rating filter. Available options are: "y", "g", "pg", "pg-13" and "r".
#' @param size
#'   Giphy's rendition class. Some available options are "original" (original size),
#'   "downsized_medium" (file size under 5mb), and others. See the Giphy API for
#'   more details.
#'
#' @export
#'
praise_with_giphy <- function(template  = "You are ${adjective}!", rating = "g",
                              size = "downsized_medium") {
  text <- praise(template)
  giphy <- get_giphy(attr(text, "praise_words"), rating)
  attributes(text) <- NULL

  out <- list(text = text, giphy = giphy)
  class(out) <- "praise_giphy"
  out
}

# Adapted from praise::praise to return the added words as attributes
praise <- function(template = "You are ${adjective}!") {
  while (praise:::is_template(template)) {
    template <- replace_one_template(template)
  }
  template
}

# Adapted from praise:::replace_one_template to return the added words as attributes
replace_one_template <- function(template) {
  match <- regexpr(praise:::template_pattern, template, perl = TRUE)

  template1 <- substring(
    template,
    match,
    match + attr(match, "match.length") - 1L
  )

  part <- substring(
    template,
    attr(match, "capture.start"),
    attr(match, "capture.start") + attr(match, "capture.length") - 1L
  )

  old_praise_words <- attr(template, "praise_words")
  sub_replacement <- sample(praise::praise_parts[[tolower(part)]], 1)
  out <- praise:::match_case_sub(
    template1,
    part,
    sub_replacement,
    template
  )

  attr(out, "praise_words") <- c(old_praise_words, sub_replacement)
  out
}

#' @importFrom magrittr %>%
NULL

#' @importFrom knitr knit_print
#' @export
knitr::knit_print


get_giphy <- function(words, rating = "g", size = "downsized_medium") {
  api_key <- get_giphy_api_key()
  word <- sample(words) %>%
    utils::URLencode()

  search_results <- sprintf("http://api.giphy.com/v1/gifs/search?q=%s&rating=%s&api_key=%s",
                            word, rating, api_key) %>%
    httr::GET() %>%
    httr::content()

  if (is.null(search_results$data)) {
    return(NULL)
  }

  gif <- sample(search_results$data, 1)[[1]]

  gif_content <- gif$images[[size]]

  gif_url <- gif$url

  out <- list(content = gif_content, link = gif_url)
  class(out) <- "giphy_gif"
  out
}

#' Get and set giphy api key
#'
#' Get and set the giphy api key. See https://github.com/Giphy/GiphyAPI for
#' more details.
#'
#' @param key An api key string.
#'
#' @export
get_giphy_api_key <- function() {
  fail_message <-
  api_key <- Sys.getenv("giphy_api_key")
  if (api_key == "") {
    stop(paste0(
      "Please set the giphy API key using the function set_giphy_api_key().\n",
      "See https://github.com/Giphy/GiphyAPI for more details."
      ), call. = FALSE)
  }
  api_key
}

#' @export
#' @rdname get_giphy_api_key
set_giphy_api_key <- function(key) {
  Sys.setenv(giphy_api_key = key)
}

#' @export
print.praise_giphy <- function(x, ...) {
  print(praise_giphy_output(x))
  invisible(x)
}

#' @export
knit_print.praise_giphy <- function(x, ...) {
  knitr::knit_print(praise_giphy_output(x))
}

praise_giphy_output <- function(x) {
  htmltools::tags$div(
    htmltools::tags$p(htmltools::tags$strong(x$text)),
    giphy_gif_output(x$giphy)
  )
}

#' @export
print.giphy_gif <- function(x, ...) {
  print(giphy_gif_output(x))
  invisible(x)
}

#' @export
knit_print.giphy_gif <- function(x, ...) {
  knitr::knit_print(giphy_gif_output(x))
}


giphy_gif_output <- function(x) {
  if (is.null(x)) return(NULL)
  htmltools::tags$div(
    htmltools::tags$img(width = x$content$width, height = x$content$height, src = x$content$url),
    htmltools::tags$br(),
    htmltools::tags$small(htmltools::tags$a(href = x$link, "Powered by giphy."))
  )
}
