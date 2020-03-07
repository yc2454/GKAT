open Automata_module

module type UnionFindSig = sig

  type parent = int array

  type rprst = int

  type tree = Node of (rprst * tree list)

  (* val disjointForest : 
     (Automata_module.Make.states * Automata_module.Make.states) -> 
     (tree * tree)

     val find : Automata_module.Make.state -> rprst

     val union : (rprst * rprst) -> tree

     val unionFind : Automata_module.Make.t -> Automata_module.Make.t -> bool *)

end

module Make : 
  functor (A : AutomataSig) -> 
    UnionFindSig