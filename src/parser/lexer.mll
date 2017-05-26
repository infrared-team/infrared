(* @TODO
 * List of jobs or tasks that need to be done or are worth noting.
 *  - Need support for `Tagged template literals`
 *    https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals
 *  - Need support for recognizing regex
 *)
{
module rec Loc : sig
  type t = {
    line: int;
    column: int;
  }
end = Loc

module Token = struct
  type t = {
    loc: Loc.t;
    body: t';
  }

  (* These keywords are organized alphabetically rather than by relevant
   * association, and separated by their specifications. Keep that in mind when
   * looking for particular keywords to add or change.
   * https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Lexical_grammar *)
  and t' = 
    (* Custom *)
    (* Like Expression but with curly brackets *)
    | Block of t list 
    (* Like Block but with parethesis *)
    | Expression of t list 
    (* Like Block/Expression but with square brackets *)
    | Array of t list
    (* Words like the names of functions or variables, not to be confused with Strings *)
    | Identifier of string
    | Bool
    (* Surrounded by quotes, not to be confused with Identifiers *)
    | String of string
    | Number
    | Variable of var_t
    (* Standard *)
    | Break
    | Case
    | Catch
    | Comment
    | Continue
    | Debugger
    | Default
    | Delete
    | Do
    | Else
    | Export
    | Extends
    | Finally
    | For
    (* Bind function names in env while parsing 
     * Ex:
       * Function Identifier "Foo", Expression ( ... ), Block ( ... ) ....
       * or 
       * Function Expression ( ... ) Block ( ... ) ....
     * *)
    | Function
    | If
    | In
    | Instanceof
    | New
    | Null
    | Return
    | Super
    | Switch
    | This
    | Throw
    | Try
    | Typeof
    | Void
    | While
    | With
    | Yield
    (* ES6 *)
    | Class
    | Implements
    | Import
    | Spread
    (* Template string w/ list of TokenTrees *)
    | TemplateString of string * t list list
    (* ES7 *)
    | Async
    | Await
    (* Miscellaneous & FutureReserved *)
    | Enum
    | Interface
    | Package
    | Private
    | Protected
    | Public
    | Static
    | Operator of ops
    (* Error handling *)
    | Syntax_Error of string
    | Unknown_Token of string

  and ops =
    (* Compound Assignment Operators *)
    | CA_Plus                (*    +=    *)
    | CA_Minus               (*    -=    *)
    | CA_Mult                (*    *=    *)
    | CA_Div                 (*    /=    *)
    | CA_Mod                 (*    %=    *)
    | CA_Pow                 (*    **=   *)
    | CA_LeftShift           (*    <<=   *)
    | CA_RightShift          (*    >>=   *)
    | CA_RightShiftUnsigned  (*    >>>=  *)
    | CA_Or                  (*    |=    *)
    | CA_Xor                 (*    ^=    *)
    | CA_And                 (*    &=    *)
    (* Binary Operators *)
    | Equal                  (*    ==    *)
    | NotEqual               (*    !=    *)
    | StrictEqual            (*    ===   *)
    | StrictNotEqual         (*    !==   *)
    | LessThan               (*    <     *)
    | LessThanEqual          (*    <=    *)
    | GreaterThan            (*    >     *)
    | GreaterThanEqual       (*    >=    *)
    | LeftShift              (*    <<    *)
    | RightShift             (*    >>    *)
    | RightShiftUnsigned     (*    >>>   *)
    | Plus                   (*    +     *)
    | Minus                  (*    -     *)
    | Mult                   (*    *     *)
    | Div                    (*    /     *)
    | Mod                    (*    %     *)
    | Pow                    (*    **    *)
    | Comma                  (*    ,     *)
    | LogicalOr              (*    ||    *)
    | LogicalAnd             (*    &&    *)
    | Or                     (*    |     *)
    | Xor                    (*    ^     *)
    | And                    (*    &     *)
    | Bang                   (*    !     *)
    | Not                    (*    ~     *)
    | Increment              (*    ++    *)
    | Decrement              (*    --    *)
    | Dot                    (*    .     *)
    | Colon                  (*    :     *)
    | Ternary                (*    ?     *)
    | Assignment             (*    =     *)

  and var_t = 
    (* Standard *)
    | Var
    (* ES6 *)
    | Let
    | Const

  let rec token_to_string tok i =
    let indentation = String.make i ' ' in
    let step = 4 in
    match tok with
    | Block content -> (
      if List.length content = 0 
        then indentation ^ "Block {}"
        else Printf.sprintf "%sBlock {\n%s%s}"
          indentation
          (List.fold_left 
            (fun acc e -> 
              Printf.sprintf "%s%s\n"
              acc
              (full_token_to_string ~indent:(i + step) e))
          "" content)
          indentation)
    | Expression content -> (
      if List.length content = 0 
        then indentation ^ "Expression ()"
        else Printf.sprintf "%sExpression (\n%s%s)"
          indentation
          (List.fold_left 
            (fun acc e -> 
              Printf.sprintf "%s%s\n"
              acc
              (full_token_to_string ~indent:(i + step) e))
          "" content)
          indentation)
    | Array content -> (
      if List.length content = 0 
        then indentation ^ "Array []"
        else Printf.sprintf "%sArray [\n%s%s]"
          indentation
          (List.fold_left 
            (fun acc e -> 
              Printf.sprintf "%s%s\n"
              acc
              (full_token_to_string ~indent:(i + step) e))
          "" content)
          indentation)
    | Variable t -> indentation ^ "Variable: " ^ (var_to_string t)
    | Number -> indentation ^ "Number"
    | Bool -> indentation ^ "Bool"
    | String str -> indentation ^ "String: " ^ str
    | Comment -> indentation ^ "Comment"
    | Break -> indentation ^ "Break"
    | Case -> indentation ^ "Case"
    | Catch -> indentation ^ "Catch"
    | Continue -> indentation ^ "Continue"
    | Debugger -> indentation ^ "Debugger"
    | Default -> indentation ^ "Default"
    | Delete -> indentation ^ "Delete"
    | Do -> indentation ^ "Do"
    | Else -> indentation ^ "Else"
    | Export -> indentation ^ "Exports"
    | Extends -> indentation ^ "Extends"
    | Finally -> indentation ^ "Finally"
    | For -> indentation ^ "For"
    | Function -> indentation ^ "Function"
    | If -> indentation ^ "If"
    | Import -> indentation ^ "Import"
    | In -> indentation ^ "In"
    | Instanceof -> indentation ^ "Instanceof"
    | New -> indentation ^ "New"
    | Return -> indentation ^ "Return"
    | Super -> indentation ^ "Super"
    | Switch -> indentation ^ "Switch"
    | This -> indentation ^ "This"
    | Throw -> indentation ^ "Throw"
    | Try -> indentation ^ "Try"
    | Typeof -> indentation ^ "Typeof"
    | Void -> indentation ^ "Void"
    | While -> indentation ^ "While"
    | With -> indentation ^ "With"
    | Yield -> indentation ^ "Yields"
    | Class -> indentation ^ "Class"
    | Implements -> indentation ^ "Implements"
    | Spread -> indentation ^ "Spread"
    | TemplateString (str,tok_lists) -> (
        Printf.sprintf "TemplateString `%s`\n -{\n%s -}"
        str
        (List.fold_left 
          (fun acc toks -> Printf.sprintf "%s - [ %s ]\n" 
            acc
            (List.fold_left 
              (fun acc e -> acc ^ (lazy_token_to_string e)  ^ ", ")
              "" toks))
        "" tok_lists))
    | Async -> indentation ^ "Async"
    | Await -> indentation ^ "Await"
    | Enum -> indentation ^ "Enum"
    | Interface -> indentation ^ "Interface"
    | Package -> indentation ^ "Package"
    | Private -> indentation ^ "Private"
    | Protected -> indentation ^ "Protected"
    | Public -> indentation ^ "Public"
    | Static -> indentation ^ "Static"
    | Null -> indentation ^ "Null"
    | Identifier str -> indentation ^ "Identifier: " ^ str
    | Operator op -> indentation ^ "Operator: " ^ (op_to_string op)
    (* Error Handling *)
    | Unknown_Token str -> Printf.sprintf "%s\x1b[31mUnknown_Token: %s \x1b[39m" indentation str
    | Syntax_Error str -> Printf.sprintf "%s\x1b[31mSyntax_Error: %s \x1b[39m" indentation str

  and op_to_string = function
    (* Operators *)
    | CA_Plus -> "CA_Plus"
    | CA_Minus -> "CA_Minus"
    | CA_Mult -> "CA_Mult"
    | CA_Div -> "CA_Div"
    | CA_Mod -> "CA_Mod"
    | CA_Pow -> "CA_Pow"
    | CA_LeftShift -> "CA_LeftShift"
    | CA_RightShift -> "CA_RightShift"
    | CA_RightShiftUnsigned -> "CA_RightShiftUnsigned"
    | CA_Or -> "CA_Or"
    | CA_Xor -> "CA_Xor"
    | CA_And -> "CA_And"
    | Equal -> "Equal"
    | NotEqual -> "NotEqual"
    | StrictEqual -> "StrictEqual"
    | StrictNotEqual -> "StrictNotEqual"
    | LessThan -> "LessThan"
    | LessThanEqual -> "LessThanEqual"
    | GreaterThan -> "GreaterThan"
    | GreaterThanEqual -> "GreaterThanEqual"
    | LeftShift -> "LeftShift"
    | RightShift -> "RightShift"
    | RightShiftUnsigned -> "RightShiftUnsigned"
    | Plus -> "Plus"
    | Minus -> "Minus"
    | Mult -> "Mult"
    | Div -> "Div"
    | Mod -> "Mod"
    | Pow -> "Pow"
    | Comma -> "Comma"
    | LogicalOr -> "LogicalOr"
    | LogicalAnd -> "LogicalAnd"
    | Or -> "Or"
    | Xor -> "Xor"
    | And -> "And"
    | Bang -> "Bang"
    | Not -> "Not"
    | Increment -> "Increment"
    | Decrement -> "Decrement"
    | Dot -> "Dot"
    | Colon -> "Colon"
    | Ternary -> "Ternary"
    | Assignment -> "Assignment"

  and var_to_string = function
    | Var -> "Var"
    | Let -> "Let"
    | Const -> "Const"

  and full_token_to_string ?(indent=0) tok =
    let open Loc in
    Printf.sprintf "%s \x1b[90m(%d:%d)\x1b[39m"
      (token_to_string tok.body indent)
      tok.loc.line
      tok.loc.column

  and lazy_token_to_string tok =
    let open Loc in
    token_to_string tok.body 0

  (* @NOTE @TODO
   * If we want to identify these complex operators, we can't use this
   * hashtable trick. We need to explicitly check each complex operator
   * manually in `token` *)
  let operators = Hashtbl.create 53
  let _ = List.iter (fun (sym, tok) -> Hashtbl.add operators sym tok) 
    [
      '+', Plus;
      '-', Minus;
      '*', Mult;
      '/', Div;
      '%', Mod;
      '<', LessThan;
      '>', GreaterThan;
      ',', Comma;
      '|', Or;
      '^', Xor;
      '&', And;
      '!', Bang;
      '~', Not;
      '.', Dot;
      ':', Colon;
      '?', Ternary;
      '=', Assignment;
    ]

  (* List of faux keywords that need to be checked separately:
   *  - Spread (Rest)
   *  - TemplateString
   *)
  let keywords = Hashtbl.create 53
  let _ = List.iter (fun (kwd, tok) -> Hashtbl.add keywords kwd tok) 
    [ "break", Break;
      "case", Case;
      "catch", Catch;
      "continue", Continue;
      "debugger", Debugger;
      "default", Default;
      "delete", Delete;
      "do", Do;
      "else", Else;
      "export", Export;
      "extends", Extends;
      "finally", Finally;
      "for", For;
      "function", Function;
      "if", If;
      "in", In;
      "instanceof", Instanceof;
      "new", New;
      "null", Null;
      "return", Return;
      "super", Super;
      "switch", Switch;
      "this", This;
      "throw", Throw;
      "try", Try;
      "typeof", Typeof;
      "void", Void;
      "while", While;
      "with", With;
      (* "yield", Yield; *)
      "class", Class;
      (* "implements", Implements; *)
      "import", Import;
      (* "async", Async; *)
      (* "await", Await; *)
      "enum", Enum;
      (* "interface", Interface; *)
      (* "package", Package; *)
      (* "private", Private; *)
      (* "protected", Protected; *)
      (* "public", Public; *)
      (* "static", Static; *)
      "var", (Variable Var);
      "let", (Variable Let);
      "const", (Variable Const);  ]

end
open Token

module Lex_env = struct
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


end 
open Lex_env
}

(* Different ways you can write a number 
   https://github.com/facebook/flow/blob/master/src/parser/lexer_flow.mll#L755 *)
let hex = ['0'-'9' 'a'-'f' 'A'-'F']
let binnumber = '0' ['B' 'b'] ['0' '1']+
let hexnumber = '0' ['X' 'x'] hex+
let octnumber = '0' ['O' 'o'] ['0'-'7']+
let legacyoctnumber = '0' ['0'-'7']+
let scinumber = ['0'-'9']*'.'?['0'-'9']+['e''E']['-''+']?['0'-'9']+
let digit = ['0'-'9']
let wholenumber = digit+'.'?
let floatnumber = ['0'-'9']*'.'['0'-'9']+

let number = binnumber | hexnumber | octnumber | legacyoctnumber | scinumber | wholenumber | floatnumber

let whitespace = [' ' '\t' '\r']
let letter = ['a'-'z' 'A'-'Z' '_''$']
let alphanumeric = digit | letter

let word = letter alphanumeric*

(* If I forget a symbol, add that here boi 
 * These are a list of the symbols which operators are composed of. *)
let symbols = ['+' '=' '-' '*' '/' '%' '<' '>' '|' '^' '&' ',' '~' '.' ',' '!' ':' '?']

let templatechars = alphanumeric | whitespace | symbols | ['('')' '['']' '{''}']

rule token env = parse
  | whitespace+ | ';' { token env lexbuf }
  | '\n'              { 
                        let _ = Lexing.new_line lexbuf in
                        token env lexbuf
                      }
  | '\\'              {
                        let tok = Syntax_Error "Illegal backslash found" in
                        let env = env
                          |> resolve_errors tok
                          |> push ~tok:(tok) ~lxb:(lexbuf) in
                        token env lexbuf
                      }
  | "//"              {
                        let tok = swallow_single_comment lexbuf in
                        let env = env
                          |> resolve_errors tok
                          |> push ~tok:(tok) ~lxb:(lexbuf) in
                        token env lexbuf
                      }
  | "/*"              {
                        let tok = swallow_multi_comment lexbuf in
                        let env = env
                          |> resolve_errors tok
                          |> push ~tok:(tok) ~lxb:(lexbuf) in
                        token env lexbuf
                      }
  | "#!"              {
                        (* This need to be at the start of the file to be valid *)
                        let tok = if lexbuf.Lexing.lex_start_pos = 0
                          then swallow_single_comment lexbuf (* Handling as comment for now *)
                          else Syntax_Error "Illegal hashbang found"
                        in let env = env
                            |> resolve_errors tok
                            |> push ~tok:(tok) ~lxb:(lexbuf) in
                          token env lexbuf
                      }
  | "true" | "false"  {
                        let env = push Bool env lexbuf in
                        token env lexbuf
                      }
  | '`'               {
                        let tok = read_template_strings env (Buffer.create 16) [] lexbuf in
                        let env = env
                          |> resolve_errors tok
                          |> push ~tok:(tok) ~lxb:(lexbuf) in
                        token env lexbuf
                      }
  | "'"|'"' as q      {
                        let tok = read_string q (Buffer.create 16) lexbuf in
                        let env = env
                          |> resolve_errors tok
                          |> push ~tok:(tok) ~lxb:(lexbuf) in
                        token env lexbuf
                      }
  | word as word      {
                        try
                          let env = push (Hashtbl.find keywords word) env lexbuf in
                          token env lexbuf
                        with Not_found -> 
                          let env = push (Identifier word) env lexbuf in
                          token env lexbuf
                      }
  | number            {
                        let env = push Number env lexbuf in
                        token env lexbuf
                      }
  | '('|'{'|'[' as c  {
                        let state = match c with
                          | '[' -> S_Array
                          | '{' -> S_Block
                          | '(' -> S_Expression
                          | _ -> S_Panic
                        in let env = env
                          |> update_state state
                          |> buf_push lexbuf in
                        token env lexbuf
                      }
  | ')'|'}'|']'       {
                        let env = buf_pop lexbuf env in
                        token env lexbuf
                      }
  | "..."             {
                        let env = push Spread env lexbuf in
                        token env lexbuf
                      }
  | "+="              { 
                        let env = push (Operator CA_Plus) env lexbuf in
                        token env lexbuf; 
                      }
  | "-="              { 
                        let env = push (Operator CA_Minus) env lexbuf in
                        token env lexbuf; 
                      }
  | "*="              { 
                        let env = push (Operator CA_Mult) env lexbuf in
                        token env lexbuf; 
                      }
  | "/="              { 
                        let env = push (Operator CA_Div) env lexbuf in
                        token env lexbuf; 
                      }
  | "%="              { 
                        let env = push (Operator CA_Mod) env lexbuf in
                        token env lexbuf; 
                      }
  | "**="             { 
                        let env = push (Operator CA_Pow) env lexbuf in
                        token env lexbuf; 
                      }
  | "<<="             { 
                        let env = push (Operator CA_LeftShift) env lexbuf in
                        token env lexbuf; 
                      }
  | ">>="             { 
                        let env = push (Operator CA_RightShift) env lexbuf in
                        token env lexbuf; 
                      }
  | ">>>="            { 
                        let env = push (Operator CA_RightShiftUnsigned) env lexbuf in
                        token env lexbuf; 
                      }
  | "|="              { 
                        let env = push (Operator CA_Or) env lexbuf in
                        token env lexbuf; 
                      }
  | "^="              { 
                        let env = push (Operator CA_Xor) env lexbuf in
                        token env lexbuf; 
                      }
  | "&="              { 
                        let env = push (Operator CA_And) env lexbuf in
                        token env lexbuf; 
                      }
  | "=="              { 
                        let env = push (Operator Equal) env lexbuf in
                        token env lexbuf; 
                      }
  | "!="              { 
                        let env = push (Operator NotEqual) env lexbuf in
                        token env lexbuf; 
                      }
  | "==="             { 
                        let env = push (Operator StrictEqual) env lexbuf in
                        token env lexbuf; 
                      }
  | "!=="             { 
                        let env = push (Operator StrictNotEqual) env lexbuf in
                        token env lexbuf; 
                      }
  | "<="              { 
                        let env = push (Operator LessThanEqual) env lexbuf in
                        token env lexbuf; 
                      }
  | ">="              { 
                        let env = push (Operator GreaterThanEqual) env lexbuf in
                        token env lexbuf; 
                      }
  | "<<"              { 
                        let env = push (Operator LeftShift) env lexbuf in
                        token env lexbuf; 
                      }
  | ">>"              { 
                        let env = push (Operator RightShift) env lexbuf in
                        token env lexbuf; 
                      }
  | ">>>"             { 
                        let env = push (Operator RightShiftUnsigned) env lexbuf in
                        token env lexbuf; 
                      }
  | "**"              { 
                        let env = push (Operator Pow) env lexbuf in
                        token env lexbuf; 
                      }
  | "||"              { 
                        let env = push (Operator LogicalOr) env lexbuf in
                        token env lexbuf; 
                      }
  | "&&"              { 
                        let env = push (Operator LogicalAnd) env lexbuf in
                        token env lexbuf; 
                      }
  | "++"              { 
                        let env = push (Operator Increment) env lexbuf in
                        token env lexbuf; 
                      }
  | "--"              { 
                        let env = push (Operator Decrement) env lexbuf in
                        token env lexbuf; 
                      }
  | symbols as op     {
                        try
                          let op' = (Hashtbl.find operators op) in
                          let env = push (Operator op') env lexbuf in
                          token env lexbuf
                        with Not_found -> 
                          let op_as_string = String.make 1 op in
                          let env = push (Unknown_Token op_as_string) env lexbuf in
                          token env lexbuf
                      }
  | eof               { env }
  | _ as tok          { 
                        let tok_str = String.make 1 tok in
                        let env = push (Unknown_Token tok_str) env lexbuf in
                        token env lexbuf
                      }
  
and read_string q buf = parse
  | '\\' _
                    {
                      Buffer.add_string buf (Lexing.lexeme lexbuf);
                      read_string q buf lexbuf
                    }
  | "'"|'"' as q'   {
                      if q = q'
                        then String (Buffer.contents buf)
                        else begin
                          Buffer.add_string buf (Lexing.lexeme lexbuf);
                          read_string q buf lexbuf
                        end
                    }
  | '\n' | eof      { Syntax_Error "String is terminated illegally or not at all" }
  | _ as c          { 
                      Buffer.add_char buf c;
                      read_string q buf lexbuf 
                    }

and read_template_strings env buf exprs = parse
  | '\\' _
                    {
                      Buffer.add_string buf (Lexing.lexeme lexbuf);
                      read_template_strings env buf exprs lexbuf
                    }
  | '`'             {
                      let str = Buffer.contents buf in
                      let _d = Printf.sprintf "%s" (string_of_int (List.length exprs)) in
                      print_endline _d;
                      TemplateString (str, exprs)
                    }
  | '$' '{' (templatechars* as raw_expr) '}'
                    {
                      if (String.length raw_expr) = 0 
                        then begin
                          let expr = Syntax_Error "Empty template string argument" in
                          let expr' = dress expr lexbuf in
                          let exprs' = [expr'] :: exprs in
                          read_template_strings env buf exprs' lexbuf
                        end else begin
                          (* Spawn a new instance of our lexer and work on expression *) 
                          let open Batteries in
                          let input = IO.input_string raw_expr in
                          let lexbuf' = Lexing.from_input input in
                          let cooked_expr_env = token new_env lexbuf' in
                          (* Consider checking for errors in cooked_expr_env.error *)
                          let expr = cooked_expr_env.token_list in
                          let exprs' = expr :: exprs in
                          read_template_strings env buf exprs' lexbuf
                        end
                    }
  | '\n'            {
                      let _ = Lexing.new_line lexbuf in
                      read_template_strings env buf exprs lexbuf
                    }
  | eof             { Syntax_Error "TemplateString is terminated illegally or not at all" }
  | _ as c          { 
                      Buffer.add_char buf c;
                      read_template_strings env buf exprs lexbuf
                    }

(* Swallows everything until a newline is encountered. By doing this, we isolate this
 * process and give us the option to save or do whatever we want to comments if we want
 * to in the future. *)
and swallow_single_comment = parse
  | '\n'            { 
                      let _ = Lexing.new_line lexbuf in
                      Comment
                    }
  | eof             { Comment }
  | _               { swallow_single_comment lexbuf }

and swallow_multi_comment = parse
  | "*/"            { Comment }
  | '\n'            {
                      let _ = Lexing.new_line lexbuf in
                      swallow_multi_comment lexbuf
                    }
  | eof             { Syntax_Error "Multiline comment is not terminated" }
  | _               { swallow_multi_comment lexbuf }

