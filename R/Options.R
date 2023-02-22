#' @title
#' Class for Package Options
#'
#' @description
#' This class holds public fields that represent the package
#' [`options`][base::options()] used to configure the default behavior of the
#' functionality [`parabar::parabar`] provides.
#'
#' @details
#' An instance of this class is automatically created and stored in the session
#' [`base::.Options`] at load time. This instance can be accessed and changed
#' via [`getOption("parabar")`][base::getOption()]. Specific package
#' [`options`][base::options()] can be retrieved using the helper function
#' [parabar::get_option()].
#'
#' @examples
#' # Set the default package options (i.e., automatically set at load time).
#' set_default_options()
#'
#' # First, get the options instance from the session options.
#' parabar <- getOption("parabar")
#'
#' # Then, disable progress tracking.
#' parabar$progress_track <- FALSE
#'
#' # Check that the change was applied (i.e., `progress_track: FALSE`).
#' getOption("parabar")
#'
#' # To restore defaults, set the default options again.
#' set_default_options()
#'
#' # Check that the change was applied (i.e., `progress_track: FALSE`).
#' getOption("parabar")
#'
#' # We can also use the built-in helpers to get and set options more conveniently.
#'
#' # Get the progress tracking option.
#' get_option("progress_track")
#'
#' # Set the progress tracking option to `TRUE`.
#' set_option("progress_track", TRUE)
#'
#' # Check that the change was applied (i.e., `progress_track: TRUE`).
#' get_option("progress_track")
#'
#' @seealso [parabar::get_option()], [parabar::set_option()], and
#' [parabar::set_default_options()].
#'
#' @export
Options <- R6::R6Class("Options",
    cloneable = FALSE,

    public = list(
        #' @field progress_track A logical value indicating whether progress
        #' tracking should be enabled (i.e., `TRUE`) or disabled  (i.e.,
        #' `FALSE`) globally for compatible backends. The default value is
        #' `TRUE`.
        progress_track = TRUE,

        #' @field progress_timeout A numeric value indicating the timeout (i.e.,
        #' in seconds) between subsequent checks of the log file for new progress
        #' records. The default value is `0.001`.
        progress_timeout = 0.001,

        #' @field progress_bar_type A character string indicating the default
        #' bar type to use with compatible backends. Possible values are
        #' `"modern"` (the default) or `"basic"`.
        progress_bar_type = "modern",

        #' @field progress_bar_config A list of lists containing the default bar
        #' configuration for each supported bar engine. Elements of these lists
        #' represent arguments for the corresponding bar engines. Currently, the
        #' supported bar engines are:
        #' - `modern`: The [`progress::progress_bar`] engine, with the following
        #'   default configuration:
        #'   - `show_after = 0`
        #'   - `format = "> completed :current out of :total tasks [:percent] [:elapsed]"`
        #' - `basic`: The [`utils::txtProgressBar`] engine, with no default
        #'   configuration.
        progress_bar_config = list(
            # See `progress::progress_bar`.
            modern = list(
                show_after = 0,
                format = " > completed :current out of :total tasks [:percent] [:elapsed]"
            ),

            # See `utils::txtProgressBar`.
            basic = list()
        )
    )
)
