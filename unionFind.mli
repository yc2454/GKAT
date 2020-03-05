open Automata_module

module type UnionFindSig = sig

  type parent = int array

  type value = int

  type tree = Node of (value * tree list)

end

module Make : 
  functor (A : AutomataSig) -> 
    UnionFindSig