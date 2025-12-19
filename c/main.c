#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define NUM_CITIES 6

const char* CITIES[] = {"North Pole", "Helsinki", "Oslo", "Stockholm", "Copenhagen", "Berlin"};

const int DISTANCES[NUM_CITIES][NUM_CITIES] = {
    {0, 10, 10, 12, 14, 16},
    {10, 0, 8, 4, 9, 11},
    {10, 8, 0, 4, 6, 9},
    {12, 4, 4, 0, 5, 8},
    {14, 9, 6, 5, 0, 4},
    {16, 11, 9, 8, 4, 0},
};

typedef struct { int path[NUM_CITIES]; int length; } Solution;
typedef struct { Solution* items; int count; int capacity; } Solutions;

void solutions_init(Solutions* s) {
    s->count = 0;
    s->capacity = 16;
    s->items = malloc(s->capacity * sizeof(Solution));
}

void solutions_add(Solutions* s, int* path, int len) {
    if (s->count >= s->capacity) {
        s->capacity *= 2;
        s->items = realloc(s->items, s->capacity * sizeof(Solution));
    }
    memcpy(s->items[s->count].path, path, len * sizeof(int));
    s->items[s->count].length = len;
    s->count++;
}

void solutions_free(Solutions* s) { free(s->items); }

void dfs(int current, int* distances, int num_distances, bool* visited,
         int* path, int path_len, Solutions* solutions) {
    if (num_distances == 0) {
        solutions_add(solutions, path, path_len);
        return;
    }
    for (int next = 0; next < NUM_CITIES; next++) {
        if (!visited[next] && DISTANCES[current][next] == distances[0]) {
            visited[next] = true;
            path[path_len] = next;
            dfs(next, distances + 1, num_distances - 1, visited, path, path_len + 1, solutions);
            visited[next] = false;
        }
    }
}

Solutions find_itineraries(int* distances, int num_distances) {
    Solutions solutions;
    solutions_init(&solutions);
    bool visited[NUM_CITIES] = {true};
    int path[NUM_CITIES];
    dfs(0, distances, num_distances, visited, path, 0, &solutions);
    return solutions;
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: traveling-santa <distance1> <distance2> ...\n");
        return 1;
    }
    int num_distances = argc - 1;
    int* distances = malloc(num_distances * sizeof(int));
    for (int i = 0; i < num_distances; i++) distances[i] = atoi(argv[i + 1]);

    Solutions solutions = find_itineraries(distances, num_distances);

    if (solutions.count == 0) {
        printf("No valid itineraries found\n");
    } else {
        printf("Found %d solution(s):\n\n", solutions.count);
        for (int i = 0; i < solutions.count; i++) {
            printf("Solution %d: ", i + 1);
            for (int j = 0; j < solutions.items[i].length; j++)
                printf("%s%s", CITIES[solutions.items[i].path[j]], j < solutions.items[i].length - 1 ? ", " : "");
            printf("\n");
        }
    }
    free(distances);
    solutions_free(&solutions);
    return 0;
}
