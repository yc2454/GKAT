# Interpreter

This an interpreter of the model language GKAT. Currently,
several tasks are supported:

## Translating

Take in a GKAT expression, parse it and construct an automaton structure

## Equivalence Checking

Normalize the automata obtained from above and check equivalence of two 
GKAT expressions using a Union-Find algorithm

# Usage

## Translating

The procedure below is an example of translation, and we show the correctness of the translation by feeding in atoms and checking the output actions. This is because the language denoted by GKAT satisfies the *Determinacy Property*

```bash
cd Interpreter/
make
```
```Ocaml
let (automata, test_config) = Eval.interp_expr "p1*p2*(p3 +b1 p4)*p5(b2)"
Eval.a2p [] automata [[("b1", true); ("b2", true)]; [("b1", true); ("b2", true)]; [("b1", false); ("b2", true)]; [("b1", true); ("b2", true)]; [("b1", true); ("b2", true)]; [("b1", true); ("b2", false)];]
```

It should output ["p1"; "p2"; "p4"; "p5"; "p5"]. 