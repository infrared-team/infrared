
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
    | Block of t' list 
    (* Like Block but with parethesis *)
    | Expression of t' list 
    (* Words like the names of functions or variables, not to be confused with Strings *)
    | Identifier of string
    | Bool
    (* Surrounded by quotes, not to be confused with Identifiers *)
    | String of string
    | Number
    | Variable of var_t
    | Assignment
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
    | TemplateString
    | Rest
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
    | Unknown_Token of string
    | Syntax_Error of string

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

  and var_t = 
    (* Standard *)
    | Var
    (* ES6 *)
    | Let
    | Const

  let rec token_to_string tok =
    match tok with
    | Block content -> (
      Printf.sprintf "Block (%s)"
        (List.fold_left (fun acc e -> 
          match acc with
          | "" -> acc ^ (token_to_string e)
          | _ -> Printf.sprintf "%s, %s" acc (token_to_string e))
        "" content))
    | Variable t -> 
      Printf.sprintf "Variable <%s>"
        (var_to_string t)
    | Expression expr -> (
      Printf.sprintf "Expression (%s)"
        (List.fold_left (fun acc e -> 
          match acc with
          | "" -> acc ^ (token_to_string e)
          | _ -> Printf.sprintf "%s, %s" acc (token_to_string e))
        "" expr))
    | Number -> "Number"
    | Bool -> "Bool"
    | String str -> Printf.sprintf "String \"%s\"" str
    | Comment -> "Comment"
    | Break -> "Break"
    | Case -> "Case"
    | Catch -> "Catch"
    | Continue -> "Continue"
    | Debugger -> "Debugger"
    | Default -> "Default"
    | Delete -> "Delete"
    | Do -> "Do"
    | Else -> "Else"
    | Export -> "Exports"
    | Extends -> "Extends"
    | Finally -> "Finally"
    | For -> "For"
    | Function -> "Function"
    | If -> "If"
    | Import -> "Import"
    | In -> "In"
    | Instanceof -> "Instanceof"
    | New -> "New"
    | Return -> "Return"
    | Super -> "Super"
    | Switch -> "Switch"
    | This -> "This"
    | Throw -> "Throw"
    | Try -> "Try"
    | Typeof -> "Typeof"
    | Void -> "Void"
    | While -> "While"
    | With -> "With"
    | Yield -> "Yields"
    | Class -> "Class"
    | Implements -> "Implements"
    | Spread -> "Spread"
    | TemplateString -> "TemplateString"
    | Rest -> "Rest"
    | Async -> "Async"
    | Await -> "Await"
    | Enum -> "Enum"
    | Interface -> "Interface"
    | Package -> "Package"
    | Private -> "Private"
    | Protected -> "Protected"
    | Public -> "Public"
    | Static -> "Static"
    | Null -> "Null"
    | Assignment -> "Assignment"
    | Identifier str -> Printf.sprintf "Identifier \"%s\"" str
    | Operator op -> Printf.sprintf "Operator <%s>" (op_to_string op)
    (* Error Handling *)
    | Unknown_Token str -> Printf.sprintf "Unknown_Token: %s" str
    | Syntax_Error str -> Printf.sprintf "Syntax_Error: %s" str

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

    and var_to_string = function
    | Var -> "Var"
    | Let -> "Let"
    | Const -> "Const"

  let operators = Hashtbl.create 53
  let _ = List.iter (fun (sym, tok) -> Hashtbl.add operators sym tok) 
    [
      "+=", CA_Plus;
      "-=", CA_Minus;
      "*=", CA_Mult;
      "/=", CA_Div;
      "%=", CA_Mod;
      "**=", CA_Pow;
      "<<=", CA_LeftShift;
      ">>=", CA_RightShift;
      ">>>=", CA_RightShiftUnsigned;
      "|=", CA_Or;
      "^=", CA_Xor;
      "&=", CA_And;
      "==", Equal;
      "!=", NotEqual;
      "===", StrictEqual;
      "!==", StrictNotEqual;
      "<", LessThan;
      "<=", LessThanEqual;
      ">", GreaterThan;
      ">=", GreaterThanEqual;
      "<<", LeftShift;
      ">>", RightShift;
      ">>>", RightShiftUnsigned;
      "+", Plus;
      "-", Minus;
      "*", Mult;
      "/", Div;
      "%", Mod;
      "**", Pow;
      ",", Comma;
      "||", LogicalOr;
      "&&", LogicalAnd;
      "|", Or;
      "^", Xor;
      "&", And;
      "!", Bang;
      "~", Not;
      "++", Increment;
      "--", Decrement;
      ".", Dot;
    ]

  (* List of faux keywords that need to be checked separately:
   *  - Spread
   *  - TemplateString
   *  - Rest
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

  let full_token_to_string tok =
    let open Loc in
    Printf.sprintf "%d:%d\t%s"
      tok.loc.line
      tok.loc.column
      (token_to_string tok.body)

  let lazy_token_to_string tok =
    let open Loc in
    token_to_string tok.body

end
open Token

module Lex_env = struct
  type t = {
    (* Meta *)
    source: string;
    is_in_comment: bool;
    (* States *)
    state: state_t;
    expr: Token.t list;
    expr_buffers: Token.t list Utils.Stack.t;
    (* The ast is "backwards" -- newest token is 
     * inserted into the front of the list. 
     * TODO: Consider using a queue? *)
    ast: Token.t list;
    error: (string * Level.t) option;
  }

  and state_t = 
    | S_Regular
    | S_Closure

  let state_to_string = function
    | S_Regular -> "S_Regular"
    | S_Closure -> "S_Closure"

  let defaultEnv = { 
    source = "undefined";
    is_in_comment = false;
    state = S_Regular;
    expr = [];
    expr_buffers = Utils.Stack.create [];
    ast = [];
    error = None;
  }

  let set_error msg env = 
    let err = (msg, Level.SyntaxError) in
    { env with error = Some err; }

  let dress body lxb = 
    let open Lexing in
    let pos = lxb.lex_start_p in
    let loc = { 
      Loc.
      line = pos.pos_lnum;
      column = pos.pos_cnum - pos.pos_bol + 1;
    } in
    { loc; body; }

  let push ~tok env ~lxb =
    let tok = dress tok lxb in
    match env.state with
    | _ -> { 
        env with 
        ast = tok :: env.ast;
      }

    let resolve_errors ~tok env =
      match tok with
        | Syntax_Error msg -> set_error msg env
        | _ -> env
end 
open Lex_env
}

(* Different ways you can write a number 
   https://github.com/facebook/flow/blob/master/src/parser/lexer_flow.mll#L755 *)
let hex = ['0'-'9''a'-'f''A'-'F']
let binnumber = '0' ['B''b'] ['0''1']+
let hexnumber = '0' ['X''x'] hex+
let octnumber = '0' ['O''o'] ['0'-'7']+
let legacyoctnumber = '0' ['0'-'7']+
let scinumber = ['0'-'9']*'.'?['0'-'9']+['e''E']['-''+']?['0'-'9']+
let digit = ['0'-'9']
let wholenumber = digit+'.'?
let floatnumber = ['0'-'9']*'.'['0'-'9']+

let number = hex | binnumber | hexnumber | octnumber | legacyoctnumber |
             scinumber | wholenumber | floatnumber

let whitespace = [' ' '\t' '\r']
let letter = ['a'-'z''A'-'Z''_''$']
let alphanumeric = digit | letter

let word = letter alphanumeric*

(* If I forget a symbol, add that here boi *)
let symbols = ['+' '=' '-' '*' '/' '%' '<' '>' '|' '^' '&' ',' '~' '.' ',']

rule token env = parse
  | whitespace+ | ';' { token env lexbuf }
  | '\n'              { 
                        let _ = Lexing.new_line lexbuf in
                        token env lexbuf 
                      }
  | "true"|"false"    {
                        let env = push Bool env lexbuf in
                        token env lexbuf
                      }
  | '"'               {
                        let tok = read_string_dquote (Buffer.create 16) lexbuf in
                        let env = env
                          |> resolve_errors ~tok:(tok)
                          |> push ~tok:(tok) ~lxb:(lexbuf) in
                        token env lexbuf
                      }
  | '\''              {
                        let tok = read_string_squote (Buffer.create 16) lexbuf in
                        let env = env
                          |> resolve_errors ~tok:(tok)
                          |> push ~tok:(tok) ~lxb:(lexbuf) in
                        token env lexbuf
                      }
  | symbols+ as op    {
                        try
                          let op = (Hashtbl.find operators op) in
                          let env = push (Operator op) env lexbuf in
                          token env lexbuf
                        with Not_found -> 
                          let env = push (Unknown_Token op) env lexbuf in
                          token env lexbuf
                      }
  | number            {
                        let env = push Number env lexbuf in
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
  | '('
  | eof               { env }
  | _ as tok          { 
                        let tok_str = String.make 1 tok in
                        let env = push (Unknown_Token tok_str) env lexbuf in
                        token env lexbuf
                      }
  
(* Creating string buffers
 * https://github.com/realworldocaml/examples/blob/master/code/parsing/lexer.mll *)
and read_string_dquote buf = parse
  | '"'             { String (Buffer.contents buf) }
  | '\\' '/'        { Buffer.add_char buf '/'; read_string_dquote buf lexbuf }
  | '\\' '"'        { Buffer.add_char buf '\"'; read_string_dquote buf lexbuf }
  | '\\'            { Buffer.add_char buf '\\'; read_string_dquote buf lexbuf }
  | [^ '"' '\\']+   { Buffer.add_string buf (Lexing.lexeme lexbuf);
                      read_string_dquote buf lexbuf }
  | _               { Syntax_Error ("Illegal string character: " ^ (Lexing.lexeme lexbuf)) }
  | eof             { Syntax_Error "String is not terminated" }

and read_string_squote buf = parse
  | '\''            { String (Buffer.contents buf) }
  | '\\' '/'        { Buffer.add_char buf '/'; read_string_squote buf lexbuf }
  | '\\' '\''       { Buffer.add_char buf '\''; read_string_squote buf lexbuf }
  | '\\'            { Buffer.add_char buf '\\'; read_string_squote buf lexbuf }
  | [^ '\'' '\\']+  { Buffer.add_string buf (Lexing.lexeme lexbuf);
                      read_string_squote buf lexbuf }
  | _               { Syntax_Error ("Illegal string character: " ^ (Lexing.lexeme lexbuf)) }
  | eof             { Syntax_Error "String is not terminated" }
