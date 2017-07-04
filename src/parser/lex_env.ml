
open Loc
open Token

type t = {
  (* Meta *)
  source: string;
  (* States *)
  state: state_t list;
  expr: Token.t list;
  expr_buffers: Token.t list Utils.Stack.t;
  (* The token_list is "backwards" -- newest token is 
    * inserted into the front of the list. 
    * TODO: Consider using a queue? *)
  token_list: Token.t list;
  error: (string * Level.t) option;
}

and state_t = 
  | S_Default
  | S_Array
  | S_Block
  | S_Expression
  | S_Panic

let state_to_string = function
  | S_Default -> "S_Default"
  | S_Array -> "S_Array"
  | S_Block -> "S_Block"
  | S_Expression -> "S_Expression"
  | S_Panic -> "S_Panic"

let new_env = { 
  source = "undefined";
  state = [ S_Default ]; (* I should use a stack for this too *)
  expr = [];
  expr_buffers = Utils.Stack.Nil; (* Empty stack type; TODO: Utils.Stack.create should have optional param *)
  token_list = [];
  error = None;
}

let update_state state env = 
  { env with state = state :: env.state }

let set_error msg env = 
  let err = (msg, Level.SyntaxError) in
  { env with error = Some err }

(* A known issue is that the position of certain tokens is currently
  * incorrect sometimes, due to _when_ we dress these tokens.
  * Tokens that are definitely have wrong positions:
  *  - Syntax_Error <- we don't know that we have a syntax error until we're well past it in some cases
  *  - Closures <- we don't track when they start, but we dress when they end 
  *  - Comments <- I bet this happens with strings too. We need to start storing the beinginng lexbuf loc *)
let dress body lxb = 
  let open Lexing in
  let pos = lxb.lex_start_p in
  let loc = { Loc.
    line = pos.pos_lnum;
    column = pos.pos_cnum - pos.pos_bol + 1;
  } in { loc; body }

let push ~tok env ~lxb =
  let tok = dress tok lxb in
  match List.hd env.state with
  | S_Default -> { env with token_list = tok :: env.token_list }
  | _ -> { env with expr = tok :: env.expr }

(* Add current expression to the expression buffer
  * and clear current expression. *)
let buf_push lxb env =
  let expr = env.expr in
  let stack = env.expr_buffers in
  match expr with
  | [] -> env
  | _ -> { env with
           expr_buffers = Utils.Stack.push stack expr;
           expr = [] }

(* Pop from expression buffer and combine it with current expression.
  * If the current expression is empty, we combine *)
let buf_pop lxb env =
  let state = List.tl env.state in
  let naked_closure_token = 
    match List.hd env.state with
    | S_Array -> Array env.expr 
    | S_Block -> Block env.expr 
    | S_Expression -> Expression env.expr 
    | _ -> Syntax_Error "A closure was terminated before it was started"
  in let dressed_closure_token = dress naked_closure_token lxb in
  match List.hd state with 
  (* There are no more closures left to resolve *)
  | S_Default -> { env with
    state = List.tl env.state;
    token_list = dressed_closure_token :: env.token_list;
    expr = [] }
  | _ ->
    (* We still have closures left to resolve
      * Take the most recent expression buffer *)
    let top_expr = Utils.Stack.peek env.expr_buffers in
    let stack = Utils.Stack.pop env.expr_buffers in
    (* If there was an expression buffer [if empty closure there won't be]
      * then add our closure token to the front an put that back in the working buffer
      * If not, then we just return the closure token as a list *)
    let combined_expr = 
      match top_expr with
      | Some expr -> dressed_closure_token :: expr
      | None -> [dressed_closure_token]
    in { env with 
      state;
      expr_buffers = stack;
      expr = combined_expr }

let resolve_errors tok env =
  match tok with
  | Syntax_Error msg -> set_error msg env
  | _ -> env

let debug env = 
  Printf.sprintf "\n{\n\
    \tsource = \"\x1b[35m%s\x1b[39m\";\n\
    \tstate = \x1b[35m%s\x1b[39m;\n\
    \texpr = [\x1b[35m%s\x1b[39m\n\t];\n\
    \texpr_buffers = Utils.Stack.create [ %d ];\n\
    \ttoken_list = [\x1b[35m%s\x1b[39m\n\t];\n\
    \terror = None;\n\
  }\n" 
  env.source 
  (List.fold_left 
    (fun acc state -> acc ^ "\n" ^ (state_to_string state)) "" env.state)
  (List.fold_left 
    (fun acc tok -> acc ^ "\n" ^ (full_token_to_string tok)) "" env.expr)
  (Utils.Stack.size env.expr_buffers)
  (List.fold_left 
    (fun acc tok -> acc ^ "\n" ^ (full_token_to_string tok)) "" env.token_list)
  |> print_endline

