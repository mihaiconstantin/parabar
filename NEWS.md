# Changelog
All notable changes to this project will be documented in this file. The format
is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased
### Added
- Add classes to work with synchronous and asynchronous backends:
  - `Service`: represents an *interface* that all concrete backends must
    implement. It contains the methods (i.e., operations) that can be requested
    from a given backend instance. These methods form the main API of `parabar`.
  - `Backend`: represents an abstract class that implements the `Service`
    interface. It contains fields and methods relevant to all concrete backend
    implementations that extend the class.
  - `SyncBackend`: represents a concrete implementation for a synchronous
    backend. When executing a task in parallel via the `sapply` method, the
    caller process (i.e., usually the interactive `R` session) is blocked until
    the task finishes executing.
  - `AsyncBackend`: represents a concrete implementation for an asynchronous
    backend. After lunching a task in parallel via the `sapply` method, the
    method returns immediately leaving the caller process (e.g., the interactive
    `R` session) free. The computation of the task is offloaded to a permanent
    background `R` session. One can read the state of the task using the public
    field (i.e., active binding) `task_state`. Furthermore, the results can be
    fetched from the background session using the `get_output` method, which can
    either block the main process to wait for the results, or attempt to fetch
    them immediately and throw an error if not successful.
  - `Specification`: represents an auxiliary class that encapsulates the logic
    for determining the type of cluster to create (i.e., via
    `parallel::makeCluster`), and the number of nodes (i.e., `R` processes) for
    the cluster.
- Add `Helper`, `Warning`, and `Exception` `R6` classes. These classes contain
  static member methods that provide useful utilities, handle warning messages,
  and throw informative errors, respectively.
- Add `UML` diagram for package classes. The classes provided by `parabar` can
  be split in three categories, namely (1) backend classes responsible for
  managing clusters, (2) context classes that decorate backend objects with
  additional functionality (e.g., progress tracking), and (3) progress bar
  classes providing a common interface for creating and interacting with various
  progress bars.

## 0.0.1
### Added
- Add `Bar` abstraction for working with progress bars in `R`. Currently, two
  types of of progress bars are supported (i.e., `BasicBar` and `ModernBar`).
  `BasicBar` uses as engine the `utils::txtProgressBar`, and `ModernBar` relies
  on the `R6` class obtained from `progress::progress_bar`. Specific concrete of
  these bar types can be requested from the `BarFactory`.
