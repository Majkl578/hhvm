(**
 * Copyright (c) 2014, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the "hack" directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 *
 *)


open Utils

type id = Pos.t * Ident.t
type sid = Pos.t * string
type pstring = Pos.t * string

type is_terminal = bool

type call_type =
  | Cnormal    (* when the call looks like f() *)
  | Cuser_func (* when the call looks like call_user_func(...) *)


type shape_field_name =
  | SFlit of pstring
  | SFclass_const of sid * pstring

module ShapeField = struct
  type t = shape_field_name
  (* We include span information in shape_field_name to improve error
   * messages, but we don't want it being used in the comparison, so
   * we have to write our own compare. *)
  let compare x y =
    match x, y with
      | SFlit _, SFclass_const _ -> -1
      | SFclass_const _, SFlit _ -> 1
      | SFlit (_, s1), SFlit (_, s2) -> Pervasives.compare s1 s2
      | SFclass_const ((_, s1), (_, s1')), SFclass_const ((_, s2), (_, s2')) ->
        Pervasives.compare (s1, s1') (s2, s2')

end

module ShapeMap = MyMap(ShapeField)

type hint = Pos.t * hint_
and hint_ =
  | Hany
  | Hmixed
  | Htuple of hint list
  | Habstr of string * hint option
  | Harray of hint option * hint option
  | Hprim of tprim
  | Hoption of hint
  | Hfun of hint list * bool * hint
  | Happly of sid * hint list
  | Hshape of hint ShapeMap.t

and tprim =
  | Tvoid
  | Tint
  | Tbool
  | Tfloat
  | Tstring
  | Tnum
  | Tresource
  | Tarraykey

and class_ = {
  c_mode           : Ast.mode         ;
  c_final          : bool             ;
  c_is_xhp         : bool;
  c_kind           : Ast.class_kind   ;
  c_name           : sid              ;
    (* The type parameters of a class A<T> (T is the parameter) *)
  c_tparams        : tparam list      ;
  c_extends        : hint list        ;
  c_uses           : hint list        ;
  c_req_extends    : hint list        ;
  c_req_implements : hint list        ;
  c_implements     : hint list        ;
  c_consts         : class_const list ;
  c_static_vars    : class_var list   ;
  c_vars           : class_var list   ;
  c_constructor    : method_ option   ;
  c_static_methods : method_ list     ;
  c_methods        : method_ list     ;
  c_user_attributes : Ast.user_attribute SMap.t;
  c_enum           : enum_ option     ;
}

and enum_ = {
  e_base       : hint;
  e_constraint : hint option;
}

and tparam = Ast.variance * sid * hint option

and class_const = hint option * sid * expr
and class_var = {
  cv_final      : bool        ;
  cv_visibility : visibility  ;
  cv_type       : hint option ;
  cv_id         : sid         ;
  cv_expr       : expr option ;
}

and method_ = {
  m_unsafe          : bool                      ;
  m_final           : bool                      ;
  m_abstract        : bool                      ;
  m_visibility      : visibility                ;
  m_name            : sid                       ;
  m_tparams         : tparam list               ;
  m_variadic        : fun_variadicity           ;
  m_params          : fun_param list            ;
  m_body            : block                     ;
  m_user_attributes : Ast.user_attribute SMap.t ;
  m_ret             : hint option               ;
  m_fun_kind        : fun_kind                  ;
}

and fun_kind =
  | FSync
  | FGenerator
  | FAsync
  | FAsyncGenerator

and visibility =
  | Private
  | Public
  | Protected

and og_null_flavor =
  | OG_nullthrows
  | OG_nullsafe

and is_reference = bool
and is_variadic = bool
and fun_param = {
  param_hint : hint option;
  param_is_reference : is_reference;
  param_is_variadic : is_variadic;
  param_id : id;
  param_name : string;
  param_expr : expr option;
}

and fun_variadicity = (* does function take varying number of args? *)
  | FVvariadicArg of fun_param (* PHP5.6 ...$args finishes the func declaration *)
  | FVellipsis    (* HH ... finishes the declaration; deprecate for ...$args? *)
  | FVnonVariadic (* standard non variadic function *)

and fun_ = {
  f_mode     : Ast.mode;
  f_unsafe   : bool;
  f_ret      : hint option;
  f_name     : sid;
  f_tparams  : tparam list;
  f_variadic : fun_variadicity;
  f_params   : fun_param list;
  f_body     : block;
  f_fun_kind : fun_kind;
}

and typedef = tparam list * hint option * hint

and gconst = {
  cst_mode: Ast.mode;
  cst_name: Ast.id;
  cst_type: hint option;
  cst_value: expr option;
}

and stmt =
  | Expr of expr
  | Break of Pos.t
  | Continue of Pos.t
  | Throw of is_terminal * expr
  | Return of Pos.t * expr option
  | Static_var of expr list
  | If of expr * block * block
  | Do of block * expr
  | While of expr * block
  | For of expr * expr * expr * block
  | Switch of expr * case list
  | Foreach of expr * as_expr * block
  | Try of block * catch list * block
  | Noop
  | Fallthrough

and as_expr =
  | As_v of expr
  | As_kv of expr * expr
  | Await_as_v of Pos.t * expr
  | Await_as_kv of Pos.t * expr * expr

and block = stmt list

and class_id =
  | CIparent
  | CIself
  | CIstatic
  | CIvar of expr
  | CI of sid

and expr = Pos.t * expr_
and expr_ =
  | Any
  | Array of afield list
  | Shape of expr ShapeMap.t
  | ValCollection of string * expr list
  | KeyValCollection of string * field list
  | This
  | Id of sid
  | Lvar of id
  | Fun_id of sid
  | Method_id of expr * pstring
  (* meth_caller('Class name', 'method name') *)
  | Method_caller of sid * pstring
  | Smethod_id of sid * pstring
  | Obj_get of expr * expr * og_null_flavor
  | Array_get of expr * expr option
  | Class_get of class_id * pstring
  | Class_const of class_id * pstring
  | Call of call_type * expr * expr list
  | True
  | False
  | Int of pstring
  | Float of pstring
  | Null
  | String of pstring
  | String2 of expr list * string
  | Special_func of special_func
  | Yield_break
  | Yield of afield
  | Await of expr
  | List of expr list
  | Pair of expr * expr
  | Expr_list of expr list
  | Cast of hint * expr
  | Unop of Ast.uop * expr
  | Binop of Ast.bop * expr * expr
  | Eif of expr * expr option * expr
  | InstanceOf of expr * expr
  | New of class_id * expr list
  | Efun of fun_ * id list
  | Xml of sid * (pstring * expr) list * expr list
  | Assert of assert_expr
  | Clone of expr

and assert_expr =
  | AE_assert of expr
  | AE_invariant of expr * expr * expr list
  | AE_invariant_violation of expr * expr list

and case =
| Default of block
| Case of expr * block

and catch = sid * id * block

and field = expr * expr
and afield =
  | AFvalue of expr
  | AFkvalue of expr * expr

and special_func =
  | Gena of expr
  | Genva of expr list
  | Gen_array_rec of expr
  | Gen_array_va_rec of expr list

type def =
 | Fun of fun_
 | Class of class_
 | Typedef of typedef

type program = def list
