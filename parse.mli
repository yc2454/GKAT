(** Driver for the SQL parser. *)

(** Raised to signal a syntax error. *)
exception SyntaxError of string

(** [parse_clause s] parses [s] as a clause. *)
val parse_expr : string -> Ast.exp

(** [parse_phrase s] parses [s] as a phrase *)
val parse_phrase : string -> Ast.phrase
