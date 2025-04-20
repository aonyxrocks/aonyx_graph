import aonyx/graph
import aonyx/graph/dijkstra
import aonyx/graph/edge
import aonyx/graph/node
import gleam/list
import gleam/set
import gleeunit/should

pub fn main() {
  creating_and_modifying_a_graph()
  |> path_finding()
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
  |> set.to_list()
  |> should.equal(["B", "D"])

  g
  |> graph.get_node("B")
  |> should.be_ok()
  |> node.get_neighbors_in()
  |> set.to_list()
  |> should.equal(["A"])

  g
  |> graph.get_node("B")
  |> should.be_ok()
  |> node.get_neighbors()
  |> set.to_list()
  |> should.equal(["A", "C", "E"])

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
