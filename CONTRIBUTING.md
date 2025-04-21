# Contributing to aonyx_graph

This document contains information for developers who want to contribute to the aonyx_graph project.

## Development

```sh
gleam test # Run the tests
gleam run -m aonyx_graph_examples # Run the examples
```

## Git Hooks

This repository uses Git hooks to enforce certain standards and automate tasks. To set up the hooks in your local repository:

```sh
git config core.hooksPath .githooks
```

### Conventional Commits

This project follows the [Conventional Commits](https://www.conventionalcommits.org/) specification for commit messages. This is enforced through a pre-commit hook in the `.githooks/commit-msg` file.

The commit message format should be:
```
<type>[optional scope]: <description>
```

Valid types are:
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `build`: Changes that affect the build system or external dependencies
- `ci`: Changes to CI configuration files and scripts
- `chore`: Other changes that don't modify src or test files
- `revert`: Reverts a previous commit

### README Examples

A pre-commit hook automatically updates the code examples in README.md with the latest content from the `test/aonyx_graph_examples.gleam` file. After setting up the hooks, whenever you make a commit, this hook will automatically update the README.md with the latest code examples and include it in your commit.

## Semantic Versioning

This project follows [Semantic Versioning](https://semver.org/). The version number is automatically determined based on conventional commit messages through the GitHub Actions workflow (`.github/workflows/release.yml`).

- **Major version (X.0.0)**: Breaking changes, indicated by commits with `BREAKING CHANGE:` in the footer or a `!` after the type/scope
- **Minor version (0.X.0)**: New features, indicated by `feat:` commits
- **Patch version (0.0.X)**: Bug fixes and other minor changes, indicated by `fix:` commits

The workflow automatically:
1. Determines the next version based on commit history
2. Updates the version in `gleam.toml`
3. Publishes the package to Hex.pm

## Changelog

The project maintains a CHANGELOG.md file based on the [Keep a Changelog](https://keepachangelog.com/) format. When contributing:

1. For new features, fixes, or changes, add an entry to the appropriate section under `[Unreleased]`
2. Follow the existing format: `- Brief description of the change`
3. During releases, the unreleased changes will be moved to a new version section

## Code Structure

- `src/aonyx/graph.gleam` - Main graph module with core functionality
- `src/aonyx/graph/` - Sub-modules for specialized functionality
  - `dijkstra.gleam` - Path finding algorithm
  - `edge.gleam` - Edge data structure and operations
  - `node.gleam` - Node data structure and operations
- `test/` - Tests and examples
  - `aonyx_graph_test.gleam` - Unit tests
  - `aonyx_graph_examples.gleam` - Example code (also used in README)