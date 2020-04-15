open Automata_module
open Automata
open Two_list_queue

module A = Automata_module.Make

module TLQ = TwoListQueue

let add a array = Array.append [|a|] array

(* let find_assoc_f v_target (v, r) =
   if v_target = v then r else v_target

   let find_assoc v_target array =
   Array.fold_left find_assoc_f v_target array *)

module StringMap = Map.Make(String)

class union_find x y = object(self)

  val forest = ref StringMap.empty

  val size = ref StringMap.empty

  method find (v : string) = 
    let r = StringMap.find v !forest in
    if r = v then r else self#find r

  method union (r_v : string) (r_u : string) = 
    let s_rv, s_ru = (StringMap.find r_v !size), (StringMap.find r_u !size) in
    if s_rv > s_ru then 
      ((forest := StringMap.add r_v r_u !forest); 
       (size := StringMap.add r_u (s_ru + s_rv) !size))
    else ((forest := StringMap.add r_v r_u !forest);
          (size := StringMap.add r_v (s_ru + s_rv) !size))

  method construct x y = 
    match x, y with
    | [], [] -> ()
    | hx :: tx, [] -> 
      let State sx = hx in
      forest := StringMap.add sx sx !forest;
      size := StringMap.add sx 1 !size;
      self#construct tx []
    | [], hy::ty -> 
      let State sy = hy in
      forest := StringMap.add sy sy !forest;
      size := StringMap.add sy 1 !size;
      self#construct [] ty
    | hx :: tx, hy::ty -> 
      let State sx, State sy = hx, hy in
      forest := StringMap.add sx sx !forest;
      forest := StringMap.add sy sy !forest;
      size := StringMap.add sx 1 !size;
      size := StringMap.add sy 1 !size;
      self#construct tx []

  initializer self#construct x y
end

let rec add_to_ll a ll = 
  match ll with 
  | l :: ls -> (a :: l) :: (add_to_ll a ls)
  | [] -> [[a]]

let rec one_len len acc lst = 
  match lst with
  | x :: xs -> 
    if List.length x = len then one_len len (x::acc) xs
    else one_len len acc xs
  | [] -> acc

let sort_atoms len all = 
  all |> List.sort_uniq compare |> one_len len []

let rec all_atoms config = 
  let all = 
    match config with
    | x :: xs -> (add_to_ll (x, true) (all_atoms xs)) 
    @ (add_to_ll (x, false) (all_atoms xs))
    | [] -> []
  in
  sort_atoms (List.length config) all

let check (aX : automata) (aY : automata) ats = 

  let (x, theta_x, lx), (y, theta_y, ly) = aX, aY in
  let todo = ref (TLQ.enqueue (lx, ly) TLQ.empty) in
  let df = new union_find (lx::x) (ly::y) in
  let flag = ref true in
  while not (TLQ.is_empty !todo) do
    let (State st_x, State st_y) = 
      match (TLQ.peek !todo) with
      | Some(sx, sy) -> (sx, sy)
      | None -> failwith "unexpected"
    in
    match TLQ.dequeue !todo with
    | None -> ()
    | Some q -> todo := q; 
      let (r_x, r_y) = 
      try
        df#find st_x, df#find st_y 
      with
      | Not_found -> failwith "cao"
      in
      if r_x = r_y then ()
      else if List.length ats = 0 then flag := false else
        for x=0 to (List.length ats) do
          let a_ats = Array.of_list ats in
          let at = a_ats.(x) in
          match (theta_x (State st_x) at), (theta_y (State st_y) at) with
          | Accept, Accept
          | Reject, Reject -> ()
          | Transition (_, State st_x'), Transition (_, State st_y') ->
            todo := (TLQ.enqueue ((State st_x'), (State st_y')) !todo)
          | _ -> flag := false
        done;
      df#union r_x r_y
  done;
  if !flag then print_endline "automata equal" else print_endline "automata not equal"

let x = ([], (fun a b -> Accept), State "a")
let y = ([], (fun a b -> Accept), State "a")
let atoms = []

let () = 
  check x y atoms