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
#' [`parabar::Backend`] abstract class and implement the [`parabar::Service`]
#' interface.
#'
#' @return
#' A [`parabar::Backend`] instance that can be used to parallelize computations.
#' The methods available on the [`parabar::Backend`] instance are defined by the
#' [`parabar::Service`] interface.
#'
#' @examples
#' # Create an asynchronous backend.
#' backend <- start_backend(cores = 2, cluster_type = "psock", backend_type = "async")
#'
#' # Check if there is anything on the backend.
#' backend$peek()
#'
#' # Create a dummy variable.
#' name <- "parabar"
#'
#' # Export the variable to the backend.
#' backend$export("name")
#'
#' # Run an expression on the backend.
#' backend$evaluate({
#'     # Print the name.
#'     print(paste0("Hello, ", name, "!"))
#' })
#'
#' # Run a task in parallel (i.e., approx. 1.25 seconds).
#' backend$sapply(
#'     x = 1:10,
#'     fun = function(x) {
#'         # Sleep a bit.
#'         Sys.sleep(0.25)
#'
#'         # Compute something.
#'         output <- x + 1
#'
#'         # Return the result.
#'         return(output)
#'     }
#' )
#'
#' # Right know the main process is free and the task is executing on a `PSOCK`
#' # cluster started in a background `R` session.
#'
#' # Wait for the task to finish (i.e., by blocking the main process).
#' backend$get_output(wait = TRUE)
#'
#' # Clear the backend.
#' backend$clear()
#'
#' # Check that there is nothing on the cluster.
#' backend$peek()
#'
#' # Stop the backend.
#' backend$stop()
#'
#' # Check that the backend is not active.
#' backend$active
#'
#' @seealso
#' [parabar::stop_backend()], [`parabar::Service`], [`parabar::Backend`], and
#' [`parabar::BackendFactory`].