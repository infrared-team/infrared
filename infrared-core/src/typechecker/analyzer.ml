open Encoder

let check file =
  Printf.printf "checking.. %s" file;
  let parsetree = NativeEncoder.parse file in
  (* let open NativeEncoder in *)
  let open NativeEncoder.Util in
  let ast = parsetree |> member "tree" in
  let directives = ast |> member "directives" |> to_list in
  let t = List.hd directives |> member "type" |> to_string in
  print_endline ("\n--> " ^ t)
