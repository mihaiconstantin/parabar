#' @title
#' Get Package Option Or Default Value
#'
#' @description
#' This function is a helper for retrieving the value of [`parabar::parabar`]
#' [`options`][base::options()]. If the [`option`][`parabar::Options`] requested
#' is not available in the session [`base::.Options`] list, the corresponding
#' default value set by the [`parabar::Options`] [`R6::R6`] class is returned
#' instead.
#'
#' @param option A character string representing the name of the option to
#' retrieve. See the public fields of [`R6::R6`] class [`parabar::Options`] for
#' the list of available [`parabar::parabar`] [`options`][base::options()].
#'
#' @return
#' The value of the requested [`option`][`parabar::Options`] present in the
#' [`base::.Options`] list, or the corresponding default value (i.e., see
#' [`parabar::Options`]). If the requested [`option`][`parabar::Options`] is not
#' known, an error is thrown.
#'
#' @seealso
#' [`parabar::Options`], [parabar::set_default_options()], [base::options()],
#' [base:getOptions()]
