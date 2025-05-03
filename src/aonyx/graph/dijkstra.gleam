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
///
/// ## Examples
///
/// ```gleam
/// import aonyx/graph
/// import aonyx/graph/edge
/// 
/// let edges = [
///   edge.new("A", "B") |> edge.with_weight(1.0),
///   edge.new("B", "C") |> edge.with_weight(2.0),
///   edge.new("A", "C") |> edge.with_weight(5.0),
/// ]
///
/// let graph =
///   graph.new()
///   |> list.fold(edges, _, graph.insert_edge)
///
/// find_path(graph, "A", "C")
/// // -> Some(["A", "B", "C"]) - Path through B is shorter (3.0) than direct path (5.0)
/// ```
///
/// ```gleam
/// // No path between nodes
/// import aonyx/graph
/// import aonyx/graph/edge
///
/// let graph =
///   graph.new()
///   |> graph.insert_edge(edge.new("A", "B"))
///   |> graph.insert_edge(edge.new("C", "D"))
///
/// find_path(graph, "A", "D")
/// // -> None
/// ```
pub fn find_path(
  graph: graph.Graph(key, value, label),
  start: key,
  goal: key,
) -> option.Option(List(key)) {
  astar.find_path(graph, start, goal, fn(_, _) { 0.0 })
}
