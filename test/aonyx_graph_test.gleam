import aonyx/graph
import aonyx/graph/dijkstra
import aonyx/graph/edge
import aonyx/graph/node
import gleam/list
import gleam/set
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

fn graph_fixture() {
  let graph =
    graph.new()
    |> list.fold(["a", "b", "c"], _, fn(g, node_key) {
      g |> graph.insert_node(node.new(node_key))
    })

  graph
}

pub fn new_graph_test() {
  graph_fixture()
  |> graph.get_nodes()
  |> should.equal([node.new("a"), node.new("b"), node.new("c")])
}

pub fn add_edge_ok_test() {
  let graph =
    graph_fixture()
    |> graph.insert_edge(edge.new("a", "b"))

  graph
  |> graph.get_edges()
  |> should.equal([edge.new("a", "b")])

  graph
  |> graph.get_node("a")
  |> should.be_ok()
  |> node.get_neighbors()
  |> set.to_list()
  |> should.equal(["b"])

  graph
  |> graph.get_node("b")
  |> should.be_ok()
  |> node.get_neighbors()
  |> set.to_list()
  |> should.equal(["a"])

  graph
  |> graph.get_node("c")
  |> should.be_ok()
  |> node.get_neighbors()
  |> should.equal(set.new())
}

pub fn remove_edge_ok_test() {
  let graph =
    graph_fixture()
    |> graph.insert_edge(edge.new("a", "b"))
    |> graph.remove_edge(edge.new("a", "b"))
    |> graph.remove_edge(edge.new("a", "c"))

  graph
  |> graph.get_edges()
  |> should.equal([])

  graph
  |> graph.get_node("a")
  |> should.be_ok()
  |> node.get_neighbors()
  |> should.equal(set.new())

  graph
  |> graph.get_node("b")
  |> should.be_ok()
  |> node.get_neighbors()
  |> should.equal(set.new())
}

pub fn insert_edge_ok_test() {
  let graph =
    graph_fixture()
    |> graph.insert_edge(edge.new("a", "b"))
    |> graph.insert_edge(edge.new("b", "c"))

  graph
  |> graph.get_edges()
  |> should.equal([edge.new("a", "b"), edge.new("b", "c")])

  graph
  |> graph.get_node("a")
  |> should.be_ok()
  |> node.get_neighbors()
  |> set.to_list()
  |> should.equal(["b"])

  graph
  |> graph.get_node("b")
  |> should.be_ok()
  |> node.get_neighbors()
  |> set.to_list()
  |> should.equal(["a", "c"])
}

pub fn remove_node_test() {
  let graph =
    graph_fixture()
    |> graph.insert_edge(edge.new("a", "b"))
    |> graph.insert_edge(edge.new("b", "c"))
    |> graph.insert_edge(edge.new("c", "a"))
    |> graph.remove_node(node.new("b"))
    |> graph.remove_node(node.new("d"))

  graph
  |> graph.get_nodes()
  |> list.map(fn(node) { node.key })
  |> should.equal(["a", "c"])

  graph
  |> graph.get_edges()
  |> should.equal([edge.new("c", "a")])

  graph
  |> graph.get_node("a")
  |> should.be_ok()
  |> node.get_neighbors()
  |> set.to_list()
  |> should.equal(["c"])

  graph
  |> graph.get_node("b")
  |> should.be_error()
  |> should.equal(graph.NodeNotFoundError("b"))
}

pub fn find_path_some_test() {
  let graph =
    graph.new()
    |> list.fold(["a", "b", "c"], _, fn(g, node_key) {
      g |> graph.insert_node(node.new(node_key))
    })
    |> list.fold([edge.new("a", "b"), edge.new("b", "c")], _, graph.insert_edge)

  graph
  |> dijkstra.find_path("a", "c")
  |> should.be_some()
  |> should.equal(["a", "b", "c"])
}

pub fn find_path_none_test() {
  let graph =
    graph.new()
    |> list.fold(["a", "b", "c"], _, fn(g, node_key) {
      g |> graph.insert_node(node.new(node_key))
    })
    |> list.fold([edge.new("a", "b"), edge.new("b", "c")], _, graph.insert_edge)

  graph
  |> dijkstra.find_path("c", "a")
  |> should.be_none()
}
