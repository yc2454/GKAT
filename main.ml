(******************************************************************************
   You do not need to modify anything in this file.
 ******************************************************************************)

open Ast
open Eval
open Automata

let interp_expr s =
  try
    s
    |> Parse.parse_expr
    |> Eval.eval_exp_init
    |> (fun (a, c) -> string_of_automata a ^ "\n" ^ string_of_config c)
  with
    Parse.SyntaxError s | Failure s -> s

let interp_phrase s =
  try
    s
    |> Parse.parse_phrase
    |> (fun p -> Eval.eval_phrase p)
    |> (fun (a, c) -> string_of_automata a ^ "\n" ^ string_of_config c)
  with
  | Parse.SyntaxError s | Failure s -> s
  | End_of_file -> ""
