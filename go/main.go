package main

import (
	"fmt"
	"os"
	"strconv"
)

var cities = []string{"North Pole", "Helsinki", "Oslo", "Stockholm", "Copenhagen", "Berlin"}

var distances = map[[2]int]int{
	{0, 1}: 10, {0, 2}: 10, {0, 3}: 12, {0, 4}: 14, {0, 5}: 16,
	{1, 2}: 8, {1, 3}: 4, {1, 4}: 9, {1, 5}: 11,
	{2, 3}: 4, {2, 4}: 6, {2, 5}: 9,
	{3, 4}: 5, {3, 5}: 8,
	{4, 5}: 4,
}

func distance(a, b int) (int, bool) {
	if a > b {
		a, b = b, a
	}
	d, ok := distances[[2]int{a, b}]
	return d, ok
}

func findItineraries(dists []int) [][]int {
	var solutions [][]int
	visited := make([]bool, len(cities))
	visited[0] = true

	var dfs func(current int, remaining []int, path []int)
	dfs = func(current int, remaining []int, path []int) {
		if len(remaining) == 0 {
			sol := make([]int, len(path))
			copy(sol, path)
			solutions = append(solutions, sol)
			return
		}
		for next := 0; next < len(cities); next++ {
			if d, ok := distance(current, next); !visited[next] && ok && d == remaining[0] {
				visited[next] = true
				dfs(next, remaining[1:], append(path, next))
				visited[next] = false
			}
		}
	}
	dfs(0, dists, nil)
	return solutions
}

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "Usage: traveling-santa <distance1> <distance2> ...")
		os.Exit(1)
	}

	dists := make([]int, len(os.Args)-1)
	for i, arg := range os.Args[1:] {
		d, err := strconv.Atoi(arg)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Invalid distance: %s\n", arg)
			os.Exit(1)
		}
		dists[i] = d
	}

	solutions := findItineraries(dists)

	if len(solutions) == 0 {
		fmt.Println("No valid itineraries found")
	} else {
		fmt.Printf("Found %d solution(s):\n\n", len(solutions))
		for i, sol := range solutions {
			fmt.Printf("Solution %d: ", i+1)
			for j, c := range sol {
				if j > 0 {
					fmt.Print(", ")
				}
				fmt.Print(cities[c])
			}
			fmt.Println()
		}
	}
}
