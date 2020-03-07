module type MyQueue = sig
  (* An ['a queue] is a queue whose elements have type ['a]. *)
  type 'a queue

  (* The empty queue. *)
  val empty : 'a queue

  (* Whether a queue is empty. *)
  val is_empty : 'a queue -> bool

  (* [enqueue x q] is the queue [q] with [x] added to the end. *)
  val enqueue : 'a -> 'a queue -> 'a queue

  (* [peek q] is [Some x], where [x] is the element at the front of the queue,
     or [None] if the queue is empty. *)
  val peek : 'a queue -> 'a option

  (* [dequeue q] is [Some q'], where [q'] is the queue containing all the elements
     of [q] except the front of [q], or [None] if [q] is empty. *)
  val dequeue : 'a queue -> 'a queue option
end

module TwoListQueue : MyQueue = struct

  type 'a queue = {front:'a list; back:'a list}

  let empty = {front=[]; back=[]}

  let is_empty = function
    | {front=[]; back=[]} -> true
    | _ -> false

  (* Helper function to ensure that a queue is in normal form. *)
  let norm = function
    | {front=[]; back} -> {front=List.rev back; back=[]}
    | q -> q

  let enqueue x q = norm {q with back=x::q.back} 

  let peek = function 
    | {front=[]; _} -> None
    | {front=x::_; _} -> Some x

  let dequeue = function
    | {front=[]; _} -> None
    | {front=_::xs; back} -> Some (norm {front=xs; back})
end