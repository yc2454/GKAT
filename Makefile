UNITS=ast_factory parse eval main repl automata_module unionFind two_list_queue
MLS_WITHOUT_MLIS=ast test automata check
MLS=$(UNITS:=.ml) $(MLS_WITHOUT_MLIS:=.ml)
OBJECTS=$(UNITS:=.cmo) $(MLS_WITHOUT_MLIS:=.cmo) parser.cmo
MLIS=$(UNITS:=.mli)
TEST=test.byte
REPL=repl.byte
CHECK=check.byte
OCAMLBUILD=ocamlbuild -use-ocamlfind -plugin-tag 'package(bisect_ppx-ocamlbuild)'
PKGS=oUnit,str

default: build
	utop

build:
	$(OCAMLBUILD) $(OBJECTS)

test:
	$(OCAMLBUILD) -tag debug $(TEST) && ./$(TEST)

bisect-test:
	BISECT_COVERAGE=YES $(OCAMLBUILD) -tag 'debug' $(TEST) && ./$(TEST) -runner sequential

bisect: clean bisect-test
	bisect-ppx-report -I _build -html report bisect0001.out

repl:
	$(OCAMLBUILD) $(REPL) && ./$(REPL)

check:
	$(OCAMLBUILD) $(CHECK) && ./$(CHECK)

finalcheck: check
	bash checkzip.sh
	bash finalcheck.sh

zip:
	zip a6src.zip *.ml* _tags Makefile

docs: docs-public docs-private

docs-public: build
	mkdir -p doc.public
	ocamlfind ocamldoc -I _build -package $(PKGS) \
		-html -stars -d doc.public $(MLIS)

docs-private: build
	mkdir -p doc.private
	ocamlfind ocamldoc -I _build -package $(PKGS) \
		-html -stars -d doc.private \
		-inv-merge-ml-mli -m A -hide-warnings $(MLIS) $(MLS)

clean:
	ocamlbuild -clean
	rm -rf doc.public doc.private a6src.zip report bisect*.out