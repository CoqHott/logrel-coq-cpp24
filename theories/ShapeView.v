From LogRel.AutoSubst Require Import core unscoped Ast.
From LogRel Require Import Utils BasicAst Notations Context Untyped GenericTyping LogicalRelation Reduction LRInduction Reflexivity.

Set Universe Polymorphism.

Section ShapeViews.
  Context `{GenericTypingProperties}.

  Definition ShapeView Γ
    A {lA eqTyA redTmA redTyA} B {lB eqTyB redTmB redTyB}
    (lrA : LRl lA Γ A eqTyA redTmA redTyA) (lrB : LRl lB Γ B eqTyB redTmB redTyB) : Type :=
    match lrA, lrB with
      | LRU _ _, LRU _ _ => True
      | LRne _ _, LRne _ _ => True
      | LRPi _ _ _, LRPi _ _ _ => True
      | _, _ => False
    end.
    
    (* | SVU (UredA UredB : [ Γ ||-U l]):
          ShapeView l Γ U U (LRU (LogRelRec l) UredA) (LRU (LogRelRec l) UredB)

      | SVne {A B} neA neB :
          ShapeView l Γ A B (LRne (LogRelRec l) neA) (LRne (LogRelRec l) neB)

      | SVPi {A B} ΠA ΠB ΠAad ΠBad:
          ShapeView l Γ A B (LRPi (LogRelRec l) ΠA ΠAad) (LRPi (LogRelRec l) ΠB ΠBad). *)

  Arguments ShapeView Γ A {lA eqTyA redTmA redTyA} B {lB eqTyB redTmB redTyB}
  !lrA !lrB.

  Lemma ShapeViewConv {Γ A lA eqTyA redTmA eqTmA B lB eqTyB redTmB eqTmB}
    (lrA : LRl lA Γ A eqTyA redTmA eqTmA) (lrB : LRl lB Γ B eqTyB redTmB eqTmB) :
    eqTyA B ->
    ShapeView Γ A B lrA lrB.
  Proof.
    destruct lrA.
    - destruct lrB.
      + constructor.
      + intros [->].
        inversion neA.
        enough (ty = U) as -> by inversion ne.
        symmetry.
        eapply mredty_whnf.
        all: gen_typing.
      + intros [->].
        inversion ΠA.
        enough (U = tProd na dom cod) by congruence.
        eapply mredty_whnf.
        all: gen_typing.
    - destruct lrB.
      + intros [].
        inversion neA.
        enough (ty = U) as -> by inversion ne.
        symmetry.
        eapply mredty_whnf.
        all: gen_typing.
      + econstructor.
      + intros [].
        destruct ΠA ; cbn in *.
        enough (ty = tProd na dom cod) as -> by inversion ne.
        eapply whredty_det.
        all: gen_typing.
    - destruct lrB.
      + intros [].
        inversion ΠA.
        enough (U = tProd na dom cod) by congruence.
        eapply mredty_whnf.
        all: gen_typing.
      + intros [].
        destruct neA.
        enough (ty = tProd na dom cod) as -> by inversion ne.
        eapply whredty_det.
        all: gen_typing.
      + now easy.
  Qed.

  Corollary ShapeViewRefl {Γ A lA eqTyA redTmA eqTmA lA' eqTyA' redTmA' eqTmA'}
    (lrA : LRl lA Γ A eqTyA redTmA eqTmA) (lrA' : LRl lA' Γ A eqTyA' redTmA' eqTmA') :
    ShapeView Γ A A lrA lrA'.
  Proof.
    now eapply ShapeViewConv, LRTyEqRefl.
  Qed.

End ShapeViews.