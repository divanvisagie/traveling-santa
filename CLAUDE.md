# Traveling Santa

Implementations of the "Traveling Santa Problem" in multiple languages.

## Structure

- `rust/` - Rust implementation (`cargo build --release`)
- `c/` - C implementation (`make`)
- `go/` - Go implementation (`go build`)
- `python/` - Python implementation (`uv run main.py`)
- `deno/` - Deno/TypeScript implementation (`deno run main.ts`)
- `ocaml/` - OCaml implementation (`ocamlopt -o traveling-santa main.ml`)
- `asm/` - ARM64 assembly for Apple Silicon (`make`)
- `docs/` - Problem requirements and design notes

## Testing

Run `./test.sh` to build and test all implementations. Each implementation is tested with 4 cases:
- Example case: `10 4 4 6 4` → Helsinki, Stockholm, Oslo, Copenhagen, Berlin
- Two solutions: `10 4` → Helsinki/Oslo to Stockholm
- No solution: `999` → impossible distance
- Single step: `10` → Helsinki or Oslo

## Adding New Implementations

1. Create a new directory with the language name
2. Implement a CLI that takes distances as arguments
3. Output format: "Found N solution(s):" followed by "Solution N: City1, City2, ..."
4. Add build command to `test.sh`
5. Add binary to `.gitignore`
