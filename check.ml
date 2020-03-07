open React
open Lwt
open LTerm_text
open Automata_module
open Automata
open Two_list_queue

module A = Automata_module.Make

module TLQ = TwoListQueue

let add a array = Array.append [|a|] array

class union_find x y = object(self)

  val forest = [||]

  method find (v : string) = 
    let r_ref = ref "" in
    for i=0 to Array.length forest do
      let (v_i, pointer) = forest.(i) in
      if v = v_i then r_ref := pointer else ()
    done

  method union = true

  method construct (acc : (string * string) array) x y = 
    match x, y with
    | [], [] -> acc
    | hx :: tx, [] -> 
      let State sx = hx in
      self#construct (add (sx, sx) acc) tx []
    | [], hy::ty -> 
      let State sy = hy in
      self#construct (add (sy, sy) acc) [] ty
    | hx :: tx, hy::ty -> 
      let State sx, State sy = hx, hy in
      self#construct (add (sy, sy) (add (sx, sx) acc)) tx ty

  initializer ignore (self#construct forest x y);
end

let check aX aY : (automata -> automata -> bool) = 

  let (x, theta_x, lx), (y, theta_y, ly) = aX, aY in
  let todo = TLQ.enqueue (lx, ly) TLQ.empty in


  failwith ""