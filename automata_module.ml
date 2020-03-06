open Ast
open Automata

module type AutomataSig = sig

  type test_config = id list

  type state = 
      State of string

  type atom = (id * bool) list

  type output = 
      Accept
    | Reject
    | Transition of (id * state)

  type transition_map = state -> atom -> output

  type states = state list

  type t = (state list * transition_map * state)

  val get_states : t -> state list

end

open Automata

module Make : AutomataSig = struct

  type test_config = id list

  type state = 
      State of string

  type atom = (id * bool) list

  type output = 
      Accept
    | Reject
    | Transition of (id * state)

  type transition_map = state -> atom -> output

  type states = state list

  type t = (state list * transition_map * state)

  let get_states a = 
    let (s, _, _) = a in s

end