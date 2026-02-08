# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Pinned `mathlib` dependency and Lean toolchain to stable versions to improve build reproducibility and reduce downloads.

### Added
- Added `Mathlib` dependency to use the `ring` tactic.
- Added `twice` function and a theorem to `Main.lean` to demonstrate LSP features.

### Fixed
- The Docker build now runs `lake update` to fetch dependencies before building, and the Dockerfile is optimized for layer caching.

## [0.1.0] - 2026-02-08

### Added
- Implement a basic "Hello, world!" program in `Main.lean`.
- Configure `lakefile.lean` to build an executable from `Main.lean`.
- Update `Dockerfile` to run `lake build` to cache the toolchain and build artifacts.
