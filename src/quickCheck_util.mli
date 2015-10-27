
module Random : sig

  include module type of Random

  val char : char -> char

  val int_range : int * int -> int

  val int32_range : Int32.t * Int32.t -> Int32.t

  val int64_range : Int64.t * Int64.t -> Int64.t

  val nativeint_range : Nativeint.t * Nativeint.t -> Nativeint.t

  val float_range : float * float -> float

  val char_range : char * char -> char

end


module List : sig

  include module type of List

  val span : ('a -> bool) -> 'a list -> 'a list * 'a list

  val group_by : ('a -> 'a -> bool) -> 'a list -> 'a list list

  val group : 'a list -> 'a list list

end

val charlist_to_string : char list -> string

val join_string_list : string list -> string -> string

val sum_int : int list -> int

#if ocaml_version < (4, 01)
val ( |> ) : 'a -> ('a -> 'b) -> 'b
#endif
val ( <| ) : ('a -> 'b) -> 'a -> 'b

val ( % ) : ('a -> 'b) -> ('c -> 'a) -> 'c -> 'b
