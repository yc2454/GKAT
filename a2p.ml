open React
open Lwt
open LTerm_text

exception Quit

module Interpreter = struct
  type repl_state = {
    command_count : int;
    env : Eval.env;
    st : Eval.state;
  }

  let initial_rstate = {
    command_count = 1;
    env = Eval.initial_env;
    st = Eval.initial_state;
  }

  let quit_regex  = Str.regexp {|^#quit\(;;\)?$|}
  let env_regex   = Str.regexp {|^#env\(;;\)?$|}
  let state_regex = Str.regexp {|^#state\(;;\)?$|}

  let matches s r =
    Str.string_match r s 0

  let eval state s =
    if matches s quit_regex then
      raise Quit
    else if matches s env_regex then
      (state, Eval.string_of_env state.env)
    else if matches s state_regex then
      (state, Eval.string_of_state state.st)
    else
      let (out, env', st') = Main.interp_phrase (s, state.env, state.st) in
      let state' = {
        command_count = state.command_count + 1;
        env = env';
        st = st';
      } in
      (state', out)
end

let make_prompt state =
  let prompt = "# " in
  eval [ S prompt ]

let make_output state out =
  let output =
    if out = "" then "\n"
    else Printf.sprintf "%s\n\n" out in
  eval [ S output ]

class read_line ~term ~history ~state = object(self)
  inherit LTerm_read_line.read_line ~history ()
  inherit [Zed_string.t] LTerm_read_line.term term

  method show_box = false

  initializer
    self#set_prompt (S.const (make_prompt state))
end

let rec loop term history state =
  Lwt.catch (fun () ->
      let rl = new read_line ~term ~history:(LTerm_history.contents history) ~state in
      rl#run >|= fun command -> Some command)
    (function
      | Sys.Break -> return None
      | exn -> Lwt.fail exn)
  >>= function
  | Some command ->
    let command_utf8 = Zed_string.to_utf8 command in
    let state, out = Interpreter.eval state command_utf8 in
    LTerm.fprints term (make_output state out)
    >>= fun () ->
    LTerm_history.add history command;
    loop term history state
  | None ->
    loop term history state

let main () =
  LTerm_inputrc.load ()
  >>= fun () ->
  Lwt.catch (fun () ->
      let state = Interpreter.initial_rstate in
      Lazy.force LTerm.stdout
      >>= fun term ->
      loop term (LTerm_history.create []) state)
    (function
      | LTerm_read_line.Interrupt | Quit -> Lwt.return ()
      | exn -> Lwt.fail exn)

let () = 
  print_endline "JoCalf\n";
  Lwt_main.run (main ())
