#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "Building..."
(cd rust && cargo build --release -q)
(cd c && make -s)
(cd go && go build -o traveling-santa)

pass=0 fail=0

run_bin() {
    case $1 in
        python) (cd python && uv run main.py "${@:2}" 2>&1) ;;
        deno) (cd deno && deno run main.ts "${@:2}" 2>&1) ;;
        *) "$1" "${@:2}" 2>&1 ;;
    esac
}

check() {
    name=$1; shift
    expected=$1; shift

    for bin in ./rust/target/release/traveling-santa ./c/traveling-santa ./go/traveling-santa python deno; do
        result=$(run_bin "$bin" "$@" || true)
        if echo "$result" | grep -q "$expected"; then
            ((pass++))
        else
            echo "FAIL [$name] $bin: expected '$expected'"
            echo "  got: $result"
            ((fail++))
        fi
    done
}

echo -e "\nRunning tests...\n"

check "example"       "Helsinki, Stockholm, Oslo, Copenhagen, Berlin"  10 4 4 6 4
check "two_solutions" "Found 2 solution"  10 4
check "no_solution"   "No valid"  999
check "single_step"   "Found 2 solution"  10

echo -e "\n$pass passed, $fail failed"
[ $fail -eq 0 ]
