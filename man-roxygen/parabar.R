#' @title
#' Progress Bar for Parallel Tasks
#'
#' @details
#' The package is aimed at two audiences: (1) end-users who want to execute a
#' task in parallel in an interactive `R` session and track the execution
#' progress, and (2) `R` package developers who want to use [`parabar`] as a
#' solution for parallel processing in their packages.
#'
#' @section Users:
#' For the first category of users, [`parabar`] provides three main functions of
#' interest:
#' - [parabar::start_backend()]: creates a parallel backend for executing tasks
#'   according to the specifications provided.
#' - [parabar::stop_backend()]: stops an active backend and makes the [`R6::R6`]
#'   eligible for garbage collection.
#' - [parabar::sapply()]: is a drop-in replacement for the built-in
#'   [base::sapply()] function when no backend is provided. However, when a
#'   backend is provided, the function will execute a task in parallel on the
#'   backend, similar to the built-in function [parallel::parSapply()].
#'
#'  Additional functions [parabar::track_progress()] and
#'  [parabar::configure_bar()] can be used to toggle progress tracking and
#'  configure the progress bar, respectively. Check out the documentation for
#'  [`parabar::sapply()`][parabar::sapply()] for an example of how to use these
#'  functions.
#'
#' @section Developers:
#' For the second category of users, [`parabar`] provides a set of classes
#' (i.e., [R6::R6Class()]) that can be used to create backends (i.e.,
#' synchronous and asynchronous) and interact with them via a simple interface.
#' From a high-level perspective, the package consists of **`backends`** and
#' **`contexts`** in which these backends are employed for executing the tasks
#' in parallel.
#'
#' ### Backends
#' A **`backend`** represents a set of operations, defined by the
#' [`parabar::Service`] interface, that can be deployed on a cluster returned by
#' [parallel::makeCluster()]. Backends can be synchronous or asynchronous. The
#' former will block the execution of the current `R` session until the parallel
#' task is completed, while the latter will return immediately and the task will
#' be executed in a background `R` session.
#'
#' The [parabar::Service] interface defines the following operations:
#' [`start()`][parabar::Service], [`stop()`][parabar::Service],
#' [`clear()`][parabar::Service], [`peek()`][parabar::Service],
#' [`export()`][parabar::Service], [`evaluate()`][parabar::Service],
#' [`sapply()`][parabar::Service], and [`get_output()`][parabar::Service].
#'
#' Check out the documentation for [`parabar::Service`] for more information on
#' each method.
#'
#' ### Contexts
#' A **`context`** represents the specific conditions in which the backend
#' operations. The default, regular [`parabar::Context`] class simply forwards
#' the call to the corresponding backend method. However, a more complex context
#' can augment the operation before forwarding the call to the backend. One
#' example of a complex context is the [`parabar::ProgressDecorator`] class.
#' This class extends the regular [`parabar::Context`] class and decorates the
#' backend [`sapply()`][parabar::Service] operation to log the progress after
#' each task execution and display a progress bar.
#'
#' The following are the main classes provided by `parabar`:
#' - [`parabar::Service`]: interface for backend operations.
#' - [`parabar::SyncBackend`]: synchronous backend extending the abstract
#'   [`parabar::Backend`] class.
#' - [`parabar::AsyncBackend`]: asynchronous backend extending the abstract
#'   [`parabar::Backend`] class.
#' - [`parabar::Specification`]: backend specification used when starting a
#'   backend.
#' - [`parabar::BackendFactory`]: factory for creating backend objects.
#' - [`parabar::Context`]: default context for executing backend operations.
#' - [`parabar::ProgressDecorator`]: context for decorating the
#'   [`sapply()`][parabar::Service] operation to track and display progress.
#' - [`parabar::ContextFactory`]: factory for creating context objects.
#'
#' @section Progress Bars:
#' [`parabar::parabar`] also exposes several classes for creating and updating
#' different progress bars, namely:
#' - [`parabar::BasicBar`]: a simple, but robust, bar created via
#'   [utils::txtProgressBar()] extending the [`parabar::Bar`] abstract class.
#' - [`parabar::ModernBar`]: a modern bar created via [`progress::progress_bar`]
#'   extending the [parabar::Bar] abstract class.
#' - [`parabar::BarFactory`]: factory for creating bar objects.
#'
#' Finally, [`parabar::parabar`] uses several [base::options()] to configure the
#' behavior of the functionality it provides. For more information on the
#' options used and their see default values, see [`parabar::Options`].
#'
#' For more information about the design of [`parabar::parabar`], check out the
#' documentation and the `UML` diagram at
#' [parabar.mihaiconstantin.com](https://parabar.mihaiconstantin.com).
#'
#' @keywords internal
