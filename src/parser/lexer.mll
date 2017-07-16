(* @TODO
 * List of jobs or tasks that need to be done or are worth noting.
 *  - Need support for `Tagged template literals`
 *    https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals
 *  - Need support for recognizing regex
 *)
{
open Loc
open Token
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

let templatechars = alphanumeric | whitespace | symbols | ['('')' '['']']

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
  | "instanceof"      {
                        let env = push (Operator Instanceof) env lexbuf in
                        token env lexbuf;
                      }
  | "in"              {
                        let env = push (Operator In) env lexbuf in
                        token env lexbuf;
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
  | "=>"              {
                        let env = push ArrowFunction env lexbuf in
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
                      if q = q' then
                        String (Buffer.contents buf)
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
  | '$' '{' (templatechars* as raw_expr) '}'
                    {
                      if (String.length raw_expr) = 0 then begin
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
                        let expr = List.rev cooked_expr_env.token_list in
                        let exprs' = expr :: exprs in
                        read_template_strings env buf exprs' lexbuf
                      end
                    }
  | '\n'            {
                      let _ = Lexing.new_line lexbuf in
                      read_template_strings env buf exprs lexbuf
                    }
  | '`'             {
                      let str = Buffer.contents buf in
                      TemplateString (str, exprs)
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

