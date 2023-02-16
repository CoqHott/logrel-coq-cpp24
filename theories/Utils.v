From Coq Require Import Morphisms List CRelationClasses.
From Coq Require Import ssrbool.
From smpl Require Import Smpl.
From LogRel.AutoSubst Require Import core unscoped Ast.

Set Universe Polymorphism.
Set Polymorphic Inductive Cumulativity.
Set Primitive Projections.

Notation "#| l |" := (List.length l) (at level 0, l at level 99, format "#| l |").
Notation "`=1`" := (pointwise_relation _ Logic.eq) (at level 80).
Infix "=1" := (pointwise_relation _ Logic.eq) (at level 70).
Notation "`=2`" := (pointwise_relation _ (pointwise_relation _ Logic.eq)) (at level 80).
Infix "=2" := (pointwise_relation _ (pointwise_relation _ Logic.eq)) (at level 70).
Infix "<~>" := iffT (at level 90).

(* Since we work a lot with type-level propositions,
we override the notation for negation from the
standard library *)
Export Set Warnings "-notation-overridden".
Notation "~ x" := (notT x) : type_scope.
Export Set Warnings "notation-overriden".

Ltac tea := try eassumption.
Ltac easy ::= solve [intuition eauto 3 with core crelations].



Inductive prod (A B : Type) : Type := | pair : A -> B -> prod A B.
Arguments pair {_ _} _ _.

Definition fst {A B} : prod A B -> A := fun '(pair a b) => a.
Definition snd {A B} : prod A B -> B := fun '(pair a b) => b.

Notation "x × y" := (prod x y) (at level 80, right associativity).
Reserved Notation "[ × P1 & P2 ]" (at level 0).
Reserved Notation "[ × P1 , P2 & P3 ]" (at level 0, format
  "'[hv' [ × '['  P1 , '/'  P2 ']' '/ '  &  P3 ] ']'").
Reserved Notation "[ × P1 , P2 , P3 & P4 ]" (at level 0, format
  "'[hv' [ × '['  P1 , '/'  P2 , '/'  P3 ']' '/ '  &  P4 ] ']'").
Reserved Notation "[ × P1 , P2 , P3 , P4 & P5 ]" (at level 0, format
  "'[hv' [ × '['  P1 , '/'  P2 , '/'  P3 , '/'  P4 ']' '/ '  &  P5 ] ']'").
Reserved Notation "[ × P1 , P2 , P3 , P4 , P5 & P6 ]" (at level 0, format
  "'[hv' [ × '['  P1 , '/'  P2 , '/'  P3 , '/'  P4 , '/'  P5 ']' '/ '  &  P6 ] ']'").
Reserved Notation "[ × P1 , P2 , P3 , P4 , P5 , P6 & P7 ]" (at level 0, format
"'[hv' [ × '['  P1 , '/'  P2 , '/'  P3 , '/'  P4 , '/'  P5 , '/'  P6  ']' '/ '  &  P7 ] ']'").
Reserved Notation "[ × P1 , P2 , P3 , P4 , P5 , P6 , P7 & P8 ]" (at level 0, format
"'[hv' [ × '['  P1 , '/'  P2 , '/'  P3 , '/'  P4 , '/'  P5 , '/'  P6 , '/'  P7 ']' '/ '  &  P8 ] ']'").
Reserved Notation "[ × P1 , P2 , P3 , P4 , P5 , P6 , P7 , P8 & P9 ]" (at level 0, format
"'[hv' [ × '['  P1 , '/'  P2 , '/'  P3 , '/'  P4 , '/'  P5 , '/'  P6 , '/'  P7 , '/'  P8 ']' '/ '  &  P9 ] ']'").
Reserved Notation "[ × P1 , P2 , P3 , P4 , P5 , P6 , P7 , P8 , P9 & P10 ]" (at level 0, format
"'[hv' [ × '['  P1 , '/'  P2 , '/'  P3 , '/'  P4 , '/'  P5 , '/'  P6 , '/'  P7 , '/'  P8 , '/'  P9 ']' '/ '  &  P10 ] ']'").

Variant and3 (P1 P2 P3 : Type) : Type := Times3 of P1 & P2 & P3.
Variant and4 (P1 P2 P3 P4 : Type) : Type := Times4 of P1 & P2 & P3 & P4.
Variant and5 (P1 P2 P3 P4 P5 : Type) : Type := Times5 of P1 & P2 & P3 & P4 & P5.
Variant and6 (P1 P2 P3 P4 P5 P6 : Type) : Type := Times6 of P1 & P2 & P3 & P4 & P5 & P6.
Variant and7 (P1 P2 P3 P4 P5 P6 P7 : Type) : Type := Times7 of P1 & P2 & P3 & P4 & P5 & P6 & P7.
Variant and8 (P1 P2 P3 P4 P5 P6 P7 P8 : Type) : Type := Times8 of P1 & P2 & P3 & P4 & P5 & P6 & P7 & P8.
Variant and9 (P1 P2 P3 P4 P5 P6 P7 P8 P9 : Type) : Type := Times9 of P1 & P2 & P3 & P4 & P5 & P6 & P7 & P8 & P9.
Variant and10 (P1 P2 P3 P4 P5 P6 P7 P8 P9 P10 : Type) : Type := Times10 of P1 & P2 & P3 & P4 & P5 & P6 & P7 & P8 & P9 & P10.

Notation "[ × P1 & P2 ]" := (pair P1 P2) (only parsing) : type_scope.
Notation "[ × P1 , P2 & P3 ]" := (and3 P1 P2 P3) : type_scope.
Notation "[ × P1 , P2 , P3 & P4 ]" := (and4 P1 P2 P3 P4) : type_scope.
Notation "[ × P1 , P2 , P3 , P4 & P5 ]" := (and5 P1 P2 P3 P4 P5) : type_scope.
Notation "[ × P1 , P2 , P3 , P4 , P5 & P6 ]" := (and6 P1 P2 P3 P4 P5 P6) : type_scope.
Notation "[ × P1 , P2 , P3 , P4 , P5 , P6 & P7 ]" := (and7 P1 P2 P3 P4 P5 P6 P7) : type_scope.
Notation "[ × P1 , P2 , P3 , P4 , P5 , P6 , P7 & P8 ]" := (and8 P1 P2 P3 P4 P5 P6 P7 P8) : type_scope.
Notation "[ × P1 , P2 , P3 , P4 , P5 , P6 , P7 , P8 & P9 ]" := (and9 P1 P2 P3 P4 P5 P6 P7 P8 P9) : type_scope.
Notation "[ × P1 , P2 , P3 , P4 , P5 , P6 , P7 , P8 , P9 & P10 ]" := (and10 P1 P2 P3 P4 P5 P6 P7 P8 P9 P10) : type_scope.

#[global] Hint Constructors prod and3 and3 and5 and6 and7 and8 and9 : core.
(* #[global] Hint Extern 0 =>
  repeat match goal with
    | H : [× _ & _] |- _ => destruct H 
    | H : [× _, _ & _] |- _ => destruct H 
    | H : [× _, _, _ & _] |- _ => destruct H
    | H : [× _, _, _, _ & _] |- _ => destruct H
    | H : [× _, _, _, _, _ & _] |- _ => destruct H
    | H : [× _, _, _, _, _, _ & _] |- _ => destruct H
    | H : [× _, _, _, _, _, _, _ & _] |- _ => destruct H
    | H : [× _, _, _, _, _, _, _, _ & _] |- _ => destruct H
  end
  : core. *)

(* Redefine for universe poly + cumulativity *)
Inductive sigT {A : Type} (P : A -> Type) : Type := 
  | existT (projT1 : A) (projT2 : P projT1) : sigT P.

Definition projT1 {A P} (x : @sigT A P) : A := let '(existT _ a _) := x in a.
Definition projT2 {A P} (x : @sigT A P) : P (projT1 x) := let '(existT _ _ p) := x in p.

Notation "'∑' x .. y , p" := (sigT (fun x => .. (sigT (fun y => p%type)) ..))
  (at level 200, x binder, right associativity,
   format "'[' '∑'  '/  ' x  ..  y ,  '/  ' p ']'")
  : type_scope.

Notation "( x ; .. ; y ; z )" := (existT _ x .. (existT _ y z) ..) : core_scope.
Notation "x .π1" := (@projT1 _ _ x) (at level 3, format "x '.π1'").
Notation "x .π2" := (@projT2 _ _ x) (at level 3, format "x '.π2'").

#[global] Hint Constructors sigT : core.

(* The database used for generic typing *)
Create HintDb gen_typing.
#[global] Hint Constants Opaque : gen_typing.
#[global] Hint Variables Transparent : gen_typing.

Ltac gen_typing := typeclasses eauto bfs 6 with gen_typing typeclass_instances.

(* A general refolding tactic to recover lost typeclasses
  (due for instance to the cbn or constructor tactics).
  Updated on the fly using the Smpl plugin. *)
Smpl Create refold [progress].

Ltac refold := repeat (smpl refold).

Ltac core_constructor := constructor.
Tactic Notation "constructor" := core_constructor ; refold.

Ltac core_econstructor := econstructor.
Tactic Notation "econstructor" := core_econstructor ; refold.

(* A tactic for presuppositions, ie deriving the well-formation of parts of a typing
judgment from said typing judgement. For instance, [Γ |- A] from [Γ |- t : A].
Made stronger over time, as we prove more of these properties. *)

Create HintDb boundary.
#[global] Hint Constants Opaque : boundary.
#[global] Hint Variables Transparent : boundary.

Ltac boundary := solve[eauto 3 with boundary].

#[universes(polymorphic)]
Definition tr@{u v} {A : Type@{u}} (P : A -> Type@{v}) {x y : A} (e: x = y) : P x -> P y :=
    match e in _ = z return P x -> P z with
    | eq_refl => fun w => w
    end.

(* Tactics used to create good induction principles using Scheme *)

Ltac polymorphise t :=
  lazymatch t with
    | forall x : ?Hyp, @?T x => constr:(forall x : Hyp, ltac:(
        let T' := ltac:(eval hnf in (T x)) in let T'' := polymorphise T' in exact T''))
    | (?t1 * ?t2)%type => let t1' := polymorphise t1 in let t2' := polymorphise t2 in
        constr:(t1' × t2')
    | ?t' => t'
  end.

Ltac remove_steps t :=
  lazymatch t with
  | _ -> ?T => remove_steps T
  | forall x : ?Hyp, @?T x => constr:(fun  x : Hyp => ltac:(
      let T' := ltac:(eval hnf in (T x)) in let T'' := remove_steps T' in exact T''))
  | ?t' => t'
  end.