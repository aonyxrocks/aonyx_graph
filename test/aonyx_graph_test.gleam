import aonyx/graph
import aonyx/graph/astar
import aonyx/graph/dijkstra
import aonyx/graph/edge
import aonyx/graph/node
import gleam/dict
import gleam/erlang/process
import gleam/float
import gleam/list
import gleam/option
import gleam/otp/actor
import gleam/set
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

fn graph_fixture() {
  let graph =
    ["a", "b", "c"]
    |> list.map(node.new)
    |> list.fold(graph.new(), graph.insert_node)

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
  |> should.equal(set.from_list(["b"]))

  graph
  |> graph.get_node("b")
  |> should.be_ok()
  |> node.get_neighbors()
  |> should.equal(set.from_list(["a"]))

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
  |> should.equal(set.from_list(["b"]))

  graph
  |> graph.get_node("b")
  |> should.be_ok()
  |> node.get_neighbors()
  |> should.equal(set.from_list(["a", "c"]))
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

pub fn re_insert_node_without_edges_test() {
  let graph =
    graph_fixture()
    |> graph.insert_edge(edge.new("a", "b"))
    |> graph.insert_edge(edge.new("a", "c"))
    |> graph.insert_edge(edge.new("b", "c"))
    |> graph.insert_node(node.new("a"))

  graph
  |> graph.get_node("a")
  |> should.be_ok()
  |> node.get_neighbors()
  |> should.equal(set.new())

  graph
  |> graph.get_node("b")
  |> should.be_ok()
  |> node.get_neighbors()
  |> should.equal(set.from_list(["c"]))

  graph
  |> graph.get_node("c")
  |> should.be_ok()
  |> node.get_neighbors()
  |> should.equal(set.from_list(["b"]))
}

pub fn get_edge_test() {
  let graph =
    graph_fixture()
    |> graph.insert_edge(edge.new("a", "b") |> edge.with_label("test label"))

  // Test getting an existing edge
  graph
  |> graph.get_edge("a", "b")
  |> should.be_ok()
  |> fn(e) { e.label }
  |> should.equal(option.Some("test label"))

  // Test error when edge doesn't exist
  graph
  |> graph.get_edge("a", "c")
  |> should.be_error()
  |> should.equal(graph.EdgeNotFoundError("a", "c"))

  // Test error when both nodes don't exist
  graph
  |> graph.get_edge("x", "y")
  |> should.be_error()
  |> should.equal(graph.EdgeNotFoundError("x", "y"))
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

pub fn find_path_weighted_test() {
  let graph =
    [
      edge.new("a", "b") |> edge.with_weight(5.0),
      edge.new("b", "c") |> edge.with_weight(2.0),
      edge.new("a", "c"),
      edge.new("c", "d"),
      edge.new("c", "e") |> edge.with_weight(3.0),
      edge.new("d", "e") |> edge.with_weight(5.0),
    ]
    |> list.fold(graph.new(), graph.insert_edge)

  graph
  |> dijkstra.find_path("a", "e")
  |> should.be_some()
  |> should.equal(["a", "c", "e"])
}

pub fn find_path_negative_cycle_test() {
  let graph =
    [
      edge.new("a", "b") |> edge.with_weight(-1.0),
      edge.new("b", "c") |> edge.with_weight(-1.0),
      edge.new("c", "a") |> edge.with_weight(-1.0),
      edge.new("c", "d") |> edge.with_weight(1.0),
    ]
    |> list.fold(graph.new(), graph.insert_edge)

  graph
  |> dijkstra.find_path("a", "d")
  |> should.be_some()
  |> should.equal(["a", "b", "c", "d"])
}

type CounterMsg(key) {
  Stop(reply_with: process.Subject(dict.Dict(key, Int)))
  Incr(key)
}

fn start_counter() {
  let assert Ok(counter) =
    actor.start(dict.new(), fn(msg, s) {
      case msg {
        Stop(client) -> {
          client |> actor.send(s)
          actor.Stop(process.Normal)
        }
        Incr(key) ->
          actor.continue(
            s
            |> dict.upsert(key, fn(v) {
              case v {
                option.Some(v) -> v + 1
                option.None -> 1
              }
            }),
          )
      }
    })

  counter
}

pub fn find_path_astar_visited_nodes_test() {
  // Define the Euclidean distance function
  let euclidean_distance = fn(a, b) {
    let #(ax, ay) = a
    let #(bx, by) = b
    let dx = ax -. bx
    let dy = ay -. by
    let assert Ok(d) = float.square_root(dx *. dx +. dy *. dy)
    d
  }

  let insert_edge_with_euclidean_distance = fn(graph, a, b) {
    {
      use a_node <- option.then(
        graph |> graph.get_node(a) |> option.from_result,
      )
      use b_node <- option.then(
        graph |> graph.get_node(b) |> option.from_result,
      )
      use a_value <- option.then(a_node.value)
      use b_value <- option.then(b_node.value)

      let d =
        euclidean_distance(a_value, b_value)
        |> float.max(0.0)

      edge.new(a, b)
      |> edge.with_weight(d)
      |> option.Some
    }
    |> option.unwrap(edge.new(a, b) |> edge.with_weight(1.0))
    |> graph.insert_edge(graph, _)
  }

  let graph =
    [
      node.new("a") |> node.with_value(#(0.0, 0.0)),
      node.new("b") |> node.with_value(#(0.0, 2.0)),
      node.new("c") |> node.with_value(#(2.0, 2.0)),
      node.new("d") |> node.with_value(#(2.0, 0.0)),
      node.new("e") |> node.with_value(#(1.0, 1.0)),
      node.new("f") |> node.with_value(#(-2.0, 2.0)),
      node.new("g") |> node.with_value(#(-2.0, 0.0)),
      node.new("h") |> node.with_value(#(-1.0, 1.0)),
      node.new("i") |> node.with_value(#(-1.0, -1.0)),
      node.new("j") |> node.with_value(#(1.0, -1.0)),
      node.new("k") |> node.with_value(#(-2.0, -2.0)),
      node.new("l") |> node.with_value(#(0.0, -2.0)),
      node.new("m") |> node.with_value(#(2.0, -2.0)),
    ]
    |> list.fold(graph.new(), graph.insert_node)
    |> insert_edge_with_euclidean_distance("a", "b")
    |> insert_edge_with_euclidean_distance("a", "d")
    |> insert_edge_with_euclidean_distance("a", "e")
    |> insert_edge_with_euclidean_distance("a", "g")
    |> insert_edge_with_euclidean_distance("a", "h")
    |> insert_edge_with_euclidean_distance("a", "i")
    |> insert_edge_with_euclidean_distance("a", "j")
    |> insert_edge_with_euclidean_distance("b", "c")
    |> insert_edge_with_euclidean_distance("d", "c")
    |> insert_edge_with_euclidean_distance("e", "c")
    |> insert_edge_with_euclidean_distance("f", "b")
    |> insert_edge_with_euclidean_distance("g", "f")
    |> insert_edge_with_euclidean_distance("h", "f")
    |> insert_edge_with_euclidean_distance("i", "k")
    |> insert_edge_with_euclidean_distance("j", "m")
    |> insert_edge_with_euclidean_distance("k", "g")
    |> insert_edge_with_euclidean_distance("k", "l")
    |> insert_edge_with_euclidean_distance("l", "m")
    |> insert_edge_with_euclidean_distance("m", "d")

  // This builds a graph with node values representing 2D coordinates in a square:
  // f --- b --- c
  // | \   |   / |
  // |  h  |  e  |
  // |   \ | /   |
  // g --- a --- d
  // |   / | \   |
  // |  i  |  j  |
  // | /   |   \ |
  // k --- l --- m

  let counter = start_counter()

  // Without the zero heuristic (equivalent to Dijkstra), all nodes are visited
  let zero_heuristic = fn(a, _) {
    counter |> actor.send(Incr(a))
    0.0
  }

  let _path =
    graph
    |> astar.find_path("a", "c", zero_heuristic)

  let visited_nodes =
    counter
    |> actor.call(Stop, 10)

  visited_nodes
  |> dict.values()
  |> list.fold(0, fn(acc, v) { acc + v })
  |> should.equal(13)

  visited_nodes
  |> dict.keys()
  |> set.from_list()
  |> should.equal(set.from_list(
    graph
    |> graph.get_nodes()
    |> list.map(fn(node) { node.value })
    |> option.values(),
  ))

  let counter = start_counter()

  // With the Euclidean heuristic, the number of nodes visited
  // is reduced significantly, as the algorithm can skip over nodes
  // for which the heuristic estimates a longer path.
  let heuristic = fn(a, b) {
    counter |> actor.send(Incr(a))
    euclidean_distance(a, b)
  }

  let _path =
    graph
    |> astar.find_path("a", "c", heuristic)

  let visited_nodes =
    counter
    |> actor.call(Stop, 10)

  visited_nodes
  |> dict.values()
  |> list.fold(0, fn(acc, v) { acc + v })
  |> should.equal(9)

  visited_nodes
  |> dict.keys()
  |> set.from_list()
  |> should.equal(
    set.from_list([
      #(-2.0, 0.0),
      #(-1.0, -1.0),
      #(-1.0, 1.0),
      #(0.0, 0.0),
      #(0.0, 2.0),
      #(1.0, -1.0),
      #(1.0, 1.0),
      #(2.0, 0.0),
      #(2.0, 2.0),
    ]),
  )
}
