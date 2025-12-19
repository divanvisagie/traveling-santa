.global _main
.align 4

.equ NUM_CITIES, 6
.equ MAX_SOLUTIONS, 32

.data

// Strings first
msg_usage: .asciz "Usage: traveling-santa <distance1> <distance2> ...\n"
msg_none: .asciz "No valid itineraries found\n"
msg_found1: .asciz "Found "
msg_found2: .asciz " solution(s):\n\n"
msg_sol: .asciz "Solution "
msg_colon: .asciz ": "
msg_comma: .asciz ", "
msg_newline: .asciz "\n"
city0: .asciz "North Pole"
city1: .asciz "Helsinki"
city2: .asciz "Oslo"
city3: .asciz "Stockholm"
city4: .asciz "Copenhagen"
city5: .asciz "Berlin"

// Aligned data
.align 3
cities: .quad city0, city1, city2, city3, city4, city5

.align 2
distances:
    .long 0, 10, 10, 12, 14, 16
    .long 10, 0, 8, 4, 9, 11
    .long 10, 8, 0, 4, 6, 9
    .long 12, 4, 4, 0, 5, 8
    .long 14, 9, 6, 5, 0, 4
    .long 16, 11, 9, 8, 4, 0

// Working variables in BSS-like section at end of data
.align 2
input_dists: .space 40
.align 2
num_dists: .long 0
.align 2
sol_count: .long 0
.align 2
visited: .space 8
.align 2
path: .space 8
.align 2
solutions: .space 256
.align 2
num_buf: .space 16

.text

_main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    mov x19, x0                    // argc
    mov x20, x1                    // argv

    cmp x19, #2
    b.lt print_usage

    // Store num_dists
    sub w21, w19, #1
    adrp x0, num_dists@PAGE
    add x0, x0, num_dists@PAGEOFF
    str w21, [x0]

    // Parse input distances
    adrp x22, input_dists@PAGE
    add x22, x22, input_dists@PAGEOFF
    mov x23, #1
parse_loop:
    cmp w23, w19
    b.ge parse_done
    ldr x0, [x20, x23, lsl #3]
    bl atoi
    sub w24, w23, #1
    str w0, [x22, x24, lsl #2]
    add x23, x23, #1
    b parse_loop
parse_done:

    // Initialize sol_count = 0
    adrp x0, sol_count@PAGE
    add x0, x0, sol_count@PAGEOFF
    str wzr, [x0]

    // Initialize visited: visited[0]=1, rest=0
    adrp x0, visited@PAGE
    add x0, x0, visited@PAGEOFF
    mov x1, #0x0000000000000001
    str x1, [x0]

    // Call DFS
    mov w0, #0
    mov w1, #0
    bl dfs

    // Get solution count
    adrp x0, sol_count@PAGE
    add x0, x0, sol_count@PAGEOFF
    ldr w19, [x0]

    cbz w19, no_solutions

    // Print header
    adrp x0, msg_found1@PAGE
    add x0, x0, msg_found1@PAGEOFF
    bl print_str
    mov w0, w19
    bl print_num
    adrp x0, msg_found2@PAGE
    add x0, x0, msg_found2@PAGEOFF
    bl print_str

    // Print each solution
    mov w20, #0
print_solutions:
    cmp w20, w19
    b.ge done

    adrp x0, msg_sol@PAGE
    add x0, x0, msg_sol@PAGEOFF
    bl print_str
    add w0, w20, #1
    bl print_num
    adrp x0, msg_colon@PAGE
    add x0, x0, msg_colon@PAGEOFF
    bl print_str

    // Get path length and solution pointer
    adrp x21, num_dists@PAGE
    add x21, x21, num_dists@PAGEOFF
    ldr w21, [x21]

    adrp x22, solutions@PAGE
    add x22, x22, solutions@PAGEOFF
    mov w23, #NUM_CITIES
    mul w23, w20, w23
    add x22, x22, w23, uxtw

    mov w23, #0
print_path:
    cmp w23, w21
    b.ge path_done

    cbz w23, skip_comma
    adrp x0, msg_comma@PAGE
    add x0, x0, msg_comma@PAGEOFF
    bl print_str
skip_comma:
    ldrb w0, [x22, w23, uxtw]
    bl print_city
    add w23, w23, #1
    b print_path

path_done:
    adrp x0, msg_newline@PAGE
    add x0, x0, msg_newline@PAGEOFF
    bl print_str
    add w20, w20, #1
    b print_solutions

no_solutions:
    adrp x0, msg_none@PAGE
    add x0, x0, msg_none@PAGEOFF
    bl print_str

done:
    mov x0, #0
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

print_usage:
    adrp x0, msg_usage@PAGE
    add x0, x0, msg_usage@PAGEOFF
    bl print_str
    mov x0, #1
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// DFS: w0=current, w1=dist_idx
dfs:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    mov w19, w0                    // current city
    mov w20, w1                    // dist_idx

    // Check if we found a solution
    adrp x0, num_dists@PAGE
    add x0, x0, num_dists@PAGEOFF
    ldr w21, [x0]
    cmp w20, w21
    b.ne try_next

    // Save solution
    adrp x0, sol_count@PAGE
    add x0, x0, sol_count@PAGEOFF
    ldr w22, [x0]
    cmp w22, #MAX_SOLUTIONS
    b.ge dfs_ret

    // Copy path to solutions[sol_count]
    adrp x1, solutions@PAGE
    add x1, x1, solutions@PAGEOFF
    mov w2, #NUM_CITIES
    mul w2, w22, w2
    add x1, x1, w2, uxtw

    adrp x2, path@PAGE
    add x2, x2, path@PAGEOFF

    mov w3, #0
copy_loop:
    cmp w3, w21
    b.ge copy_end
    ldrb w4, [x2, w3, uxtw]
    strb w4, [x1, w3, uxtw]
    add w3, w3, #1
    b copy_loop
copy_end:

    add w22, w22, #1
    adrp x0, sol_count@PAGE
    add x0, x0, sol_count@PAGEOFF
    str w22, [x0]
    b dfs_ret

try_next:
    // Get required distance
    adrp x0, input_dists@PAGE
    add x0, x0, input_dists@PAGEOFF
    ldr w21, [x0, w20, uxtw #2]

    mov w22, #0
city_loop:
    cmp w22, #NUM_CITIES
    b.ge dfs_ret

    // Check visited
    adrp x0, visited@PAGE
    add x0, x0, visited@PAGEOFF
    ldrb w23, [x0, w22, uxtw]
    cbnz w23, next_city

    // Check distance matches
    adrp x0, distances@PAGE
    add x0, x0, distances@PAGEOFF
    mov w1, #NUM_CITIES
    mul w1, w19, w1
    add w1, w1, w22
    ldr w23, [x0, w1, uxtw #2]
    cmp w23, w21
    b.ne next_city

    // Mark visited
    adrp x0, visited@PAGE
    add x0, x0, visited@PAGEOFF
    mov w1, #1
    strb w1, [x0, w22, uxtw]

    // Add to path
    adrp x0, path@PAGE
    add x0, x0, path@PAGEOFF
    strb w22, [x0, w20, uxtw]

    // Recurse
    mov w0, w22
    add w1, w20, #1
    bl dfs

    // Unmark visited
    adrp x0, visited@PAGE
    add x0, x0, visited@PAGEOFF
    strb wzr, [x0, w22, uxtw]

next_city:
    add w22, w22, #1
    b city_loop

dfs_ret:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

print_city:
    stp x29, x30, [sp, #-16]!
    and w0, w0, #0x7
    adrp x1, cities@PAGE
    add x1, x1, cities@PAGEOFF
    ldr x0, [x1, w0, uxtw #3]
    bl print_str
    ldp x29, x30, [sp], #16
    ret

print_num:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!

    adrp x19, num_buf@PAGE
    add x19, x19, num_buf@PAGEOFF
    add x19, x19, #15
    strb wzr, [x19]

    mov w1, #10
1:  sub x19, x19, #1
    udiv w2, w0, w1
    msub w3, w2, w1, w0
    add w3, w3, #'0'
    strb w3, [x19]
    mov w0, w2
    cbnz w0, 1b

    mov x0, x19
    bl print_str

    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

print_str:
    stp x29, x30, [sp, #-16]!
    mov x1, x0
1:  ldrb w2, [x1], #1
    cbnz w2, 1b
    sub x2, x1, x0
    sub x2, x2, #1
    mov x1, x0
    mov x0, #1
    mov x16, #4
    svc #0x80
    ldp x29, x30, [sp], #16
    ret

atoi:
    mov w1, #0
    mov w2, #10
1:  ldrb w3, [x0], #1
    cbz w3, 2f
    sub w3, w3, #'0'
    cmp w3, #9
    b.hi 2f
    mul w1, w1, w2
    add w1, w1, w3
    b 1b
2:  mov w0, w1
    ret
