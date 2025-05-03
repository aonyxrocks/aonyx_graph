import aonyx/graph
import aonyx/graph/node
import gleam/dict
import gleam/float
import gleam/list
import gleam/option
import gleam/order
import gleam/result
import gleam/set

type Node(key) {
  Node(
    key: key,
    previous: option.Option(key),
    distance: Float,
    heuristic: Float,
  )
}

type PathSearch(key) {
  PathSearch(
    get_neighbors: fn(key) -> set.Set(key),
    get_edge_weight: fn(key, key) -> Float,
    get_heuristic: fn(key) -> Float,
    nodes: dict.Dict(key, Node(key)),
    open_set: set.Set(key),
  )
}

/// Updates a node if a shorter path is found.
/// Returns the path search with the updated node or unchanged if current path is shorter.
fn update_node(
  path_search: PathSearch(key),
  key: key,
  previous: key,
  new_distance: Float,
) -> PathSearch(key) {
  case path_search.nodes |> dict.get(key) {
    Ok(node) if node.distance <=. new_distance -> path_search
    found_result -> {
      let node = case found_result {
        Ok(node) -> {
          Node(..node, distance: new_distance, previous: option.Some(previous))
        }
        Error(_) -> {
          Node(
            key: key,
            distance: new_distance,
            previous: option.Some(previous),
            heuristic: path_search.get_heuristic(key),
          )
        }
      }
      PathSearch(
        ..path_search,
        open_set: path_search.open_set |> set.insert(key),
        nodes: path_search.nodes |> dict.insert(key, node),
      )
    }
  }
}

/// Updates neighbors of current node by checking for shorter paths.
/// For each neighbor, calculates and updates distances if a shorter path is found.
fn update_neighbors(
  path_search: PathSearch(key),
  current: key,
  current_distance: Float,
) -> PathSearch(key) {
  path_search.get_neighbors(current)
  |> set.fold(path_search, fn(ps, k) {
    let edge_weight = path_search.get_edge_weight(current, k)
    let tentative_distance = current_distance +. edge_weight
    ps |> update_node(k, current, tentative_distance)
  })
}

/// Reconstructs the path from goal to start by following previous nodes.
/// Returns the path as a list ordered from start to goal.
fn reconstruct_path(
  nodes: dict.Dict(key, Node(key)),
  acc: List(key),
  current: key,
) -> List(key) {
  case nodes |> dict.get(current) {
    Ok(node) ->
      case node.previous {
        option.Some(prev) -> reconstruct_path(nodes, [current, ..acc], prev)
        option.None -> [current, ..acc]
      }
    Error(_) -> panic as "Node not found"
  }
}

/// Selects the next node to process based on lowest f-score (distance + heuristic).
fn get_current(
  open_set: set.Set(key),
  nodes: dict.Dict(key, Node(key)),
) -> Result(Node(key), Nil) {
  open_set
  |> set.to_list()
  |> list.filter_map(fn(k) {
    nodes
    |> dict.get(k)
  })
  |> list.max(fn(a, b) {
    float.compare(a.distance +. a.heuristic, b.distance +. b.heuristic)
    |> order.negate()
  })
}

/// Core A* search algorithm implementation.
/// Recursively processes nodes until goal is found or all paths are exhausted.
/// Uses tail recursion for efficient processing of large graphs.
fn find_path_internal(
  path_search: PathSearch(key),
  goal: key,
) -> option.Option(List(key)) {
  case get_current(path_search.open_set, path_search.nodes) {
    Error(_) -> option.None
    Ok(c) if c.key == goal -> {
      option.Some(reconstruct_path(path_search.nodes, [], c.key))
    }
    Ok(c) -> {
      path_search
      |> update_neighbors(c.key, c.distance)
      |> fn(s) { PathSearch(..s, open_set: s.open_set |> set.delete(c.key)) }
      |> find_path_internal(goal)
    }
  }
}

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
pub fn find_path(
  graph: graph.Graph(key, value, label),
  start: key,
  goal: key,
  heuristic: fn(value, value) -> Float,
) -> option.Option(List(key)) {
  let get_neighbors = fn(key) {
    graph
    |> graph.get_node(key)
    |> result.map(node.get_neighbors_out)
    |> result.unwrap(set.new())
  }
  let get_edge_weight = fn(a, b) {
    graph
    |> graph.get_edge(a, b)
    |> option.from_result()
    |> option.map(fn(edge) { edge.weight })
    |> option.flatten()
    |> option.unwrap(1.0)
    |> float.max(0.0)
  }
  use goal_node <- option.then(
    graph |> graph.get_node(goal) |> option.from_result,
  )
  let get_heuristic = fn(key: key) {
    {
      use g_value <- option.then(goal_node.value)
      use n <- option.then(graph |> graph.get_node(key) |> option.from_result)
      use n_value <- option.then(n.value)
      heuristic(n_value, g_value)
      |> option.Some
    }
    |> option.unwrap(0.0)
  }
  PathSearch(
    get_neighbors: get_neighbors,
    get_edge_weight: get_edge_weight,
    get_heuristic: get_heuristic,
    nodes: {
      [
        #(
          start,
          Node(
            key: start,
            distance: 0.0,
            previous: option.None,
            heuristic: get_heuristic(start),
          ),
        ),
      ]
      |> dict.from_list()
    },
    open_set: { [start] |> set.from_list() },
  )
  |> find_path_internal(goal)
}
