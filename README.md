# GKAT Interpreter

This an student made interpreter of the model language GKAT. Currently,
several tasks are supported:

## Translating

Take in a GKAT expression, parse it and construct an automaton structure

## Equivalence Checking

Normalize the automata obtained from above and check equivalence of two 
GKAT expressions using a Union-Find algorithm

## Usage

### Translating

First, a repl can directly show the resulting automaton:
```bash
make repl
```
In the repl, type in a GKAT expression, the repl returns the states and the test configuration of the automaton. Each state is named after the action is produces.

Moreover, the procedure below is an example of translation, and we show the correctness of the translation by feeding in atoms and checking the output actions. This is because the language denoted by GKAT satisfies the *Determinacy Property*

The procedure is done in Utop.

```bash
cd GKAT/
make
```
```Ocaml
(* get the automata from a GKAT string *)
let (automata, test_config) = interp_expr "p1*p2*(p3 +b1 p4)*p5(b2)";;
(* design the sequence of atoms *)
let atom_list = [[("b1", true); ("b2", true)]; [("b1", true); ("b2", true)]; [("b1", false); ("b2", true)]; [("b1", true); ("b2", true)]; [("b1", true); ("b2", true)]; [("b1", true); ("b2", false)];];;
(* call function to output the actions *)
output_action_sequence automata atom_list;;
```

The function output_action_sequence that we use above has the type
```Ocaml
output_action_sequence : Automata.automata -> Automata.atom list -> Ast.id list
```
it takes in a list of atoms, and outputs the determinated actions from the automaton.
The output should be ["p1"; "p2"; "p4"; "p5"; "p5"]. 

### Checking equivalence
The function check_equiv will take two GKAT strings, convert them to automata, normalize the automata, and then the use Union-Find algorithm to check their equivalence

```bash
make
```
```Ocaml
check_equiv "p1*p2" "p1*p3";;
```

It will output "not equal"