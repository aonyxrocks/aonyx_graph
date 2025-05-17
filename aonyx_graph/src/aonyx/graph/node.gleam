import gleam/option
import gleam/set

/// Represents a node in the graph identified by a key and containing an optional value.
pub type Node(key, value) {
  Node(
    key: key,
    value: option.Option(value),
    outgoing: set.Set(key),
    incoming: set.Set(key),
  )
}

pub type NodeKey(key) {
  NodeKey(key: key)
}

/// Creates a node with the given key, without a value.
///
/// ## Examples
///
/// ```gleam
/// new("A")
/// // -> Node(key: "A", value: None, outgoing: Set([]), incoming: Set([]))
/// ```
pub fn new(key: key) -> Node(key, a) {
  Node(key:, value: option.None, outgoing: set.new(), incoming: set.new())
}

/// Extracts the key from a node.
pub fn get_key(node: Node(key, value)) -> NodeKey(key) {
  NodeKey(node.key)
}

/// Returns a set union of keys of all direct neighbors of a given node in both directions.
///
/// ## Examples
///
/// ```gleam
/// let node = new("A")
///   |> with_outgoing(["B", "C"])
///   |> with_incoming(["D"])
///
/// get_neighbors(node)
/// // -> Set(["B", "C", "D"])
/// ```
pub fn get_neighbors(node: Node(key, value)) -> set.Set(key) {
  node.outgoing |> set.union(node.incoming)
}

/// Returns a set of keys of all direct neighbors of a given node via incoming edges.
///
/// ## Examples
///
/// ```gleam
/// let node = new("A")
///   |> with_outgoing(["B", "C"])
///   |> with_incoming(["D", "E"])
///
/// get_neighbors_in(node)
/// // -> Set(["D", "E"])
/// ```
pub fn get_neighbors_in(node: Node(key, value)) -> set.Set(key) {
  node.incoming
}

/// Returns a set of keys of all direct neighbors of a given node via outgoing edges.
///
/// ## Examples
///
/// ```gleam
/// let node = new("A")
///   |> with_outgoing(["B", "C"])
///   |> with_incoming(["D"])
///
/// get_neighbors_out(node)
/// // -> Set(["B", "C"])
/// ```
pub fn get_neighbors_out(node: Node(key, value)) -> set.Set(key) {
  node.outgoing
}

/// Sets the value of a node.
///
/// ## Examples
///
/// ```gleam
/// let node = new("A")
/// with_value(node, "Node A")
/// // -> Node(key: "A", value: Some("Node A"), outgoing: Set([]), incoming: Set([]))
/// ```
pub fn with_value(node: Node(key, value), value: value) -> Node(key, value) {
  Node(..node, value: option.Some(value))
}

/// Clears the value of a node.
///
/// ## Examples
///
/// ```gleam
/// let node = new("A") |> with_value("Node A")
/// without_value(node)
/// // -> Node(key: "A", value: None, outgoing: Set([]), incoming: Set([]))
/// ```
pub fn without_value(node: Node(key, value)) -> Node(key, value) {
  Node(..node, value: option.None)
}

/// Sets the outgoing edges of a node.
///
/// ## Examples
///
/// ```gleam
/// let node = new("A")
/// with_outgoing(node, ["B", "C"])
/// // -> Node(key: "A", value: None, outgoing: Set(["B", "C"]), incoming: Set([]))
/// ```
pub fn with_outgoing(
  node: Node(key, value),
  outgoing: List(key),
) -> Node(key, value) {
  Node(..node, outgoing: outgoing |> set.from_list())
}

/// Sets the incoming edges of a node.
///
/// ## Examples
///
/// ```gleam
/// let node = new("A")
/// with_incoming(node, ["B", "C"])
/// // -> Node(key: "A", value: None, outgoing: Set([]), incoming: Set(["B", "C"]))
/// ```
pub fn with_incoming(
  node: Node(key, value),
  incoming: List(key),
) -> Node(key, value) {
  Node(..node, incoming: incoming |> set.from_list())
}
