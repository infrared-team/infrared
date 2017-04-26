(* Generic Stack data structure *)

module Stack : sig
  type 'a t = Node of 'a * 'a t | Nil
  val create : 'a -> 'a t
  val push : 'a t -> 'a -> 'a t
  val pop : 'a t -> 'a t
  val size : 'a t -> int
end = struct
  type 'a t = 
    | Node of 'a * 'a t
    | Nil
  let create n = Node (n, Nil)
  let push s n = Node (n, s)
  let pop s = 
    match s with
    | Node (n, s) -> s
    | Nil -> s
  let size s = 
    let rec _size s n =
      match s with 
      | Node (_, s) -> _size s (n + 1)
      | Nil -> n
    in _size s 0
end
