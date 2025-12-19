use std::collections::HashMap;

fn main() {
    let distances: Vec<u32> = std::env::args().skip(1)
        .map(|s| s.parse().expect("Invalid distance"))
        .collect();

    if distances.is_empty() {
        eprintln!("Usage: traveling-santa <distance1> <distance2> ...");
        std::process::exit(1);
    }

    let graph = CityGraph::new();
    let solutions = find_itineraries(&graph, &distances);

    match solutions.len() {
        0 => println!("No valid itineraries found"),
        n => {
            println!("Found {} solution(s):\n", n);
            for (i, s) in solutions.iter().enumerate() {
                println!("Solution {}: {}", i + 1, s.join(", "));
            }
        }
    }
}

struct CityGraph {
    cities: Vec<&'static str>,
    distances: HashMap<(usize, usize), u32>,
}

impl CityGraph {
    fn new() -> Self {
        let cities = vec!["North Pole", "Helsinki", "Oslo", "Stockholm", "Copenhagen", "Berlin"];
        let idx: HashMap<_, _> = cities.iter().enumerate().map(|(i, &c)| (c, i)).collect();
        let mut distances = HashMap::new();

        for (a, b, d) in [
            ("North Pole", "Helsinki", 10), ("North Pole", "Oslo", 10),
            ("North Pole", "Stockholm", 12), ("North Pole", "Copenhagen", 14),
            ("North Pole", "Berlin", 16), ("Helsinki", "Stockholm", 4),
            ("Helsinki", "Oslo", 8), ("Helsinki", "Copenhagen", 9),
            ("Helsinki", "Berlin", 11), ("Oslo", "Stockholm", 4),
            ("Oslo", "Copenhagen", 6), ("Oslo", "Berlin", 9),
            ("Stockholm", "Copenhagen", 5), ("Stockholm", "Berlin", 8),
            ("Copenhagen", "Berlin", 4),
        ] {
            let (i, j) = (idx[a], idx[b]);
            distances.insert((i.min(j), i.max(j)), d);
        }

        Self { cities, distances }
    }

    fn distance(&self, a: usize, b: usize) -> Option<u32> {
        self.distances.get(&(a.min(b), a.max(b))).copied()
    }
}

fn find_itineraries(graph: &CityGraph, distances: &[u32]) -> Vec<Vec<String>> {
    let mut solutions = Vec::new();
    let mut visited = vec![false; graph.cities.len()];
    visited[0] = true;
    dfs(graph, 0, distances, &mut visited, &mut Vec::new(), &mut solutions);
    solutions
}

fn dfs(
    graph: &CityGraph,
    current: usize,
    distances: &[u32],
    visited: &mut [bool],
    path: &mut Vec<usize>,
    solutions: &mut Vec<Vec<String>>,
) {
    if distances.is_empty() {
        solutions.push(path.iter().map(|&i| graph.cities[i].to_string()).collect());
        return;
    }

    for next in 0..graph.cities.len() {
        if !visited[next] && graph.distance(current, next) == Some(distances[0]) {
            visited[next] = true;
            path.push(next);
            dfs(graph, next, &distances[1..], visited, path, solutions);
            path.pop();
            visited[next] = false;
        }
    }
}
