open Ast
open Automata

let empty_func (s : state) (a : atom) : output = 
  Reject

let rec get_config_bexp acc b = 
  let have_dup =
    match b with
    | Bvar bid -> bid :: acc
    | And (b1, b2) -> get_config_bexp acc b1 @ get_config_bexp acc b2 
    | Or (b1, b2) -> get_config_bexp acc b1 @ get_config_bexp acc b2 
    | Not b -> get_config_bexp acc b
    | _ -> acc
  in
  List.sort_uniq compare have_dup

let rec get_config acc e =
  let have_dup =
    match e with
    | Assert b -> get_config_bexp acc b
    | Avar p -> acc
    | If (e, b, f) -> get_config_bexp acc b @ get_config acc e @ 
                      get_config acc f
    | Seq (e, f) -> get_config acc e @ get_config acc f
    | While (b, e) -> get_config_bexp acc b @ get_config acc e
  in
  List.sort_uniq compare have_dup

let rec bexp_name b = 
  match b with
  | True -> "true"
  | False -> "false"
  | Bvar bid -> bid
  | And (b1, b2) -> (bexp_name b1) ^ " " ^ "and" ^ " " ^ (bexp_name b2)
  | Or (b1, b2) -> (bexp_name b1) ^ " " ^ "or" ^ " " ^ (bexp_name b2)
  | Not b -> "not" ^ " " ^ bexp_name b

let rec exp_name e = 
  match e with
  | Assert b -> "assert" ^ " " ^ (bexp_name b)
  | Avar p -> "action" ^ " " ^ p
  | If (e, b, f) -> "if" ^ " " ^ (bexp_name b) ^ "then" ^ " " ^ (exp_name e)
                    ^ " " ^ "else" ^ " " ^ (exp_name f)
  | Seq (e, f) -> (exp_name e) ^ " " ^ "then" ^ " " ^ (exp_name f)
  | While (b, e) -> "while" ^ " " ^ (bexp_name b) ^ " " ^ "do" 
                    ^ " " ^ (exp_name e)

let rec atom_less_than_test a b =
  match b with
  | True -> true
  | False -> false
  | Bvar test_id -> List.assoc test_id a
  | And (b1, b2) -> (atom_less_than_test a b1) && (atom_less_than_test a b2)
  | Or (b1, b2) -> (atom_less_than_test a b1) || (atom_less_than_test a b2)
  | Not b -> not (atom_less_than_test a b)

let eval_assert b : (automata * test_config) = 
  let s = State (exp_name (Assert b)) in
  let (func : state -> atom -> output) = 
    fun state a -> 
      if state = s then 
        if (atom_less_than_test a b) then Accept else Reject
      else Reject
  in
  ([s], func, s), get_config_bexp [] b

let eval_action p : (automata * test_config) =
  let s_normal = State (exp_name (Avar p)) in
  let s_init = State ((exp_name (Avar p)) ^ " init") in
  let (func : state -> atom -> output) = 
    fun s a -> 
      if s = s_init then Transition (p, s_normal)
      else 
      if s = s_normal then Accept else Reject
  in
  ([s_init; s_normal], func, s_init), []

let rec eval_exp e =
  match e with
  | Assert b -> eval_assert b
  | Avar p -> eval_action p
  | If (e, b, f) -> eval_if (e, b, f)
  | Seq (e, f) -> eval_seq (e, f)
  | While (b, e) -> eval_while (b, e)

and 

  eval_if (e, b, f) = 
  let ((x_e, theta_e, init_e), config_e), ((x_f, theta_f, init_f), config_f) = 
    (eval_exp e), (eval_exp f)
  in
  let s_init = State ((exp_name (If (e, b, f))) ^ " init") in
  let func = 
    fun s a ->
      if s = s_init then 
        if (atom_less_than_test a b) then (theta_e init_e a) 
        else (theta_f init_f a)
      else 
      if List.exists (fun st -> s = st) x_e then (theta_e s a) 
      else (theta_f s a)
  in
  (s_init :: (x_e @ x_f), func, s_init),
  List.sort_uniq compare (get_config_bexp [] b @ config_e @ config_f)

and

  eval_seq (e, f) = 
  let ((x_e, theta_e, init_e), config_e), ((x_f, theta_f, init_f), config_f) = 
    (eval_exp e), (eval_exp f)
  in
  let s_init = State ((exp_name (Seq (e, f))) ^ " init") in
  let func = 
    fun s a ->
      if s = s_init then 
        if (theta_e init_e a) = Accept then (theta_f init_f a) 
        else (theta_e init_e a)
      else 
      if List.exists (fun st -> s = st) x_e && (theta_e s a) = Accept then 
        (theta_f init_f a) 
      else 
      if List.exists (fun st -> s = st) x_e then (theta_e s a) else
        (theta_f s a)
  in
  (s_init :: (x_e @ x_f), func, s_init), 
  List.sort_uniq compare (config_e @ config_f)

and 

  eval_while (b, e) = 
  let (x_e, theta_e, init_e), config_e = eval_exp e in
  let s_init = State ((exp_name (While (b, e))) ^ " init") in
  let func = 
    fun s a ->
      let init_func = 
        fun a -> 
          if not (atom_less_than_test a b) then Accept
          else if ((atom_less_than_test a b) && (theta_e init_e a) = Accept)
          then Reject
          else theta_e init_e a
      in
      if s = s_init then init_func a else 
      if List.exists (fun st -> s = st) x_e && (theta_e s a) = Accept then 
        init_func a
      else theta_e s a
  in
  (s_init :: x_e, func, s_init), 
  List.sort_uniq compare ((get_config_bexp [] b) @ config_e)

let rec string_of_automata (atmt : automata) : string = 
  let (x, theta, l) = atmt in
  match x with
  | [] -> "END"
  | h :: t -> 
    let State (s_id) = h in
    s_id ^ "  |  " ^ (string_of_automata (t, theta, l))

let rec string_of_config cfg : string = 
  match cfg with 
  | [] -> "END"
  | h :: t -> h ^ "  |  " ^ string_of_config t

let eval_exp_init e =
  eval_exp e

let eval_phrase ph =
  match ph with
  | Exp exp -> 
    eval_exp exp