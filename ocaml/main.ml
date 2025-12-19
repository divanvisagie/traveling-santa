let cities = [|"North Pole"; "Helsinki"; "Oslo"; "Stockholm"; "Copenhagen"; "Berlin"|]

let distances = Hashtbl.create 15
let () =
  List.iter (fun (a, b, d) -> Hashtbl.add distances (min a b, max a b) d) [
    (0,1,10); (0,2,10); (0,3,12); (0,4,14); (0,5,16);
    (1,2,8); (1,3,4); (1,4,9); (1,5,11);
    (2,3,4); (2,4,6); (2,5,9);
    (3,4,5); (3,5,8);
    (4,5,4)
  ]

let distance a b = Hashtbl.find_opt distances (min a b, max a b)

let find_itineraries dists =
  let n = Array.length cities in
  let solutions = ref [] in
  let visited = Array.make n false in
  visited.(0) <- true;
  let rec dfs current remaining path =
    match remaining with
    | [] -> solutions := List.rev path :: !solutions
    | d :: rest ->
      for next = 0 to n - 1 do
        if not visited.(next) && distance current next = Some d then begin
          visited.(next) <- true;
          dfs next rest (next :: path);
          visited.(next) <- false
        end
      done
  in
  dfs 0 dists [];
  !solutions

let () =
  let args = Array.to_list Sys.argv |> List.tl in
  if args = [] then begin
    prerr_endline "Usage: traveling-santa <distance1> <distance2> ...";
    exit 1
  end;
  let dists = List.map int_of_string args in
  let solutions = find_itineraries dists in
  if solutions = [] then
    print_endline "No valid itineraries found"
  else begin
    Printf.printf "Found %d solution(s):\n\n" (List.length solutions);
    List.iteri (fun i sol ->
      Printf.printf "Solution %d: %s\n" (i + 1)
        (String.concat ", " (List.map (fun c -> cities.(c)) sol))
    ) solutions
  end
