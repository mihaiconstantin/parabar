#' @include Options.R Helper.R

#' @template set-default-options
set_default_options <- function() {
    # Set `Options` instance.
    options(parabar = Options$new())

    # Remain silent.
    invisible(NULL)
}


#' @template get-option
get_option <- function(option) {
    # Invoke the helper.
    Helper$get_option(option)
}


#' @template set-option
#' @export
set_option <- function(option, value) {
    # Invoke the helper.
    Helper$set_option(option, value)

    # Remain silent.
    invisible()
}
