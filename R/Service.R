#' @include Exception.R

#' @title
#' Service
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
Service <- R6::R6Class("Service",
    public = list(
        #' @description
        #' Create a new [`parabar::Service`] object.
        #'
        #' @return
        #' Instantiating this call will throw an error.
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
        #' Run a task on the backend akin to [parallel::parSapply()].
        #'
        #' @param x A vector (i.e., usually of integers) to pass to the `fun`
        #' function.
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
        #' Get the output of the task execution.
        #'
        #' @details
        #' This method fetches the output of the task execution after calling
        #' the `sapply()` method. It returns the output and immediately removes
        #' it from the backend. Therefore, subsequent calls to this method are
        #' not advised. This method should be called after the execution of a
        #' task.
        #'
        #' @return
        #' A vector or list of the same length as `x` containing the results of
        #' the `fun`. It resembles the format of [base::sapply()].
        get_output = function() {
            Exception$method_not_implemented()
        }
    )
)
