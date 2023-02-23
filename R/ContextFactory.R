#' @include Exception.R Context.R ProgressDecorator.R

# Factory for fetching context instances (i.e., for managing and decorating backends).
#' @title BackendFactory
#'
#' @description
#' This class is a factory that provides instances of the [`parabar::Context`]
#' class.
#'
#' @examples
#' # Create a context factory.
#' context_factory <- ContextFactory$new()
#'
#' # Get a regular context instance.
#' context <- context_factory$get("regular")
#'
#' # Check the class of the context instance.
#' class(context)
#'
#' # Get a progress context instance.
#' context <- context_factory$get("progress")
#' class(context)
#'
#' @seealso
#' [`parabar::Context`], [`parabar::ProgressDecorator`], [`parabar::Service`],
#' and [`parabar::Backend`]
#'
#' @export
ContextFactory <- R6::R6Class("ContextFactory",
    public = list(
        #' @description
        #' Obtain instances of the [`parabar::Context`] class.
        #'
        #' @param type A character string specifying the type of the
        #' [`parabar::Context`] to instantiate. Possible values are `"regular"`
        #' and `"progress"`. See the **Details** section for more information.
        #'
        #' @details
        #' When `type = "regular"` a [`parabar::Context`] instance is created
        #' and returned. When `type = "progress"` a
        #' [`parabar::ProgressDecorator`] instance is provided instead.
        #'
        #' @return
        #' An object of type [`parabar::Context`]. It throws an error if the
        #' requested context `type` is not supported.
        get = function(type) {
            return(
                switch(type,
                    regular = Context$new(),
                    progress = ProgressDecorator$new(),
                    Exception$feature_not_developed()
                )
            )
        }
    )
)
