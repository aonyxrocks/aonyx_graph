# Changelog

All notable changes to the aonyx_graph project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Future changes will be listed here

## [1.0.1] - 2025-04-21

### Changed
- Simplified release workflow by removing unnecessary steps
- Updated version format in CI pipeline
- Improved release workflow permissions

### Documentation
- Removed contributing section from README
- Added separate CONTRIBUTING.md guidelines

## [1.0.0] - 2025-04-20

### Added
- Setup release pipeline
- Added conventional commits enforcement using git hook

### Changed
- Refactored get_edges function to remove redundant mapping

## [0.1.0] - 2025-04-20

### Added
- Initial release of aonyx_graph
- Core graph data structure with node and edge support
- Functions to add, remove, and update nodes and edges
- Neighbor discovery (incoming, outgoing, and all neighbors)
- Path finding using Dijkstra's algorithm
- Node and edge customization (labels, weights, values)
- Support for automatic node creation when adding edges

[Unreleased]: https://github.com/aonyxrocks/aonyx_graph/compare/v1.0.1...HEAD
[1.0.1]: https://github.com/aonyxrocks/aonyx_graph/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/aonyxrocks/aonyx_graph/compare/v0.1.0...v1.0.0
[0.1.0]: https://github.com/aonyxrocks/aonyx_graph/releases/tag/v0.1.0