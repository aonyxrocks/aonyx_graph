import aonyx/graph/edge.{type Edge, type EdgeKey, Edge, EdgeKey}
import aonyx/graph/node.{type Node, type NodeKey, Node, NodeKey}
import gleam/dict
import gleam/list
import gleam/option
import gleam/result
import gleam/set

/// Represents a graph with nodes identified by a key, containing an optional value, with edges having an associated optional label.
pub opaque type Graph(key, value, label) {
  Graph(
    nodes: dict.Dict(NodeKey(key), Node(key, value)),
    edges: dict.Dict(EdgeKey(key), Edge(key, label)),
  )
}

/// Returned when trying to retrieve a node or edge that does not exist.
pub type GraphError(key) {
  NodeNotFoundError(key: key)
  EdgeNotFoundError(from: key, to: key)
}

/// Creates a new empty graph.
pub fn new() -> Graph(key, value, label) {
  Graph(dict.new(), dict.new())
}

/// Returns a list of all edges in the graph.
pub fn get_edges(graph: Graph(key, value, label)) -> List(Edge(key, label)) {
  graph.edges
  |> dict.map_values(fn(edge_internal, edge_info_internal) {
    Edge(
      edge_internal.from,
      edge_internal.to,
      edge_info_internal.label,
      edge_info_internal.weight,
    )
  })
  |> dict.values()
}

fn insert_edge_internal(
  graph: Graph(key, value, label),
  edge: Edge(key, label),
) -> Graph(key, value, label) {
  let Graph(nodes, edges) = graph

  let from_node = case nodes |> dict.get(NodeKey(edge.from)) {
    Ok(node) -> Node(..node, outgoing: node.outgoing |> set.insert(edge.to))
    Error(_) ->
      Node(
        key: edge.from,
        incoming: set.new(),
        outgoing: [edge.to] |> set.from_list(),
        value: option.None,
      )
  }

  let to_node = case nodes |> dict.get(NodeKey(edge.to)) {
    Ok(node) -> Node(..node, incoming: node.incoming |> set.insert(edge.from))
    Error(_) ->
      Node(
        key: edge.to,
        incoming: [edge.from] |> set.from_list(),
        outgoing: set.new(),
        value: option.None,
      )
  }

  let nodes =
    nodes
    |> dict.insert(node.get_key(from_node), from_node)
    |> dict.insert(node.get_key(to_node), to_node)

  let edges =
    edges
    |> dict.insert(edge.get_key(edge), edge)

  Graph(nodes, edges)
}

/// Inserts an edge into the graph.
/// If a node does not exist in the graph, it is created.
/// If the edge already exists, its info is updated.
pub fn insert_edge(
  graph: Graph(key, value, label),
  edge: Edge(key, label),
) -> Graph(key, value, label) {
  insert_edge_internal(graph, edge)
}

fn remove_edge_internal(
  graph: Graph(key, value, label),
  edge: EdgeKey(key),
) -> Graph(key, value, label) {
  let Graph(nodes, edges) = graph
  let from_node =
    nodes
    |> dict.get(NodeKey(edge.from))
    |> result.map(fn(node) {
      Node(..node, outgoing: node.outgoing |> set.delete(edge.to))
    })
  let to_node =
    nodes
    |> dict.get(NodeKey(edge.to))
    |> result.map(fn(node) {
      Node(..node, incoming: node.incoming |> set.delete(edge.from))
    })

  let nodes =
    [from_node, to_node]
    |> list.filter_map(fn(n) { n })
    |> list.fold(nodes, fn(nodes, n) {
      nodes |> dict.insert(node.get_key(n), n)
    })

  let edges =
    edges
    |> dict.delete(edge)

  Graph(nodes, edges)
}

/// Removes an edge from the graph.
/// If one of the nodes does not exist in the graph, NodeNotFoundError is returned.
/// If the edge does not exist, the graph remains unchanged.
pub fn remove_edge(
  graph: Graph(key, value, label),
  edge: Edge(key, label),
) -> Graph(key, value, label) {
  remove_edge_internal(graph, edge.get_key(edge))
}

/// Returns the edge from the graph with the given from and to node keys, or an error when the edge does not exist.
pub fn get_edge(
  graph: Graph(key, value, label),
  from: key,
  to: key,
) -> Result(Edge(key, label), GraphError(key)) {
  graph.edges
  |> dict.get(EdgeKey(from, to))
  |> result.replace_error(EdgeNotFoundError(from, to))
}

/// Returns a list of all nodes in the graph.
pub fn get_nodes(graph: Graph(key, value, label)) -> List(Node(key, value)) {
  graph.nodes
  |> dict.values()
}

/// Inserts a node into the graph.
/// If a node with the same key already exists, its value is updated.
/// If the node has incoming or outgoing edges, they are added to the graph.
/// If any of the target nodes do not exist, they are created.
pub fn insert_node(
  graph: Graph(key, value, label),
  node: Node(key, value),
) -> Graph(key, value, label) {
  let graph =
    Graph(..graph, nodes: graph.nodes |> dict.insert(node.get_key(node), node))

  let edges_outgoing =
    node.outgoing
    |> set.map(fn(to) { edge.new(node.key, to) })

  let edges_incoming =
    node.incoming
    |> set.map(fn(from) { edge.new(from, node.key) })

  edges_outgoing
  |> set.union(edges_incoming)
  |> set.fold(graph, insert_edge_internal)
}

/// Removes a node and all its edges from the graph.
/// If the node does not exist, the graph remains unchanged.
pub fn remove_node(
  graph: Graph(key, value, label),
  node: Node(key, value),
) -> Graph(key, value, label) {
  let Graph(nodes, edges) =
    graph.edges
    |> dict.filter(fn(edge, _) {
      let EdgeKey(from, to) = edge
      from == node.key || to == node.key
    })
    |> dict.fold(graph, fn(graph, edge, _) {
      graph |> remove_edge_internal(edge)
    })

  let nodes = nodes |> dict.delete(node.get_key(node))

  Graph(nodes:, edges:)
}

/// Returns the node from the graph with the given key, or an error when the node does not exist.
pub fn get_node(
  graph: Graph(key, value, label),
  key: key,
) -> Result(Node(key, value), GraphError(key)) {
  graph.nodes
  |> dict.get(NodeKey(key))
  |> result.replace_error(NodeNotFoundError(key))
}
