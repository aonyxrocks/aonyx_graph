import gleam/option

/// Represents an edge going from one node to another.
pub type Edge(key, label) {
  Edge(
    from: key,
    to: key,
    label: option.Option(label),
    weight: option.Option(Float),
  )
}

pub type EdgeKey(key) {
  EdgeKey(from: key, to: key)
}

/// Creates an edge with the given from and to node keys, without label or weight.
pub fn new(from: key, to: key) -> Edge(key, label) {
  Edge(from:, to:, label: option.None, weight: option.None)
}

/// Extracts the key from an edge.
pub fn get_key(edge: Edge(key, label)) -> EdgeKey(key) {
  EdgeKey(edge.from, edge.to)
}

/// Sets the label of an edge.
pub fn with_label(edge: Edge(key, label), label: label) -> Edge(key, label) {
  Edge(..edge, label: option.Some(label))
}

/// Sets the weight of an edge.
pub fn with_weight(edge: Edge(key, label), weight: Float) -> Edge(key, label) {
  Edge(..edge, weight: option.Some(weight))
}

/// Clears the label of an edge.
pub fn without_label(edge: Edge(key, label)) -> Edge(key, label) {
  Edge(..edge, label: option.None)
}

/// Clears the weight of an edge.
pub fn without_weight(edge: Edge(key, label)) -> Edge(key, label) {
  Edge(..edge, weight: option.None)
}
