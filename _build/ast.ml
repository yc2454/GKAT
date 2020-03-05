(** The abstract syntax tree type. *)

type id = string

type bexp = 
  | False
  | True
  | And of (bexp * bexp)
  | Or of (bexp * bexp)
  | Not of bexp
  | Bvar of id

type exp = 
  | Assert of bexp
  | Avar of id
  | If of (exp * bexp * exp)
  | Seq of (exp * exp)
  | While of (bexp * exp)

type phrase = 
  | Exp of exp