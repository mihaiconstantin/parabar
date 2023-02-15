#' @title
#' Set Default Options
#'
#' @description
#' This function is used to set the default [`options`][base::options()] values
#' for the [`parabar::parabar`] package. The function is automatically called at
#' package load and the entry created can be retrieved via
#' [`getOption("parabar")`][base:getOptions()]. Specific package
#' [`options`][base::options()] can be retrieved using the helper function
#' [parabar::get_option()].
#'
#' @return
#' The function returns void. The [`options`][base::options()] set can be
#' consulted via the [`base::.Options`] list. See the [`parabar::Options`]
#' [`R6::R6`] class for more information on the default values set by this
#' function.
#'
#' @seealso [`parabar::Options`], [parabar::get_option()]
#'
#' @export
