import aonyx/graph
import aonyx/graph/path/astar
import gleam/option

/// Finds the shortest path from start to goal using A* algorithm.
/// 
/// The heuristic function estimates remaining distance to goal and must be admissible
/// (never overestimate). Using a zero heuristic makes this equivalent to Dijkstra's algorithm.
/// 
/// Returns a list of nodes from start to goal, or None if no path exists.
/// 
/// Note: Does not support negative edge weights (they are clamped to 0.0).
/// Edge weights of None are treated as 1.0.
///
/// ## Examples
///
/// ```gleam
/// import aonyx/graph
/// import aonyx/graph/edge
/// import aonyx/graph/node
///
/// // Create a graph representing a grid with coordinates as values
/// 
/// let nodes = [
///   node.new("A") |> node.with_value(#(0, 0))
///   node.new("B") |> node.with_value(#(1, 0))
///   node.new("C") |> node.with_value(#(2, 0))
///   node.new("D") |> node.with_value(#(0, 1))
///   node.new("E") |> node.with_value(#(1, 1))
///   node.new("F") |> node.with_value(#(2, 1))
/// ]
/// 
/// let edges = [
///  edge.new("A", "B") |> edge.with_weight(1.0),
///  edge.new("B", "C") |> edge.with_weight(1.0),
///  edge.new("D", "E") |> edge.with_weight(1.0),
///  edge.new("E", "F") |> edge.with_weight(1.0),
///  edge.new("A", "D") |> edge.with_weight(1.0),
///  edge.new("B", "E") |> edge.with_weight(1.0),
///  edge.new("C", "F") |> edge.with_weight(1.0),
///  edge.new("A", "E") |> edge.with_weight(1.5),
///  edge.new("B", "F") |> edge.with_weight(1.5),
/// ]
/// 
/// let graph =
///   graph.new()
///   |> list.fold(nodes, _, insert_node)
///   |> list.fold(edges, _, insert_edge)
/// 
/// // Define Manhattan distance heuristic for our grid
/// fn manhattan_distance(from, to) {
///   let #(x1, y1) = from
///   let #(x2, y2) = to
///   int.absolute_value(x2 - x1) + int.absolute_value(y2 - y1) |> int.to_float
/// }
///
/// find_path(graph, "A", "F", manhattan_distance)
/// // -> Some(["A", "B", "C", "F"]) or Some(["A", "D", "E", "F"])
/// ```
///
/// ```gleam
/// // Using zero heuristic (equivalent to Dijkstra's algorithm)
/// find_path(graph, "A", "F", fn(_, _) { 0.0 })
/// // -> Some(["A", "B", "C", "F"]) or Some(["A", "D", "E", "F"])
/// ```
@deprecated("Use aonyx/graph/path/astar instead")
pub fn find_path(
  graph: graph.Graph(key, value, label),
  start: key,
  goal: key,
  heuristic: fn(value, value) -> Float,
) -> option.Option(List(key)) {
  astar.find_path(graph, start, goal, heuristic)
}
