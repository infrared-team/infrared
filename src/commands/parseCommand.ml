
open Core.Std
open CommandSpec

let parse_single file = 
  let ast = Parser.parse file in
  match ast with
  | Ok _ -> ast
  | Error msg -> 
      (ErrorHandling.report ~msg:msg ~level:Level.Med);
      ast
 
let generate_ast_list ~args ~flags =
  let files = extract_files args in
  let rec parse_files files asts =
    match files with
    | [] -> asts
    | file :: rest -> (parse_files rest ([(parse_single file)] @ asts))
  in parse_files files []

let spec = CommandSpec.create
  ~name:"parse"
  ~doc:"Parses the targeted files and returns a list of the ASTs produced."
  ~flags:[]

let exec = generate_ast_list;


