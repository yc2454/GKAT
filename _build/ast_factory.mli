(** Builds AST nodes for the parser. *)

(*******************************************************************************
   This AST "factory" contains functions that the parser calls to produce
   AST nodes.  This design enables the parser to be ignorant of the
   names of the constructors of your AST, thus enabling everyone in the
   class to design their own AST type.

   You don't want to change any of the names or types appearing in this
   factory, because then the Menhir parser in `parser.mly` would have to be
   modified---something you really don't want to do.
 ******************************************************************************)

open Ast

(** [make_seq e1 e2] represents [e1; e2] *)
val make_seq : exp -> exp -> exp

(** [make_and e1 e2] represents [e1 && e2] *)
val make_and : bexp -> bexp -> bexp

(** [make_or e1 e2] represents [e1 || e2] *)
val make_or : bexp -> bexp -> bexp

val make_bool : bool -> bexp

val make_not : bexp -> bexp

(** [make_if e1 e2 e3] represents [if e1 then e2 else e3] *)
val make_if : exp -> bexp -> exp -> exp

(** [make_while e1 e2] represents [while e1 do e2 done] *)
val make_while : bexp -> exp -> exp

val make_assert : bexp -> exp

val make_avar : id -> exp

val make_bvar : id -> bexp