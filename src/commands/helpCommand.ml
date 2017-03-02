
open Core.Std
open CommandSpec

let print_usage commands =
  let open Printf in
  printf "🐢  Usage: infrared [COMMAND]\n\n🐳  Valid values for COMMAND:\n";
  List.iter ~f:(fun cmd -> 
    printf "     %s\t%s\n" cmd.name cmd.doc) commands

let spec = CommandSpec.create
  ~name:"help"
  ~doc:"Prints the usage and other information regarding Infrared."
  ~flags:[]

let exec = print_usage

