#' @title
#' Get or Set Package Option
#'
#' @description
#' The [parabar::set_option()] function is a helper for setting
#' [`parabar::parabar`] [`options`][base::options()]. The function adjusts the
#' fields of the [`parabar::Options`] instance stored in the [`base::.Options`]
#' list. If no [`parabar::Options`] instance is present in the
#' [`base::.Options`] list, a new one is created.
#'
#' @param option A character string representing the name of the option to
#' retrieve or adjust. See the public fields of [`R6::R6`] class
#' [`parabar::Options`] for the list of available [`parabar::parabar`]
#' [`options`][base::options()].
#'
#' @param value The value to set the [`option`][`parabar::Options`] to.
#'
#' @return
#' The [parabar::set_option()] function returns void. It throws an error if the
#' requested [`option`][`parabar::Options`] to be adjusted is not known.
#'
#' @examples
#' # Get the status of progress tracking.
#' get_option("progress_track")
#'
#' # Set the status of progress tracking to `FALSE`.
#' set_option("progress_track", FALSE)
#'
#' # Get the status of progress tracking again.
#' get_option("progress_track")
#'
#' # Restore default options.
#' set_default_options()
#'
#' # Get the status of progress tracking yet again.
#' get_option("progress_track")
#'
#' @seealso
#' [`parabar::Options`], [parabar::set_default_options()], [base::options()],
#' and [base::getOption()].
#'
#' @rdname option
