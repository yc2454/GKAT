%{
open Ast
open Ast_factory

let has_dups lst =
  let open List in
  length lst <> length (sort_uniq Stdlib.compare lst)
%}

%token <string> AID TID
%token AND OR NOT
%token LPAREN RPAREN DOUBLE_SEMI
%token TRUE FALSE
%token EOF

%right OR
%right AND

%start <Ast.exp> parse_expression
%start <Ast.phrase> parse_phrase

%%

parse_expression:
  | e = expr; EOF
        { e }
        ;

parse_phrase:
	| e = expr; DOUBLE_SEMI?; EOF
		{ Exp e }
  | DOUBLE_SEMI?; EOF
        { raise End_of_file }
	;

expr:
  | p = AID
            { make_avar p }
  | b = bool_expr
            { make_assert b }
  | e = expr; AND; f = expr
		{ make_seq e f }
  | b = bool_expr; AND; e = expr
    { make_seq (make_assert b) e}
  | e = expr; AND; b = bool_expr
    { make_seq e (make_assert b)}
  | e = expr; OR; b = bool_expr; f = expr
		{ make_if e b f }
  | e = expr; LPAREN; b = bool_expr; RPAREN
            { make_while b e }
  | e = simple_expr
            { e }
            ;

bool_expr:
  | TRUE
		{ make_bool true }
  | FALSE
		{ make_bool false }
  | LPAREN; e1 = bool_expr; AND; e2 = bool_expr; RPAREN
		{ make_and e1 e2 }
  | e1 = bool_expr; OR; e2 = bool_expr
		{ make_or e1 e2 }
  | NOT; e = bool_expr
            { make_not e }
  | t = TID
            { make_bvar t }
            ;

simple_expr:
  | LPAREN; e = expr; RPAREN
        { e }
  | LPAREN; b = bool_expr; RPAREN
        { make_assert b }
