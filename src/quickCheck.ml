
open QuickCheck_util
open QuickCheck_gen


type 'a show = 'a -> string

let show_bool = Printf.sprintf "%B"

let show_char = Printf.sprintf "%C"

let show_string x = Printf.sprintf "\"%s\"" (String.escaped x)

let show_int = string_of_int

let show_int32 = Printf.sprintf "%ldl"

let show_int64 = Printf.sprintf "%LdL"

let show_float = string_of_float

let show_pair show_fst show_snd (fst, snd) =
  let (sfst, ssnd) = (show_fst fst, show_snd snd) in
  Printf.sprintf "(%s, %s)" sfst ssnd

let show_triple show_fst show_snd show_trd (fst, snd, trd) =
  let (sf, ss, st) = (show_fst fst, show_snd snd, show_trd trd) in
  Printf.sprintf "(%s, %s, %s)" sf ss st

let show_list show_elt lst =
  Printf.sprintf "[%s]" (join_string_list (List.map show_elt lst) ";")

type 'a arbitrary = 'a gen

let arbitrary_unit = ret_gen ()

let arbitrary_bool = elements [true; false]

let arbitrary_char = choose_int (32,255) >>= fun c -> ret_gen (Char.chr c)

let arbitrary_byte = choose_int (0,255) >>= fun c -> ret_gen (Char.chr c)

let arbitrary_string = list arbitrary_char >>= (fun cl ->
  ret_gen (charlist_to_string cl))

let arbitrary_bytesequence = list arbitrary_byte >>= (fun cl ->
  ret_gen (charlist_to_string cl))

let arbitrary_stringN n = (listN n arbitrary_char) >>= (fun cl ->
  ret_gen (charlist_to_string cl))

let arbitrary_bytesequenceN n = (listN n arbitrary_byte) >>= (fun cl ->
  ret_gen (charlist_to_string cl))

let arbitrary_int = sized (fun n -> choose_int (-n, n))

let arbitrary_int32 = arbitrary_int >>= fun a -> arbitrary_int >>= fun b->
  ret_gen Int32.(add (of_int a) (of_int b))

let arbitrary_int64 = arbitrary_int32 >>= fun a -> arbitrary_int32 >>= fun b->
  ret_gen Int64.(add (of_int32 a) (of_int32 b))

let arbitrary_float = arbitrary_int >>= fun a -> arbitrary_int >>= fun b ->
  sized choose_int0 >>= fun c -> ret_gen
  (float a +. (float b /. (float c +. 1.)))

let arbitrary_pair arbitrary_fst arbitrary_snd =
  arbitrary_fst >>= fun v1 -> arbitrary_snd >>= fun v2 -> ret_gen (v1,v2)

let arbitrary_triple arbitrary_fst arbitrary_snd arbitrary_trd =
  arbitrary_fst >>= fun v1 ->
  arbitrary_snd >>= fun v2 ->
  arbitrary_trd >>= fun v3 ->
  ret_gen (v1,v2,v3)

let arbitrary_list arbitrary_elt = list arbitrary_elt

let arbitrary_listN n arbitrary_elt = listN n arbitrary_elt

type result = {
  ok : bool option;
  stamp : string list;
  arguments : string list;
}

type property = Prop of result gen

type 'a testable = 'a -> property

let nothing : result = {ok=None; stamp=[]; arguments=[]}

let result : result -> property =
  fun res -> Prop (ret_gen res)


let testable_unit () = result nothing

let testable_bool b = result {nothing with ok=Some b}

let testable_tesult r = result r

let testable_property p = p

let evaluate testable arg =
  let Prop gen = testable arg in
  gen

let for_all show testable gen body =
  let eval = evaluate testable in
  let argument a res =
    {res with arguments = (show a)::res.arguments }
  in
  Prop (gen >>= (fun a ->
    eval (body a) >>= (fun res ->
      ret_gen (argument a res)))
  )

let testable_fun arbitrary show testable f =
  for_all show testable arbitrary f

let implies testable b a =
  if b then testable a
  else testable_unit ()
(* ==> *)

let label testable s a =
  let eval = evaluate testable in
  let add r = {r with stamp = s :: r.stamp } in
  let a' = eval a in
  Prop (map_gen add a')

let classify testable b =
  let lbl = label testable in
  if b then lbl
  else (fun _ -> testable)

let trivial testable b =
  classify testable b "trivial"

let collect show testable sv tv =
  (label testable) (show sv) tv

type config = {
  maxTest : int;
  maxFail : int;
  size    : int -> int;
  every   : Format.formatter -> int * string list -> unit;
}

let quick = {
  maxTest = 100;
  maxFail = 1000;
  size    = (fun n -> 3 + n / 2);
  every   = (fun _ (_, _) -> ())
}

let verbose = {
  quick with
    every = begin fun f (n, args) ->
      let pargs fmt l =
        List.iter (fun a -> Format.fprintf fmt "@ %s" a) l
      in
      Format.fprintf f "@[%d:@[<hov 2>%a@]@]@." n pargs args
    end
}

let done_ mesg ntest stamps =
  let percentage n m =
    Format.sprintf "%2d%%" ((100 * n) / m)
  in
  let entry (n, xs) =
    Format.sprintf "%s %s" (percentage n ntest) (String.concat ", " xs)
  in
  let pairLength l = match l with
    | (xs::_) as xss -> (List.length xss, xs)
    | [] -> assert false
  in
  let display l = match l with
    | [] -> ".\n"
    | [x] -> Format.sprintf " (%s).\n" x
    | xs ->
      String.concat "\n" ("." :: List.map (Format.sprintf "%s.") xs)
  in
  let not_null = function [] -> false | _ -> true in
  let table =
    List.filter not_null stamps |> List.sort compare |>
        List.group |> List.map pairLength |> List.sort compare |>
            List.rev |> List.map entry |> display
    in
    Format.printf "%s %d tests%s" mesg ntest table

type testresult = Success
                | Failure of int
                | Exhausted of int

let rec tests config gen ntest nfail stamps =
  let () = Random.self_init () in
  if ntest = config.maxTest
  then
    let () = done_ "OK, passed" ntest stamps in
    Success
  else if nfail = config.maxFail
  then
    let () = done_ "Arguments exhausted after" nfail stamps in
    Exhausted nfail
  else begin
    let result = generate (config.size ntest) gen in
    let () =
      Format.printf "@[%a@]@?" config.every (ntest, result.arguments)
    in
    match result.ok with
      | None ->
        tests config gen ntest (nfail+1) stamps
      | Some true ->
        tests config gen (ntest+1) nfail (result.stamp :: stamps)
      | Some false ->
        Format.printf "@[<2>Falsifiable, after %d tests:\n %s."
          ntest (join_string_list result.arguments "\n");
        Failure ntest
  end

let check testable cfg a =
  let eval = evaluate testable in
  tests cfg (eval a) 0 0 []

let quickCheck testable = check testable quick
let verboseCheck testable = check testable verbose

