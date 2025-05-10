import aonyx/graph
import aonyx/graph/edge
import aonyx/graph/node
import aonyx/graph/path/astar
import aonyx/graph/path/dijkstra
import gleam/dict
import gleam/float
import gleam/list
import gleam/option
import gleam/set
import gleeunit/should

pub fn main() {
  creating_and_modifying_a_graph()
  |> path_finding()

  path_finding_with_a_star()

  graph_traversal_examples()
}

fn creating_and_modifying_a_graph() {
  let g = graph.new()

  let g =
    [
      node.new("A"),
      node.new("B"),
      node.new("C"),
      node.new("D") |> node.with_value("Some value"),
      // you can also add nodes with incoming or outgoing edges.
      // the edges will be created automatically as well as the target nodes.
      node.new("E")
        |> node.with_incoming(["B"])
        |> node.with_outgoing(["F"]),
    ]
    |> list.fold(g, graph.insert_node)

  g |> graph.get_nodes() |> list.length() |> should.equal(6)

  let g =
    [
      edge.new("A", "B"),
      edge.new("B", "C"),
      edge.new("C", "A") |> edge.with_label("Some label"),
      edge.new("A", "D") |> edge.with_weight(0.5),
      edge.new("D", "F"),
      // you can also add edges to non-existing nodes.
      // the nodes will be created automatically.
      edge.new("G", "H"),
    ]
    |> list.fold(g, graph.insert_edge)

  g |> graph.get_edges() |> list.length() |> should.equal(8)
  g |> graph.get_nodes() |> list.length() |> should.equal(8)

  // the graph now looks like this:
  // ┌── C
  // ▼   ▲
  // A ► B ► E
  // ▼       ▼
  // D ────► F
  // 
  // G ► H   

  g
  |> graph.get_node("A")
  |> should.be_ok()
  |> node.get_neighbors_out()
  |> should.equal(set.from_list(["B", "D"]))

  g
  |> graph.get_node("B")
  |> should.be_ok()
  |> node.get_neighbors_in()
  |> should.equal(set.from_list(["A"]))

  g
  |> graph.get_node("B")
  |> should.be_ok()
  |> node.get_neighbors()
  |> should.equal(set.from_list(["A", "C", "E"]))

  g
}

fn path_finding(g: graph.Graph(String, _, _)) {
  g
  |> dijkstra.find_path("A", "F")
  |> should.be_some()
  |> should.equal(["A", "D", "F"])

  g
  |> dijkstra.find_path("B", "F")
  |> should.be_some()
  |> should.equal(["B", "E", "F"])

  let g = g |> graph.remove_edge(edge.new("A", "D"))

  g
  |> dijkstra.find_path("A", "F")
  |> should.be_some()
  |> should.equal(["A", "B", "E", "F"])

  let g = g |> graph.remove_node(node.new("E"))

  g
  |> dijkstra.find_path("A", "F")
  |> should.be_none()

  let g =
    g
    |> graph.get_node("D")
    |> should.be_ok()
    |> node.with_incoming(["A"])
    |> node.with_outgoing(["G"])
    |> graph.insert_node(g, _)

  g
  |> dijkstra.find_path("A", "H")
  |> should.be_some()
  |> should.equal(["A", "D", "G", "H"])
}

fn path_finding_with_a_star() {
  // A* is a pathfinding algorithm that uses heuristics to find the shortest path in a graph.
  // It is more efficient than Dijkstra's algorithm in many cases, especially when the graph is large and sparse.
  // The A* algorithm uses a heuristic function to estimate the cost of reaching the goal from a given node.
  // The heuristic function must be admissive, meaning it never overestimates the cost.
  // A common heuristic function is the Euclidean distance between two points in a 2D space.
  // In this example, we will use the Euclidean distance as the heuristic function for A*.
  // The heuristic function takes two values (in this case, 2D coordinates) and returns the Euclidean distance between them.
  let euclidean_distance = fn(a, b) {
    let #(ax, ay) = a
    let #(bx, by) = b
    let dx = ax -. bx
    let dy = ay -. by
    let assert Ok(d) = float.square_root(dx *. dx +. dy *. dy)
    d
  }

  let g =
    [
      node.new("A") |> node.with_value(#(0.0, 0.0)),
      node.new("B") |> node.with_value(#(0.0, 1.0)),
      node.new("C") |> node.with_value(#(0.5, 0.5)),
      node.new("D") |> node.with_value(#(1.0, 1.0)),
    ]
    |> list.fold(graph.new(), graph.insert_node)
    // add edges with approximate weights (rounded up from the euclidean distance)
    |> graph.insert_edge(edge.new("A", "B") |> edge.with_weight(1.0))
    |> graph.insert_edge(edge.new("A", "C") |> edge.with_weight(0.8))
    |> graph.insert_edge(edge.new("B", "D") |> edge.with_weight(1.0))
    |> graph.insert_edge(edge.new("C", "D") |> edge.with_weight(0.8))

  // this builds a graph with node values representing 2D coordinates:
  // A
  // |\
  // | C
  // |  \
  // B - D

  let path =
    g
    |> astar.find_path("A", "D", euclidean_distance)

  path
  |> should.be_some()
  |> should.equal(["A", "C", "D"])
}

fn graph_traversal_examples() {
  // Create a simple tree-like graph for traversal examples
  //      A
  //     / \
  //    B   C
  //   / \   \
  //  D   E   F
  let g =
    graph.new()
    |> graph.insert_edge(edge.new("A", "B"))
    |> graph.insert_edge(edge.new("A", "C"))
    |> graph.insert_edge(edge.new("B", "D"))
    |> graph.insert_edge(edge.new("B", "E"))
    |> graph.insert_edge(edge.new("C", "F"))

  // Example 1: Collect node keys for each depth level
  let visit = fn(acc, node: node.Node(String, _), depth) {
    graph.Continue(
      acc
      |> dict.upsert(depth, fn(x) {
        case x {
          option.None -> [node.key] |> set.from_list()
          option.Some(xs) -> xs |> set.insert(node.key)
        }
      }),
    )
  }

  let breadth_first_result =
    g
    |> graph.fold_breadth_first_until("A", dict.new(), visit)
    |> should.be_ok()

  // In breadth-first traversal, we visit nodes level by level
  // A (level 0), then B, C (level 1), then D, E, F (level 2)
  // The exact order within a level may vary depending on implementation
  breadth_first_result
  |> should.equal(
    [
      #(0, set.from_list(["A"])),
      #(1, set.from_list(["B", "C"])),
      #(2, set.from_list(["D", "E", "F"])),
    ]
    |> dict.from_list(),
  )

  // Example 2: Collect node keys in depth-first order
  let depth_first_result =
    g
    |> graph.fold_depth_first_until("A", dict.new(), visit)
    |> should.be_ok()

  // In depth-first traversal, we explore as far as possible along each branch before backtracking
  // The exact order depends on implementation but could be A -> B -> D -> E -> C -> F
  // The depth levels will be the same as in breadth-first traversal
  depth_first_result
  |> should.equal(
    [
      #(0, set.from_list(["A"])),
      #(1, set.from_list(["B", "C"])),
      #(2, set.from_list(["D", "E", "F"])),
    ]
    |> dict.from_list(),
  )

  // Example 3: Early termination with Stop
  // We'll stop when we find a node with key "C"
  let stop_at_c = fn(acc, node: node.Node(String, _), _depth) {
    case node.key {
      "C" -> graph.Stop
      _ -> graph.Continue([node.key, ..acc])
    }
  }

  let partial_traversal =
    g
    |> graph.fold_breadth_first_until("A", [], stop_at_c)

  // We should have only visited A and possibly B (depending on traversal order)
  // but definitely not visited nodes after C
  partial_traversal
  |> should.be_ok()
  |> list.contains("F")
  |> should.be_false()
}
