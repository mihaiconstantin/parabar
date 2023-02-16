#' @title
#' Configure The Progress Bar
#'
#' @description
#' This function can be used to conveniently configure the progress bar by
#' adjusting the `progress_bar_config` field of the
#' [`Options`][`parabar::Options`] instance in the [`base::.Options`] list.
#'
#' @param type A character string specifying the type of progress bar to be used
#'  with compatible [`backends`][`parabar::Backend`]. Possible values are
#' `"modern"` and `"basic"`. The default value is `"modern"`.
#'
#' @param ... A list of named arguments used to configure the progress bar. See
#' the **Details** section for more information.
#'
#' @details
#' The optional `...` named arguments depend on the `type` of progress bar being
#' configured. When `type = "modern"`, the `...` take the named arguments of the
#' [`progress::progress_bar`] class. When `type = "basic"`, the `...` take the
#' named arguments of the [utils::txtProgressBar()] built-in function. See the
#' **Examples** section for a demonstration.
#'
#' @return
#' The function returns void. It throws an error if the requested bar `type` is
#' not supported.
#'
#' @examples
#' # Set the default package options.
#' set_default_options()
#'
#' # Get the progress bar type from options.
#' get_option("progress_bar_type")
#'
#' # Get the progress bar configuration from options.
#' get_option("progress_bar_config")
#'
#' # Adjust the format of the `modern` progress bar.
#' configure_bar(type = "modern", format = "[:bar] :percent")
#'
#' # Check that the configuration has been updated in the options.
#' get_option("progress_bar_config")
#'
#' # Change to and adjust the style of the `basic` progress bar.
#' configure_bar(type = "basic", style = 3)
#'
#' # Check that the configuration has been updated in the options.
#' get_option("progress_bar_type")
#' get_option("progress_bar_config")
#'
#' @seealso
#' [`progress::progress_bar`], [utils::txtProgressBar()],
#' [parabar::set_default_options()], [parabar::get_option()],
#' [parabar::set_option()]
