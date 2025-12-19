# Traveling Santa Problem - Design Document

## Problem Classification

This is **NOT** the classic Traveling Salesman Problem (TSP). While TSP finds the optimal route, we're solving an **itinerary reconstruction problem**:

- **Given**: Complete graph with known edge weights (city distances)
- **Given**: A sequence of distances traveled
- **Find**: All valid Hamiltonian paths from North Pole matching the distance sequence

## Algorithm: Constrained Backtracking DFS

Each distance acts as a **constraint filter**. At each step, we filter candidate cities by:
1. Distance from current city equals next distance in sequence
2. City has not been visited yet

### Pseudocode

```
find_itineraries(distances):
    solutions = []
    visited = {North Pole}
    dfs(current=North Pole, distances, visited, path=[], solutions)
    return solutions

dfs(current, distances, visited, path, solutions):
    if distances is empty:
        solutions.add(path)
        return

    next_distance = distances[0]
    for city in unvisited cities at distance next_distance from current:
        visited.add(city)
        path.push(city)
        dfs(city, distances[1:], visited, path, solutions)
        path.pop()
        visited.remove(city)
```

### Complexity

- **Time**: O(n! * d) worst case, but typically much better due to distance constraint pruning
- **Space**: O(n) for recursion stack + O(n * s) for storing s solutions

## Data Structures

### CityGraph

```rust
struct CityGraph {
    cities: Vec<String>,                      // City names by index
    city_indices: HashMap<String, usize>,     // Name → index lookup
    distances: HashMap<(usize, usize), u32>,  // Ordered pair → distance
}
```

Key insight: Store distances with **ordered** tuple keys `(min, max)` to ensure symmetric lookup without storing twice.

## Module Structure

```
src/
├── lib.rs      # Library root, re-exports
├── main.rs     # CLI entry point
├── graph.rs    # CityGraph: distance storage and lookup
└── solver.rs   # Core algorithm: find_itineraries()
```

## Key Design Decisions

1. **Index-based operations**: Use city indices internally for efficiency; convert to names only at boundaries
2. **Symmetric distance storage**: Single HashMap entry per city pair with ordered keys
3. **Backtracking with explicit unchoose**: Clear visited/path state after recursion for correctness
4. **Separation of graph and solver**: Graph handles data, solver handles algorithm
