import sys

CITIES = ["North Pole", "Helsinki", "Oslo", "Stockholm", "Copenhagen", "Berlin"]

DISTANCES = {
    (0,1): 10, (0,2): 10, (0,3): 12, (0,4): 14, (0,5): 16,
    (1,2): 8, (1,3): 4, (1,4): 9, (1,5): 11,
    (2,3): 4, (2,4): 6, (2,5): 9,
    (3,4): 5, (3,5): 8,
    (4,5): 4,
}

def distance(a, b):
    return DISTANCES.get((min(a,b), max(a,b)))

def find_itineraries(dists):
    solutions = []
    def dfs(current, remaining, visited, path):
        if not remaining:
            solutions.append(path[:])
            return
        for next_city in range(len(CITIES)):
            if next_city not in visited and distance(current, next_city) == remaining[0]:
                visited.add(next_city)
                path.append(next_city)
                dfs(next_city, remaining[1:], visited, path)
                path.pop()
                visited.remove(next_city)
    dfs(0, dists, {0}, [])
    return solutions

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: traveling-santa <distance1> <distance2> ...", file=sys.stderr)
        sys.exit(1)

    dists = [int(x) for x in sys.argv[1:]]
    solutions = find_itineraries(dists)

    if not solutions:
        print("No valid itineraries found")
    else:
        print(f"Found {len(solutions)} solution(s):\n")
        for i, sol in enumerate(solutions, 1):
            print(f"Solution {i}: {', '.join(CITIES[c] for c in sol)}")
