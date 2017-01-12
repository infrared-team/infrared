(* Core Infrared shell for filtering and dispatching commands *)

open CommandSpec

module InfraredShell : sig
  val commands : CommandSpec.t list
  val main : unit -> unit
  val greeting : unit -> unit
  val failure : string -> unit
end = struct
  let commands = [
    HelpCommand.spec;
    ParseCommand.spec;
    VersionCommand.spec;
(*    
    TypeCheckCommand.spec;
*)  
  ]

  let failure msg = 
    Printf.printf "😬  Well this is awkward, %s\n" msg

  let greeting () = 
    Printf.printf "%s%s\n\n" "✨  🚀  Infrared — " InfraredConfig.version

  let main () = 
    let argv = Array.to_list Sys.argv in
    match argv with
    | [] -> failure "no args found whatsoever, shouldn't ever see this"
    | prgm :: [] -> HelpCommand.exec commands
    | prgm :: cmd :: args -> 
        try 
          let command = List.find (fun command -> 
            command.name = cmd) commands in
          (* Cannot have arbitrary function as a type param, therefore we need
           * to try and match commands like this because we cannot store custom
           * exec functions to the commands themselves, but rather to their
           * modules. I'm sure there's a "right" way to do this so keep thinking. *)
          match command.name with
          | cmd when HelpCommand.spec.name = cmd -> HelpCommand.exec commands
          | cmd when VersionCommand.spec.name = cmd -> VersionCommand.exec ()
          | cmd when ParseCommand.spec.name = cmd -> (
            match args with
            | [] -> failure "no arguments given for parsing."
            | arg :: [] -> Printf.printf "requested to parse single file:\n%s\n" arg
            | _ -> 
                Printf.printf "requested to parse the following files:\n";
                Core.Std.List.iter ~f:(fun file -> Printf.printf "%s\n" file) args)
          | _ -> raise Not_found
        with Not_found ->
          failure "you've entered an invalid command.\n";
          HelpCommand.exec commands
end

let _ = 
  (* InfraredShell.greeting (); *)
  InfraredShell.main ()

