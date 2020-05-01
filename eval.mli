(** Implements the big-step environment model semantics. *)

open Ast

open Automata

val eval_exp_init : exp -> automata * test_config

val eval_exp : exp -> automata * test_config

val eval_phrase : phrase -> automata * test_config

val string_of_automata : automata -> string

val string_of_config : test_config -> string

val a2p : id list -> automata -> atom list -> id list

val interp_expr : string -> Automata.automata * Automata.test_config

val output_action_sequence : Automata.automata -> Automata.atom list -> Ast.id list