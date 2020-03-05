open OUnit2
open Eval
open Automata

let make_test name v output = 
  name >:: (fun _ -> 
      assert_equal v output)

let gkat_exp_act = "p"
let gkat_exp_asrt = "b"
let gkat_exp_seq = "p1*p2"
let gkat_exp_if = "p3 +(b1 * b2) p4"
let gkat_exp_while = "p5(b2)"

let empty_func (s : state) (a : atom) : output = 
  Reject

let get_atmt_from_str s = 
  let (a, _) = 
    try
      s
      |> Parse.parse_expr
      |> Eval.eval_exp_init
    with
      Parse.SyntaxError s | Failure s -> 
      (([State ""], empty_func, State ""), [])
  in
  a

let get_cfg_from_str s = 
  let (_, c) = 
    try
      s
      |> Parse.parse_expr
      |> Eval.eval_exp_init
    with
      Parse.SyntaxError s | Failure s -> 
      (([State ""], empty_func, State ""), [])
  in
  c

let make_map_test (theta : transition_map) x a = 
  theta x a

let get_map a = 
  let (_, theta, _) = a in
  theta

let func_tests = [
  make_test "simple action init state" 
    ((gkat_exp_act |> get_atmt_from_str |> get_map) (State "action p init") [])
    (Transition ("p", State "action p"));

  make_test "simple action normal state" 
    ((gkat_exp_act |> get_atmt_from_str |> get_map) (State "action p") [])
    Accept;

  make_test "single test config"
    (gkat_exp_asrt |> get_cfg_from_str) ["b"];

  make_test "single test accept"
    ((gkat_exp_asrt |> get_atmt_from_str |> get_map) (State "assert b") 
       [("b", true)])
    Accept;

  make_test "single test reject"
    ((gkat_exp_asrt |> get_atmt_from_str |> get_map) (State "assert b") 
       [("b", false)])
    Reject;

  make_test "if init state, atom less than b" 
    ((gkat_exp_if |> get_atmt_from_str |> get_map) 
       (State "if b1 and b2then action p3 else action p4 init") 
       [("b1", true); ("b2", true)])
    (Transition ("p3", State "action p3"));

  make_test "if init state, atom more than b" 
    ((gkat_exp_if |> get_atmt_from_str |> get_map) 
       (State "if b1 and b2then action p3 else action p4 init") 
       [("b1", true); ("b2", false)])
    (Transition ("p4", State "action p4"));

  make_test "if normal state" 
    ((gkat_exp_if |> get_atmt_from_str |> get_map) 
       (State "action p3") 
       [("b1", true); ("b2", true)])
    Accept;

  make_test "while init state atom more than b"
    ((gkat_exp_while |> get_atmt_from_str |> get_map) 
       (State "while b2 do action p5 init") 
       [("b2", false)])
    Accept;

  (* make_test "while init state atom less than b, action accepts"
     ((gkat_exp_while |> get_atmt_from_str |> get_map) 
       (State "while b2 do action p5 init") 
       [("b2", true)])
     Reject; *)
]

let suite = "search test suite" >::: func_tests

let _ = run_test_tt_main suite