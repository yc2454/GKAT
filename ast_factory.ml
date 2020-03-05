open Ast

let make_seq e1 e2 =
  Seq (e1, e2)

let make_bool b = 
  if b then True else False

let make_and e1 e2 =
  And (e1, e2)

let make_or e1 e2 =
  Or (e1, e2)

let make_not e = 
  Not (e)

let make_if e1 e2 e3 =
  If (e1, e2, e3)

let make_while b e =
  While (b, e)

let make_bvar x =
  Bvar x

let make_avar x = 
  Avar x

let make_assert b = 
  Assert b