# Changelog

All notable changes to the aonyx_graph project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Removed
- Deprecated `graph/astar` and `graph/dijkstra` modules (replaced by `graph/path/astar` and `graph/path/dijkstra` in v2.0.0)

### Documentation
- Cleaned up comments and examples across source files, README, and tests

## [2.0.0] - 2026-04-28

### Breaking Changes
- `Node.value` is now a required value instead of `Option(value)` — callers must always supply a value
- `node.new` now requires a `value` argument: `node.new(key, value)`
- `node.with_value` replaced by `node.replace_value`
- `node.without_value` removed
- `insert_edge` now requires a `default_node_value` argument used when auto-creating missing nodes
- `remove_node` now accepts a `NodeKey(key)` instead of a `Node(key, value)`

### Added
- `try_insert_edge` — inserts an edge and returns `Result(Graph, Nil)`; returns an error if either endpoint node does not exist
- Breadth-first search (BFS) and depth-first search (DFS) traversal functions
- `.editorconfig` for consistent coding styles across editors

### Changed
- A* and Dijkstra implementations reorganised into separate `path/astar` and `path/dijkstra` modules
- Minimum required Gleam version bumped to 1.16.0
- Minimum required `gleam_stdlib` version bumped to 1.0.0

### Fixed
- Ensure heuristic value is non-negative in A* pathfinding

### Documentation
- Added examples to graph, edge, node, and pathfinding functions
- Improved documentation for pathfinding functions

## [1.1.0] - 2025-05-01

### Added
- A* algorithm

## [1.0.3] - 2025-04-25

### Fixed
- Re-inserting an existing node with different edges left the graph in an inconsistent state

## [1.0.2] - 2025-04-22

### Fixed
- Dijkstra's algorithm implementation now respects edge weights

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

[Unreleased]: https://github.com/aonyxrocks/aonyx_graph/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/aonyxrocks/aonyx_graph/compare/v1.1.0...v2.0.0
[1.1.0]: https://github.com/aonyxrocks/aonyx_graph/compare/v1.0.3...v1.1.0
[1.0.3]: https://github.com/aonyxrocks/aonyx_graph/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/aonyxrocks/aonyx_graph/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/aonyxrocks/aonyx_graph/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/aonyxrocks/aonyx_graph/compare/v0.1.0...v1.0.0
[0.1.0]: https://github.com/aonyxrocks/aonyx_graph/releases/tag/v0.1.0