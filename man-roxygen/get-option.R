#' @description
#' The [parabar::get_option()] function is a helper for retrieving the value of
#' [`parabar::parabar`] [`options`][base::options()]. If the
#' [`option`][`parabar::Options`] requested is not available in the session
#' [`base::.Options`] list, the corresponding default value set by the
#' [`parabar::Options`] [`R6::R6`] class is returned instead.
#'
#' @return
#' The [parabar::get_option()] function returns the value of the requested
#' [`option`][`parabar::Options`] present in the [`base::.Options`] list, or its
#' corresponding default value (i.e., see [`parabar::Options`]). If the
#' requested [`option`][`parabar::Options`] is not known, an error is thrown.
#'
#' @rdname option
