#' @include Options.R

#' @template set-default-options
set_default_options <- function() {
    # Set `Options` instance.
    options(parabar = Options$new())

    # Remain silent.
    invisible(NULL)
}
