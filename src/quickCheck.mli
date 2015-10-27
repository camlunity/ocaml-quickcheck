
type 'a show = 'a -> string

val show_bool : bool show

val show_char : char show

val show_string : string show

val show_int : int show

val show_int32 : int32 show

val show_int64 : int64 show

val show_float : float show

val show_pair : 'a show -> 'b show -> 'a * 'b -> string

val show_triple : 'a show -> 'b show -> 'c show -> 'a * 'b * 'c -> string

val show_list : 'a show -> 'a list -> string

type 'a arbitrary = 'a QuickCheck_gen.gen

val arbitrary_unit : unit QuickCheck_gen.gen

val arbitrary_bool : bool QuickCheck_gen.gen

val arbitrary_char : char QuickCheck_gen.gen

val arbitrary_byte : char QuickCheck_gen.gen

val arbitrary_string : string QuickCheck_gen.gen

val arbitrary_bytesequence : string QuickCheck_gen.gen

val arbitrary_stringN : int -> string QuickCheck_gen.gen

val arbitrary_bytesequenceN : int -> string QuickCheck_gen.gen

val arbitrary_int : int QuickCheck_gen.gen

val arbitrary_int32 : int32 QuickCheck_gen.gen

val arbitrary_int64 : int64 QuickCheck_gen.gen

val arbitrary_float : float QuickCheck_gen.gen

val arbitrary_pair : 'a arbitrary ->
                     'b arbitrary ->
                     ('a * 'b) QuickCheck_gen.gen

val arbitrary_triple : 'a arbitrary ->
                       'b arbitrary ->
                       'c arbitrary ->
                       ('a * 'b *'c) QuickCheck_gen.gen

val arbitrary_list : 'a arbitrary -> 'a list QuickCheck_gen.gen

val arbitrary_listN : int -> 'a QuickCheck_gen.gen -> 'a list QuickCheck_gen.gen

type result = {
  ok : bool option;
  stamp : string list;
  arguments : string list;
}

type property = Prop of result QuickCheck_gen.gen

type 'a testable = 'a -> property

val nothing : result

val result : result -> property

val testable_unit : unit testable

val testable_bool : bool testable

val testable_tesult : result testable

val testable_property : property testable

val evaluate : 'a testable -> 'a -> result QuickCheck_gen.gen

val for_all : 'a show -> 'b testable -> 'a QuickCheck_gen.gen -> ('a -> 'b) -> property

val testable_fun : 'a arbitrary -> 'a show -> 'b testable -> ('a -> 'b) testable

val implies : 'a testable -> bool -> 'a testable

val label : 'a testable -> string -> 'a testable

val classify : 'a testable -> bool -> string -> 'a testable

val trivial : 'a testable -> bool -> 'a testable

val collect : 'a show -> 'b testable -> 'a -> 'b -> property
                                              (* 'b property  *)

type config = {
  maxTest : int;
  maxFail : int;
  size : int -> int;
  every : Format.formatter -> int * string list -> unit;
}

type testresult = Success
                | Failure of int
                | Exhausted of int

val quick : config
val verbose : config
val done_ : string -> int -> string list list -> unit
val tests : config ->
  result QuickCheck_gen.gen ->
  int ->
  int ->
  string list list ->
  testresult

val check : 'a testable -> config -> 'a -> testresult
val quickCheck : 'a testable -> 'a -> testresult
val verboseCheck : 'a testable -> 'a -> testresult

