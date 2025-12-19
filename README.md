# Traveling Santa

A coding challenge solved in multiple languages to compare implementation approaches, verbosity, and readability.

## 100% AI-Generated

Every line of code in this repository was written by Claude (Opus 4.5). There's a claim that LLMs struggle with this problem and produce messy, unreadable solutions. This project exists to prove otherwise: clean, idiomatic implementations across 7 languages, from Python to ARM64 assembly, all generated in a single session with proper planning and TDD.

## The Challenge

Santa spilled hot chocolate on his itinerary, obscuring city names but leaving travel distances visible. Given the distances between all cities and a sequence of traveled distances, reconstruct all possible routes that match.

**Input:** A sequence of distances (e.g., `10 4 4 6 4`)

**Output:** All valid itineraries starting from the North Pole

```
$ ./traveling-santa 10 4 4 6 4
Found 1 solution(s):

Solution 1: Helsinki, Stockholm, Oslo, Copenhagen, Berlin
```

## The Algorithm

All implementations use the same approach: **constrained backtracking DFS**.

1. Start at North Pole
2. For each distance in the sequence, find unvisited cities at that exact distance
3. Recursively explore each candidate
4. Backtrack when stuck, collect all complete paths

The distance constraint dramatically prunes the search space compared to brute-force permutation.

## Implementation Comparison

| Language | Lines | Data Structure | Notes |
|----------|-------|----------------|-------|
| Python   | 45    | Dict + Set | Closures, list slicing, f-strings |
| OCaml    | 51    | Hashtbl + Array | Pattern matching, refs, functional style |
| Deno/TS  | 53    | Record + Set | Similar to Python, with types |
| Go       | 85    | Map + Slice | Explicit copying, verbose error handling |
| C        | 90    | 2D Array + Dynamic array | Manual memory management |
| Rust     | 90    | HashMap + Vec | Ownership, Option types |
| ARM64    | 366   | Raw memory | Apple Silicon assembly, syscalls |

### Key Differences

**Python (45 lines)** - Most concise due to:
- Built-in dict/set with clean syntax
- List slicing (`remaining[1:]`)
- Nested function captures `solutions` without explicit passing
- f-strings and `enumerate` reduce boilerplate

**OCaml (51 lines)** - Functional elegance:
- Pattern matching on list (`[] | d :: rest`)
- Mutable refs for solutions accumulator
- Hashtbl with tuple keys for distances
- Terse syntax, minimal punctuation

**Deno/TypeScript (53 lines)** - Clean with types:
- Record type for distances, Set for visited
- Arrow functions and template literals
- Array spread for path copying
- Type annotations add ~8 lines vs Python

**Go (85 lines)** - Middle ground:
- Explicit `copy()` needed for solution snapshots
- Tuple keys via `[2]int` array type
- Multi-value returns for distance lookup
- No generics needed, straightforward imperative style

**C (90 lines)** - Verbose but predictable:
- Manual dynamic array with realloc
- 2D array for distances (most memory-efficient)
- Explicit memory management (malloc/free)
- No hash map needed due to small fixed city set

**Rust (90 lines)** - Safety with verbosity:
- HashMap for distances, Vec for solutions
- `Option<u32>` for safe distance lookup
- Explicit mutability annotations
- Iterator chains for transformations

**ARM64 Assembly (366 lines)** - Maximum control:
- Direct syscalls for I/O (`svc #0x80`)
- Manual register allocation and stack management
- Apple Silicon (M1/M2/M3) native
- No standard library, no allocator

## Running

```bash
# Run all tests (builds all implementations)
./test.sh

# Run individual implementations
cd rust && cargo run --release -- 10 4 4 6 4
cd c && make && ./traveling-santa 10 4 4 6 4
cd go && go run main.go 10 4 4 6 4
cd python && uv run main.py 10 4 4 6 4
cd deno && deno run main.ts 10 4 4 6 4
cd ocaml && ocamlopt -o traveling-santa main.ml && ./traveling-santa 10 4 4 6 4
cd asm && make && ./traveling-santa 10 4 4 6 4
```

## City Distances

```
North Pole - Helsinki: 10    Helsinki - Oslo: 8
North Pole - Oslo: 10        Helsinki - Copenhagen: 9
North Pole - Stockholm: 12   Helsinki - Berlin: 11
North Pole - Copenhagen: 14  Oslo - Stockholm: 4
North Pole - Berlin: 16      Oslo - Copenhagen: 6
Helsinki - Stockholm: 4      Oslo - Berlin: 9
Stockholm - Copenhagen: 5    Stockholm - Berlin: 8
Copenhagen - Berlin: 4
```
