
(* The type of tokens. *)

type token = 
  | TRUE
  | TID of (string)
  | RPAREN
  | OR
  | NOT
  | LPAREN
  | FALSE
  | EOF
  | DOUBLE_SEMI
  | AND
  | AID of (string)

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val parse_phrase: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Ast.phrase)

val parse_expression: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Ast.exp)
