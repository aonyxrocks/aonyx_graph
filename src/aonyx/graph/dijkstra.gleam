import aonyx/graph
import aonyx/graph/astar
import gleam/option

/// Uses Dijkstra's algorithm to exhaustively search for the shortest path from start to goal in the graph.
/// If a path can be found, it is guaranteed to be the shortest one. This uses the A* algorithm internally with a heuristic function returning 0.0 for all nodes.
/// The returned list represents the path in order from the start node to the goal node, or None when no path can be found.
/// 
/// Note: Since Dijkstra's algorithm is susceptible to negative cycles, negative weights are clamped to 0.0 to avoid infinite loops. None values are treated as 1.0.
pub fn find_path(
  graph: graph.Graph(key, value, label),
  start: key,
  goal: key,
) -> option.Option(List(key)) {
  astar.find_path(graph, start, goal, fn(_, _) { 0.0 })
}
