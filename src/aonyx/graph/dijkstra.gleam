import aonyx/graph
import aonyx/graph/astar
import gleam/option

/// Finds the shortest path from start to goal using Dijkstra's algorithm.
/// 
/// This implementation uses A* algorithm internally with a zero heuristic function.
/// The returned path is ordered from start to goal node, or None if no path exists.
/// 
/// Note: Does not support negative edge weights (they are clamped to 0.0).
/// Edge weights of None are treated as 1.0.
pub fn find_path(
  graph: graph.Graph(key, value, label),
  start: key,
  goal: key,
) -> option.Option(List(key)) {
  astar.find_path(graph, start, goal, fn(_, _) { 0.0 })
}
