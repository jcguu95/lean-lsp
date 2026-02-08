# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Updated the "Hello, world!" greeting in `Main.lean` to be more casual.

### Added
- Added `twice` function and a theorem to `Main.lean` to demonstrate LSP features.
- Added `Mathlib` dependency to use the `ring` tactic.

### Fixed
- Resolved persistent Docker build failures by optimizing layer caching, pinning a stable toolchain and dependencies, and correctly managing the build context with `.dockerignore`.

## [0.2.0] - 2026-02-08

### Changed
- Pinned `mathlib` dependency and Lean toolchain to stable versions to improve build reproducibility and reduce downloads.

### Added
- Added `Mathlib` dependency to use the `ring` tactic.
- Added `twice` function and a theorem to `Main.lean` to demonstrate LSP features.

### Fixed
- Resolved persistent Docker build failures by optimizing layer caching, pinning a stable toolchain and dependencies, and correctly managing the build context with `.dockerignore`.

## [0.1.0] - 2026-02-08

### Added
- Implement a basic "Hello, world!" program in `Main.lean`.
- Configure `lakefile.lean` to build an executable from `Main.lean`.
- Update `Dockerfile` to run `lake build` to cache the toolchain and build artifacts.
