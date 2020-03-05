open Ast

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

  type t = (state list * transition_map * state)

  val get_states : t -> state list

end

module Make : AutomataSig