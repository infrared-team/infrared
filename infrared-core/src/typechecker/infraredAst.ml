
(* Type constraints. *)
type t =
  | T_STRING
  | T_NUMBER
  | T_BOOL
  | T_OBJECTABLE
  | T_NULLABLE
  | T_CALLABLE

type primitive =
  | P_string
  | P_number
  | P_boolean
  | P_null
  | P_undefined
  | P_object

type predicate =
  | Typeof of expression * string

and expression =
  | Primitive of primitive
  | Variable of identifier
  | Predicate of expression
  | Not of expression
  | Function of identifier list * expression list
  | Or of expression * expression
  | And of expression * expression
  | Call of expression * expression

and statement =
  | Skip
  | Declaration of identifier * expression
  | Expression of expression
  | If of expression * expression * expression
  | While of expression * expression * expression
  | For of expression * expression * expression

and identifier =
  | Identifer of string
  | Member of identifier * identifier
  (* this is weird *)
  | Assignment of identifier * expression

type program = {
  (* Includes all import mappings from identifiers to location.
   * Supports imports for CommonJS and ES6. *)
  imports: identifier * string;

  (* Includes all import mappings from identifiers to location.
   * Supports imports for CommonJS and ES6. *)
  exports: identifier;

  (* Collection of all parsed statements. *)
  statements: statement list
}
