Ocaml-QuickCheck -- Translation of QuickCheck to OCaml
======================================================

This is translation of
[QuickCheck](http://www.cs.chalmers.se/~rjmh/QuickCheck/) from
[Haskell](http://www.haskell.org/) into
[Ocaml](http://caml.inria.fr/).

Forked from [Alan Falloon's ocaml-quickcheck](http://github.com/alanfalloon/ocaml-quickcheck),
but uses regular high-order-functions, and doesn't try to mimic haskell
[type-classes](http://www.haskell.org/tutorial/classes.html) with
OCamls [modules](http://caml.inria.fr/pub/docs/manual-ocaml/manual004.html).
Maybe, it's not all that pretty, but it works!
For some examples see [tests/test.ml](https://github.com/camlunity/ocaml-quickcheck/blob/master/tests/test.ml).
More docs and examples coming soon.

If you are interested in original implementation
you can go to Alan Falloon's blog to hear more about
[how he converted the code and the differences that were introduced](http://brierwoodapps.com/ocaml-quickcheck-translating-quickcheck-from-haskell-type-classes-to-ocaml-modules/).

Btw, with OCaml 3.12 you can somehow simplify original code
with first-class modules. You can check branch "first-class-modules"
in this repo to see some work in this field. However, HOFs still simplier
than modules and functors.
