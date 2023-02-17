#' @include Exception.R BasicBar.R ModernBar.R

#' @title
#' BackendFactory
#'
#' @description
#' This class is a factory that provides concrete implementations of the
#' [`parabar::Bar`] abstract class.
#'
#' @examples
#' # Create a bar factory.
#' bar_factory <- BarFactory$new()
#'
#' # Get a modern bar instance.
#' bar <- bar_factory$get("modern")
#'
#' # Check the class of the bar instance.
#' class(bar)
#'
#' # Get a basic bar instance.
#' bar <- bar_factory$get("basic")
#'
#' # Check the class of the bar instance.
#' class(bar)
#'
#' @seealso
#' [`parabar::Bar`], [`parabar::BasicBar`], and [`parabar::ModernBar`].
#'
#' @export
BarFactory <- R6::R6Class("BarFactory",
    public = list(
        #' @description
        #' Obtain a concrete implementation of the abstract [`parabar::Bar`]
        #' class of the specified type.
        #'
        #' @param type A character string specifying the type of the
        #' [`parabar::Bar`] to instantiate. Possible values are `"modern"` and
        #' `"basic"`. See the **Details** section for more information.
        #'
        #' @details
        #' When `type = "modern"` a [`parabar::ModernBar`] instance is created
        #' and returned. When `type = "basic"` a [`parabar::BasicBar`] instance
        #' is provided instead.
        #'
        #' @return
        #' A concrete implementation of the class [`parabar::Bar`]. It throws an
        #' error if the requested bar `type` is not supported.
        get = function(type) {
            return(
                switch(type,
                    basic = BasicBar$new(),
                    modern = ModernBar$new(),
                    Exception$feature_not_developed()
                )
            )
        }
    )
)
