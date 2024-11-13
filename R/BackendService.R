#' @include Exception.R

#' @title
#' BackendService
#'
#' @description
#' This is an interface that defines the operations available on a
#' [`parabar::Backend`] implementation. Backend implementations and the
#' [`parabar::Context`] class must implement this interface.
#'
#' @seealso
#' [`parabar::Backend`], [`parabar::SyncBackend`], [`parabar::AsyncBackend`],
#' and [`parabar::Context`].
#'
#' @export
BackendService <- R6::R6Class("BackendService",
    public = list(
        #' @description
        #' Create a new [`parabar::BackendService`] object.
        #'
        #' @return
        #' Instantiating this class will throw an error.
        initialize = function() {
            Exception$abstract_class_not_instantiable(self)
        },

        #' @description
        #' Start the backend.
        #'
        #' @param specification An object of class [`parabar::Specification`]
        #' that contains the backend configuration.
        #'
        #' @return
        #' This method returns void. The resulting backend must be stored in the
        #' `.cluster` private field on the [`parabar::Backend`] abstract class,
        #' and accessible to any concrete backend implementations via the active
        #' binding `cluster`.
        start = function(specification) {
            Exception$method_not_implemented()
        },

        #' @description
        #' Stop the backend.
        #'
        #' @return
        #' This method returns void.
        stop = function() {
            Exception$method_not_implemented()
        },

        #' @description
        #' Remove all objects from the backend. This function is equivalent to
        #' calling `rm(list = ls(all.names = TRUE))` on each node in the
        #' backend.
        #'
        #' @details
        #' This method is ran by default when the backend is started.
        #'
        #' @return
        #' This method returns void.
        clear = function() {
            Exception$method_not_implemented()
        },

        #' @description
        #' Inspect the backend for variables available in the `.GlobalEnv`.
        #'
        #' @return
        #' This method returns a list of character vectors, where each element
        #' corresponds to a node in the backend. The character vectors contain
        #' the names of the variables available in the `.GlobalEnv` on each
        #' node.
        peek = function() {
            Exception$method_not_implemented()
        },

        #' @description
        #' Export variables from a given environment to the backend.
        #'
        #' @param variables A character vector of variable names to export.
        #'
        #' @param environment An environment object from which to export the
        #' variables.
        #'
        #' @return This method returns void.
        export = function(variables, environment) {
            Exception$method_not_implemented()
        },

        #' @description
        #' Evaluate an arbitrary expression on the backend.
        #'
        #' @param expression An unquoted expression to evaluate on the backend.
        #'
        #' @return
        #' This method returns the result of the expression evaluation.
        evaluate = function(expression) {
            Exception$method_not_implemented()
        },

        #' @description
        #' Run a task on the backend akin to [`parallel::parSapply()`].
        #'
        #' @param x An atomic vector or list to pass to the `fun` function.
        #'
        #' @param fun A function to apply to each element of `x`.
        #'
        #' @param ... Additional arguments to pass to the `fun` function.
        #'
        #' @return
        #' This method returns void. The output of the task execution must be
        #' stored in the private field `.output` on the [`parabar::Backend`]
        #' abstract class, and is accessible via the `get_output()` method.
        sapply = function(x, fun, ...) {
            Exception$method_not_implemented()
        },

        #' @description
        #' Run a task on the backend akin to [`parallel::parLapply()`].
        #'
        #' @param x An atomic vector or list to pass to the `fun` function.
        #'
        #' @param fun A function to apply to each element of `x`.
        #'
        #' @param ... Additional arguments to pass to the `fun` function.
        #'
        #' @return
        #' This method returns void. The output of the task execution must be
        #' stored in the private field `.output` on the [`parabar::Backend`]
        #' abstract class, and is accessible via the `get_output()` method.
        lapply = function(x, fun, ...) {
            Exception$method_not_implemented()
        },

        #' @description
        #' Run a task on the backend akin to [`parallel::parApply()`].
        #'
        #' @param x An array to pass to the `fun` function.
        #'
        #' @param margin A numeric vector indicating the dimensions of `x` the
        #' `fun` function should be applied over. For example, for a matrix,
        #' `margin = 1` indicates applying `fun` rows-wise, `margin = 2`
        #' indicates applying `fun` columns-wise, and `margin = c(1, 2)`
        #' indicates applying `fun` element-wise. Named dimensions are also
        #' possible depending on `x`. See [`parallel::parApply()`] and
        #' [`base::apply()`] for more details.
        #'
        #' @param fun A function to apply to `x` according to the `margin`.
        #'
        #' @param ... Additional arguments to pass to the `fun` function.
        #'
        #' @return
        #' This method returns void. The output of the task execution must be
        #' stored in the private field `.output` on the [`parabar::Backend`]
        #' abstract class, and is accessible via the `get_output()` method.
        apply = function(x, margin, fun, ...) {
            Exception$method_not_implemented()
        },

        #' @description
        #' Get the output of the task execution.
        #'
        #' @param ... Additional optional arguments that may be used by concrete
        #' implementations.
        #'
        #' @details
        #' This method fetches the output of the task execution after calling
        #' the `sapply()` method. It returns the output and immediately removes
        #' it from the backend. Therefore, subsequent calls to this method are
        #' not advised. This method should be called after the execution of a
        #' task.
        #'
        #' @return
        #' A vector, matrix, or list of the same length as `x`, containing the
        #' results of the `fun`. The output format differs based on the specific
        #' operation employed. Check out the documentation for the `apply`
        #' operations of [`parallel::parallel`] for more information.
        get_output = function(...) {
            Exception$method_not_implemented()
        }
    )
)
