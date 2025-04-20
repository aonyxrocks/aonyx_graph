import aonyx/graph
import aonyx/graph/node
import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/order
import gleam/result
import gleam/set

type Node(key) {
  Node(key: key, previous: option.Option(key), distance: Int)
}

type PathSearch(key) {
  PathSearch(
    get_neighbors: fn(key) -> set.Set(key),
    nodes: dict.Dict(key, Node(key)),
    open_set: set.Set(key),
  )
}

/// Updates the node in the path search with a new distance and previous node if it is shorter than the current one.
fn update_node(
  path_search: PathSearch(key),
  key: key,
  previous: key,
  distance: Int,
) -> PathSearch(key) {
  case path_search.nodes |> dict.get(key) {
    Ok(node) if node.distance <= distance -> path_search
    _ -> {
      let node = Node(key:, distance:, previous: option.Some(previous))
      PathSearch(
        ..path_search,
        open_set: path_search.open_set |> set.insert(key),
        nodes: path_search.nodes |> dict.insert(key, node),
      )
    }
  }
}

/// Updates the neighbors of the current node by checking if a shorter path can be found through the current node.
/// If a shorter path is found, it updates the neighbor's distance and previous node.
fn update_neighbors(
  path_search: PathSearch(key),
  current: key,
  current_distance: Int,
) -> PathSearch(key) {
  let tentative_distance = current_distance + 1
  path_search.get_neighbors(current)
  |> set.fold(path_search, fn(ps, k) {
    ps |> update_node(k, current, tentative_distance)
  })
}

/// Backtracks from the current (goal) node to the start node to reconstruct the shortest path, by following the previous nodes.
/// The accumulator should be an empty list when called.
/// Stops when it reaches a node with no previous node (which is the start node).
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

/// Selects the node from the open_set with the shortest distance so far.
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
  |> list.max(fn(a, b) { int.compare(a.distance, b.distance) |> order.negate() })
}

/// Recursively searches for the shortest path from start to goal.
/// It uses the open_set to keep track of the nodes to explore.
/// It updates the neighbors of the current node and continues searching until it finds the goal or exhausts all options.
/// If the goal is found, it reconstructs the path and returns it.
/// If no path is found, it returns None.
/// The function is tail-recursive, so it can handle large graphs without running out of stack space.
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

/// Uses Dijkstra's algorithm to exhaustively search for the shortest path from start to goal in the graph.
/// If a path can be found, it is guaranteed to be the shortest one.
/// The returned list represents the path in order from the start node to the goal node, or None when no path can be found.
pub fn find_path(
  graph: graph.Graph(key, value, label),
  start: key,
  goal: key,
) -> option.Option(List(key)) {
  let get_neighbors = fn(key) {
    graph
    |> graph.get_node(key)
    |> result.map(node.get_neighbors_out)
    |> result.unwrap(set.new())
  }
  PathSearch(
    get_neighbors: get_neighbors,
    nodes: {
      [#(start, Node(key: start, distance: 0, previous: option.None))]
      |> dict.from_list()
    },
    open_set: { [start] |> set.from_list() },
  )
  |> find_path_internal(goal)
}
