const CITIES = ["North Pole", "Helsinki", "Oslo", "Stockholm", "Copenhagen", "Berlin"];

const DISTANCES: Record<string, number> = {
  "0,1": 10, "0,2": 10, "0,3": 12, "0,4": 14, "0,5": 16,
  "1,2": 8, "1,3": 4, "1,4": 9, "1,5": 11,
  "2,3": 4, "2,4": 6, "2,5": 9,
  "3,4": 5, "3,5": 8,
  "4,5": 4,
};

const distance = (a: number, b: number): number | undefined =>
  DISTANCES[a < b ? `${a},${b}` : `${b},${a}`];

function findItineraries(dists: number[]): number[][] {
  const solutions: number[][] = [];
  const visited = new Set([0]);

  function dfs(current: number, remaining: number[], path: number[]) {
    if (remaining.length === 0) {
      solutions.push([...path]);
      return;
    }
    for (let next = 0; next < CITIES.length; next++) {
      if (!visited.has(next) && distance(current, next) === remaining[0]) {
        visited.add(next);
        path.push(next);
        dfs(next, remaining.slice(1), path);
        path.pop();
        visited.delete(next);
      }
    }
  }

  dfs(0, dists, []);
  return solutions;
}

if (Deno.args.length === 0) {
  console.error("Usage: traveling-santa <distance1> <distance2> ...");
  Deno.exit(1);
}

const dists = Deno.args.map(Number);
const solutions = findItineraries(dists);

if (solutions.length === 0) {
  console.log("No valid itineraries found");
} else {
  console.log(`Found ${solutions.length} solution(s):\n`);
  solutions.forEach((sol, i) =>
    console.log(`Solution ${i + 1}: ${sol.map(c => CITIES[c]).join(", ")}`)
  );
}
