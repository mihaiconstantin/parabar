#' @title
#' Start a Backend
#'
#' @description
#' This function can be used to start a backend. Check out the **Details**
#' section for more information.
#'
#' @param cores A positive integer representing the number of cores to use
#' (i.e., the number of processes to start). This value must be between `2` and
#' `parallel::detectCores() - 1`.
#'
#' @param cluster_type A character string representing the type of cluster to
#' create. Possible values are `"fork"` and `"psock"`. Defaults to `"psock"`.
#' See the section **Cluster Type** for more information.
#'
#' @param backend_type A character string representing the type of backend to
#' create. Possible values are `"sync"` and `"async"`. Defaults to `"async"`.
#' See the section **Backend Type** for more information.
#'
#' @details
#' This function is a convenience wrapper around the lower-lever API of
#' [`parabar::parabar`] aimed at developers. More specifically, this function
#' uses the [`parabar::Specification`] class to create a specification object,
#' and the [`parabar::BackendFactory`] class to create a [`parabar::Backend`]
#' instance based on the specification object.
#'
#' @section Cluster Type:
#' The cluster type determines the type of cluster to create. The requested
#' value is validated and passed to the `type` argument of the
#' [parallel::makeCluster()] function. The following table lists the possible
#' values and their corresponding description.
#'
#' | **Cluster** | **Description**            |
#' | :---------- | :------------------------- |
#' | `"fork"`    | For Unix-based systems.    |
#' | `"psock"`   | For Windows-based systems. |
#'
#' @section Backend Type:
#' The backend type determines the type of backend to create. The requested
#' value is passed to the [`parabar::BackendFactory`] class, which returns a
#' [`parabar::Backend`] instance of the desired type. The following table lists
#' the possible backend types and their corresponding description.
#'
#' | **Backend** | **Description**          | **Implementation**        | **Progress** |
#' | :---------- | :----------------------- | :------------------------ | :----------: |
#' | `"sync"`    | A synchronous backend.   | [`parabar::SyncBackend`]  |      no      |
#' | `"async"`   | An asynchronous backend. | [`parabar::AsyncBackend`] |     yes      |
#'
#' In a nutshell, the difference between the two backend types is that for the
#' synchronous backend the cluster is created in the main process, while for the
#' asynchronous backend the cluster is created in a backend `R` process using
#' [`callr::r_session`]. Therefore, the synchronous backend is blocking the main
#' process during task execution, while the asynchronous backend is
#' non-blocking. Check out the implementations listed in the table above for
#' more information. All concrete implementations extend the
#' [`parabar::Backend`] abstract class and implement the
#' [`parabar::BackendService`] interface.
#'
#' @return
#' A [`parabar::Backend`] instance that can be used to parallelize computations.
#' The methods available on the [`parabar::Backend`] instance are defined by the
#' [`parabar::BackendService`] interface.
#'
#' @examples
#' # Create an asynchronous backend.
#' backend <- start_backend(cores = 2, cluster_type = "psock", backend_type = "async")
#'
#' # Check that the backend is active.
#' backend$active
#'
#' # Check if there is anything on the backend.
#' peek(backend)
#'
#' # Create a dummy variable.
#' name <- "parabar"
#'
#' # Export the `name` variable in the current environment to the backend.
#' export(backend, "name", environment())
#'
#' # Remove the dummy variable from the current environment.
#' rm(name)
#'
#' # Check the backend to see that the variable has been exported.
#' peek(backend)
#'
#' # Run an expression on the backend.
#' # Note that the symbols in the expression are resolved on the backend.
#' evaluate(backend, {
#'     # Print the name.
#'     print(paste0("Hello, ", name, "!"))
#' })
#'
#' # Clear the backend.
#' clear(backend)
#'
#' # Check that there is nothing on the backend.
#' peek(backend)
#'
#' # Use a basic progress bar (i.e., see `parabar::Bar`).
#' configure_bar(type = "basic", style = 3)
#'
#' # Run a task in parallel (i.e., approx. 1.25 seconds).
#' output <- par_sapply(backend, x = 1:10, fun = function(x) {
#'     # Sleep a bit.
#'     Sys.sleep(0.25)
#'
#'     # Compute and return.
#'     return(x + 1)
#' })
#'
#' # Print the output.
#' print(output)
#'
#' # Stop the backend.
#' stop_backend(backend)
#'
#' # Check that the backend is not active.
#' backend$active
#'
#' @seealso
#' [parabar::peek()], [parabar::export()], [parabar::evaluate()],
#' [parabar::clear()], [parabar::configure_bar()], [parabar::par_sapply()],
#' [parabar::par_lapply()], [parabar::par_apply()], [parabar::stop_backend()],
#' and [`parabar::BackendService`].
