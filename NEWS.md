# Changelog
All notable changes to this project will be documented in this file. The format
is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased
### Added
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
