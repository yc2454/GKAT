open Automata_module

module type UnionFindSig = sig

  type parent = int array

  type rprst = int

  type tree = Node of (rprst * tree list)

  val disjointForest : 
    (Automata_module.Make.states * Automata_module.Make.states) -> 
    (tree * tree)

end

module Make =
  functor (A : AutomataSig) -> 
  struct

  end