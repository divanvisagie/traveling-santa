# Traveling Santa Problem - Requirements

## Problem Statement

Santa Claus has a list of cities to visit, and his elves planned the most efficient route using their "Traveling Santa Problem" solver. However, Santa spilled hot chocolate on the itinerary, making city names unreadable while distances remain visible.

**Goal**: Reconstruct all possible itineraries that match a given sequence of distances.

## Constraints

- Santa starts from the **North Pole**
- Each city must be visited **exactly once**
- The order of cities must produce the **exact sequence of distances** provided

## City Distance Data

```
North Pole - Helsinki: 10
North Pole - Oslo: 10
North Pole - Stockholm: 12
North Pole - Copenhagen: 14
North Pole - Berlin: 16
Helsinki - Stockholm: 4
Helsinki - Oslo: 8
Helsinki - Copenhagen: 9
Helsinki - Berlin: 11
Oslo - Stockholm: 4
Oslo - Copenhagen: 6
Oslo - Berlin: 9
Stockholm - Copenhagen: 5
Stockholm - Berlin: 8
Copenhagen - Berlin: 4
```

## Example

**Input**: `10 4 4 6 4`

**Output**: `Helsinki, Stockholm, Oslo, Copenhagen, Berlin`

**Verification**:
- North Pole → Helsinki: 10
- Helsinki → Stockholm: 4
- Stockholm → Oslo: 4
- Oslo → Copenhagen: 6
- Copenhagen → Berlin: 4

## Success Criteria

1. Program accepts distance sequence as command-line arguments
2. Returns **all** valid itineraries (there may be multiple)
3. Returns empty result if no valid itinerary exists
4. Handles edge cases (empty input, impossible distances)
