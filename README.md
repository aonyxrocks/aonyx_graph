# aonyx_graph

[![Package Version](https://img.shields.io/hexpm/v/aonyx_graph)](https://hex.pm/packages/aonyx_graph)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/aonyx_graph/)

A functional graph library for Gleam.

```sh
gleam add aonyx_graph
```

## Features

- Add, remove, and update nodes and edges
- List neighbors of a node, including incoming and outgoing edges
- Find paths between nodes

## Example

```gleam
import aonyx/graph
import aonyx/graph/astar
import aonyx/graph/dijkstra
import aonyx/graph/edge
import aonyx/graph/node
import gleam/float
import gleam/list
import gleam/set
import gleeunit/should

pub fn main() {
  creating_and_modifying_a_graph()
  |> path_finding()

  path_finding_with_a_star()
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
```
