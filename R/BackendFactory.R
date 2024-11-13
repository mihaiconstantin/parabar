#' @include Exception.R SyncBackend.R AsyncBackend.R

#' @title BackendFactory
#'
#' @description
#' This class is a factory that provides concrete implementations of the
#' [`parabar::Backend`] abstract class.
#'
#' @examples
#' # Create a backend factory.
#' backend_factory <- BackendFactory$new()
#'
#' # Get a synchronous backend instance.
#' backend <- backend_factory$get("sync")
#'
#' # Check the class of the backend instance.
#' class(backend)
#'
#' # Get an asynchronous backend instance.
#' backend <- backend_factory$get("async")
#'
#' # Check the class of the backend instance.
#' class(backend)
#'
#' @seealso
#' [`parabar::BackendService`], [`parabar::Backend`], [`parabar::SyncBackend`],
#' [`parabar::AsyncBackend`], and [`parabar::ContextFactory`].
#'
#' @export
BackendFactory <- R6::R6Class("BackendFactory",
    public = list(
        #' @description
        #' Obtain a concrete implementation of the abstract [`parabar::Backend`]
        #' class of the specified type.
        #'
        #' @param type A character string specifying the type of the
        #' [`parabar::Backend`] to instantiate. Possible values are `"sync"` and
        #' `"async"`. See the **Details** section for more information.
        #'
        #' @details
        #' When `type = "sync"` a [`parabar::SyncBackend`] instance is created
        #' and returned. When `type = "async"` an [`parabar::AsyncBackend`]
        #' instance is provided instead.
        #'
        #' @return
        #' A concrete implementation of the class [`parabar::Backend`]. It
        #' throws an error if the requested backend `type` is not supported.
        get = function(type) {
            return(
                switch(type,
                    sync = SyncBackend$new(),
                    async = AsyncBackend$new(),
                    Exception$feature_not_developed()
                )
            )
        }
    )
)
