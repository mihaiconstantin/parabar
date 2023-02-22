#' @include Exception.R

#' @title
#' Bar
#'
#' @description
#' This is an abstract class that defines the pure virtual methods a concrete
#' bar must implement.
#'
#' @details
#' This class cannot be instantiated. It needs to be extended by concrete
#' subclasses that implement the pure virtual methods. Instances of concrete
#' backend implementations can be conveniently obtained using the
#' [`parabar::BarFactory`] class.
#'
#' @seealso
#' [`parabar::BasicBar`], [`parabar::ModernBar`], and [`parabar::BarFactory`].
#'
#' @export
Bar <- R6::R6Class("Bar",
    private = list(
        .bar = NULL
    ),

    public = list(
        #' @description
        #' Create a new [`parabar::Bar`] object.
        #'
        #' @return
        #' Instantiating this call will throw an error.
        initialize = function() {
            Exception$abstract_class_not_instantiable(self)
        },

        #' @description
        #' Create a progress bar.
        #'
        #' @param total The total number of times the progress bar should tick.
        #'
        #' @param initial The starting point of the progress bar.
        #'
        #' @param ... Additional arguments for the bar creation. See the
        #' **Details** section for more information.
        #'
        #' @details
        #' The optional `...` named arguments depend on the specific concrete
        #' implementation (i.e., [`parabar::BasicBar`] or
        #' [`parabar::ModernBar`]).
        #'
        #' @return
        #' This method returns void. The resulting bar is stored in the private
        #' field `.bar`, accessible via the active binding `engine`.
        create = function(total, initial, ...) {
            Exception$method_not_implemented()
        },

        #' @description
        #' Update the progress bar.
        #'
        #' @param current The position the progress bar should be at (e.g., 30
        #' out of 100), usually the index in a loop.
        update = function(current) {
            Exception$method_not_implemented()
        },

        #' @description
        #' Terminate the progress bar.
        terminate = function() {
            Exception$method_not_implemented()
        }
    ),

    active = list(
        #' @field engine The bar engine.
        engine = function() { return(private$.bar) }
    )
)
