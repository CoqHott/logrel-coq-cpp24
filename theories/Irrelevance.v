From LogRel.AutoSubst Require Import core unscoped Ast.
From LogRel Require Import Utils BasicAst Notations Context Untyped Weakening GenericTyping LogicalRelation Reduction LRInduction ShapeView Reflexivity.

Section Irrelevances.
Context `{GenericTypingProperties}.


Section ΠIrrelevanceLemmas.
Context Γ A A' (ΠA : PiRedTy Γ A) (ΠA' : PiRedTy Γ A') 
  (dom := PiRedTy.dom ΠA)
  (dom' := PiRedTy.dom ΠA')
  (domRed := (@PiRedTy.domRed _ _ _ _ _ _ _ ΠA))
  (domRed' := (@PiRedTy.domRed _ _ _ _ _ _ _ ΠA'))
  (cod := PiRedTy.cod ΠA)
  (cod' := PiRedTy.cod ΠA')
  (codRed := (@PiRedTy.codRed _ _ _ _ _ _ _ ΠA))
  (codRed' := (@PiRedTy.codRed _ _ _ _ _ _ _ ΠA'))
  (eqPi : [Γ |- tProd (PiRedTy.na ΠA) dom cod ≅ tProd (PiRedTy.na ΠA') dom' cod']).

Lemma ΠIrrelevanceTyEq  :
  (forall (Δ : context) (ρ : Δ ≤ Γ) (h : [  |- Δ]),
  [× (forall B : term,
      [domRed Δ ρ h | Δ ||- dom⟨ρ⟩ ≅ B] <~> [domRed' Δ ρ h | Δ ||- dom'⟨ρ⟩ ≅ B]),
    (forall t : term,
      [domRed Δ ρ h | Δ ||- t : dom⟨ρ⟩] <~> [domRed' Δ ρ h | Δ ||- t : dom'⟨ρ⟩]) &
    (forall t u : term,
      [domRed Δ ρ h | Δ ||- t ≅ u : dom⟨ρ⟩ ] <~> [domRed' Δ ρ h | Δ ||- t ≅ u : dom'⟨ρ⟩])]) ->
  (forall (Δ : context) (ρ : Δ ≤ Γ) (a : term) (h : [  |- Δ])
      (ha : [domRed Δ ρ h | Δ ||- a : dom⟨ρ⟩])
      (ha' : [domRed' Δ ρ h | Δ ||- a : dom'⟨ρ⟩]),
  [× (forall B : term,
      [codRed Δ a ρ h ha | Δ ||- cod[a .: (ρ >> tRel)] ≅ B] <~>
      [codRed' Δ a ρ h ha' | Δ ||- cod'[a .: (ρ >> tRel)] ≅ B]),
    (forall t : term,
      [codRed Δ a ρ h ha | Δ ||- t : cod[a .: (ρ >> tRel)] ] <~>
      [codRed' Δ a ρ h ha' | Δ ||- t : cod'[a .: (ρ >> tRel)]]) &
    (forall t u : term,
      [codRed Δ a ρ h ha | Δ ||- t ≅ u : cod[a .: (ρ >> tRel)]] <~>
      [codRed' Δ a ρ h ha' | Δ ||- t ≅ u : cod'[a .: (ρ >> tRel)] ])]) ->
  forall B, [Γ ||-Π A ≅ B | ΠA] -> [Γ ||-Π A' ≅ B | ΠA'].
Proof.
  intros IHdom IHcod B [] ; cbn in *.
  econstructor.
  - now gen_typing.
  - cbn in *.
    etransitivity.
    2: eassumption.
    now symmetry.
  - intros ; now apply IHdom.
  - intros.
    cbn in *.
    unshelve eapply IHcod.
    2: eauto.
    now eapply IHdom.
Qed.

Lemma ΠIrrelevanceTm  :
  (forall (Δ : context) (ρ : Δ ≤ Γ) (h : [  |- Δ]),
  [× (forall B : term,
      [domRed Δ ρ h | Δ ||- dom⟨ρ⟩ ≅ B] <~> [domRed' Δ ρ h | Δ ||- dom'⟨ρ⟩ ≅ B]),
    (forall t : term,
      [domRed Δ ρ h | Δ ||- t : dom⟨ρ⟩] <~> [domRed' Δ ρ h | Δ ||- t : dom'⟨ρ⟩]) &
    (forall t u : term,
      [domRed Δ ρ h | Δ ||- t ≅ u : dom⟨ρ⟩ ] <~> [domRed' Δ ρ h | Δ ||- t ≅ u : dom'⟨ρ⟩])]) ->
  (forall (Δ : context) (ρ : Δ ≤ Γ) (a : term) (h : [  |- Δ])
      (ha : [domRed Δ ρ h | Δ ||- a : dom⟨ρ⟩])
      (ha' : [domRed' Δ ρ h | Δ ||- a : dom'⟨ρ⟩]),
  [× (forall B : term,
      [codRed Δ a ρ h ha | Δ ||- cod[a .: (ρ >> tRel)] ≅ B] <~>
      [codRed' Δ a ρ h ha' | Δ ||- cod'[a .: (ρ >> tRel)] ≅ B]),
    (forall t : term,
      [codRed Δ a ρ h ha | Δ ||- t : cod[a .: (ρ >> tRel)] ] <~>
      [codRed' Δ a ρ h ha' | Δ ||- t : cod'[a .: (ρ >> tRel)]]) &
    (forall t u : term,
      [codRed Δ a ρ h ha | Δ ||- t ≅ u : cod[a .: (ρ >> tRel)]] <~>
      [codRed' Δ a ρ h ha' | Δ ||- t ≅ u : cod'[a .: (ρ >> tRel)] ])]) ->
  forall t, [Γ ||-Π t : A | ΠA] -> [Γ ||-Π t : A' | ΠA'].
Proof.
  intros IHdom IHcod B [] ; cbn in *.
  econstructor.
  - cbn.
    econstructor.
    all: gen_typing.
  - eassumption.
  - cbn.
    gen_typing.
  - intros.
    unshelve eapply IHcod.
    2: now auto.
    now apply IHdom.
  - intros.
    unshelve eapply IHcod, eq.
    all: now eapply IHdom.
Defined.

Lemma ΠIrrelevanceTmEq  :
  (forall (Δ : context) (ρ : Δ ≤ Γ) (h : [  |- Δ]),
  [× (forall B : term,
      [domRed Δ ρ h | Δ ||- dom⟨ρ⟩ ≅ B] <~> [domRed' Δ ρ h | Δ ||- dom'⟨ρ⟩ ≅ B]),
    (forall t : term,
      [domRed Δ ρ h | Δ ||- t : dom⟨ρ⟩] <~> [domRed' Δ ρ h | Δ ||- t : dom'⟨ρ⟩]) &
    (forall t u : term,
      [domRed Δ ρ h | Δ ||- t ≅ u : dom⟨ρ⟩ ] <~> [domRed' Δ ρ h | Δ ||- t ≅ u : dom'⟨ρ⟩])]) ->
  (forall (Δ : context) (ρ : Δ ≤ Γ) (a : term) (h : [  |- Δ])
      (ha : [domRed Δ ρ h | Δ ||- a : dom⟨ρ⟩])
      (ha' : [domRed' Δ ρ h | Δ ||- a : dom'⟨ρ⟩]),
  [× (forall B : term,
      [codRed Δ a ρ h ha | Δ ||- cod[a .: (ρ >> tRel)] ≅ B] <~>
      [codRed' Δ a ρ h ha' | Δ ||- cod'[a .: (ρ >> tRel)] ≅ B]),
    (forall t : term,
      [codRed Δ a ρ h ha | Δ ||- t : cod[a .: (ρ >> tRel)] ] <~>
      [codRed' Δ a ρ h ha' | Δ ||- t : cod'[a .: (ρ >> tRel)]]) &
    (forall t u : term,
      [codRed Δ a ρ h ha | Δ ||- t ≅ u : cod[a .: (ρ >> tRel)]] <~>
      [codRed' Δ a ρ h ha' | Δ ||- t ≅ u : cod'[a .: (ρ >> tRel)] ])]) ->
  forall t u, [Γ ||-Π t ≅ u : A | ΠA] -> [Γ ||-Π t ≅ u : A' | ΠA'].
Proof.
  intros IHdom IHcod t u [] ; cbn in *.
  unshelve econstructor.
  - now eapply ΠIrrelevanceTm.
  - now eapply ΠIrrelevanceTm.
  - cbn.
    gen_typing.
  - intros.
    unshelve eapply IHcod.
    2: now auto.
    now apply IHdom.
Qed.

End ΠIrrelevanceLemmas.


Theorem LRIrrelevant Γ A A' {lA eqTyA redTmA eqTmA lA' eqTyA' redTmA' eqTmA'}
    (lrA : LogRel lA Γ A eqTyA redTmA eqTmA) (lrA' : LogRel lA' Γ A' eqTyA' redTmA' eqTmA') :
    eqTyA A' ->
    [× forall B, eqTyA B <~> eqTyA' B ,
    forall t, redTmA t <~> redTmA' t &
    forall t u, eqTmA t u <~> eqTmA' t u ].
Proof.
  intros he.
  set (s := ShapeViewConv lrA lrA' he).
  induction lrA as [? [? []] | ? ? [] | ? A [] [] IHdom IHcod]
    in lA', A', eqTyA', eqTmA', redTmA', lrA', he, s |- *.
  - destruct lrA' as [? [? []] | | ]; try solve [destruct s] ; clear s.
    split.
    + intros ?.
      split.
      all: eauto.
    + intros ?.
      split.
      all: intros [].
      all: now econstructor.
    + intros ? ?.
      split.
      all: intros [[] []].
      all: unshelve econstructor ; tea.
      1-4: now econstructor.
      all: eassumption.
  - destruct lrA' as [|? A' neA'|] ; try solve [destruct s] ; clear s.
    destruct he as [AA], neA' as [AA'] ; cbn in *.
    assert (AA' = AA) as ->.
    {
      all: eapply whredty_det ; econstructor ; [idtac |now econstructor| idtac |now econstructor].
      all: gen_typing.
    }
    assert [Γ |- ty ≅ AA] as convtAA by gen_typing.
    split.
    + intros ?.
      split.
      all: intros [].
      all: econstructor.
      all: cbn in *.
      all: try eauto.
      2: etransitivity ; eassumption.
      etransitivity ; [symmetry|..] ; eassumption.
    + intros ?.
      split.
      2: symmetry in convtAA.
      all: intros [].
      all: econstructor ; cbn in *.
      all: try eauto.
      1,3: eapply wfredtm_conv ; eassumption.
      all: gen_typing.
    + intros ? ?.
      split.
      2: symmetry in convtAA.
      all: intros [].
      all: econstructor.
      all: cbn in *.
      1-2,6-7: eapply wfredtm_conv ; eassumption.
      1-2,4-5: eassumption.
      all: now gen_typing.
  - destruct lrA' as [| | ? A' [] []] ; try solve [destruct s] ; clear s.
    destruct he ; cbn -[subst1] in *.
    assert (tProd na0 dom0 cod0 = tProd na1 dom1 cod1) as ePi
      by (eapply whredty_det ; gen_typing).
    inversion ePi ; subst ; clear ePi.
    pose proof (IHdom_ := fun Δ ρ h => IHdom Δ ρ h _ _ _ _ _ (domAd0 Δ ρ h) (domRed1 Δ ρ h)).
    assert (IHcod_ : forall Δ a (ρ : Δ ≤ Γ) (h : [|- Δ])
      (ha : [domRed Δ ρ h | Δ ||- a : dom⟨ρ⟩])
      (ha' : [domRed0 Δ ρ h | Δ ||- a : dom1⟨ρ⟩]),
      [×
        (forall B,
          [codRed Δ a ρ h ha | Δ ||- cod[a .: (ρ >> tRel)] ≅ B] <~>
          [codRed0 Δ a ρ h ha' | Δ ||- cod1[a .: (ρ >> tRel)] ≅ B]),
        (forall t,
          [codRed Δ a ρ h ha | Δ ||- t : cod[a .: (ρ >> tRel)]] <~>
          [codRed0 Δ a ρ h ha' | Δ ||- t : cod1[a .: (ρ >> tRel)]]) &
      (forall t u,
        [codRed Δ a ρ h ha | Δ ||- t ≅ u : cod[a .: (ρ >> tRel)]] <~>
        [codRed0 Δ a ρ h ha' | Δ ||- t ≅ u : cod1[a .: (ρ >> tRel)]])
      ]).
    {
      intros.
      eapply IHcod.
      1: eapply codAd0.
      eauto.
    }
    split.
    + split ; intros.
      all: eapply ΠIrrelevanceTyEq.
      4,8: eassumption. 
      1,4: assumption + now symmetry.
      1-2: now eauto.
      * do 2 split ; intros.
        all: now eapply IHdom_ ; eauto.
      * do 2 split ; intros.
        all: now eapply IHcod_ ; eauto.
    + split ; intros.
      all: eapply ΠIrrelevanceTm.
      4,8: eassumption. 
      1,4: assumption + now symmetry.
      1-2: now eauto.
      * do 2 split ; intros.
        all: now eapply IHdom_ ; eauto.
      * do 2 split ; intros.
        all: now eapply IHcod_ ; eauto.
    + split ; intros.
      all: eapply ΠIrrelevanceTmEq.
      4,8: eassumption. 
      1,4: assumption + now symmetry.
      1-2: now eauto.
      * do 2 split ; intros.
        all: now eapply IHdom_ ; eauto.
      * do 2 split ; intros.
        all: now eapply IHcod_ ; eauto.
Qed.

Corollary TyEqIrrelevant Γ A {lA eqTyA redTmA eqTmA lA' eqTyA' redTmA' eqTmA'}
  (lrA : LogRel lA Γ A eqTyA redTmA eqTmA) (lrA' : LogRel lA' Γ A eqTyA' redTmA' eqTmA') :
  forall B, eqTyA B -> eqTyA' B.
Proof.
  apply (LRIrrelevant _ _ _ lrA lrA').
  now eapply LRTyEqRefl.
Qed.

Corollary LRTyEqIrrelevant lA lA' Γ A (lrA : [Γ ||-< lA > A]) (lrA' : [Γ ||-< lA'> A]) :
  forall B, [Γ ||-< lA > A ≅ B | lrA] -> [Γ ||-< lA' > A ≅ B | lrA'].
Proof.
  destruct lrA, lrA'.
  cbn in *.
  now eapply TyEqIrrelevant.
Qed.

Corollary RedTmIrrelevant Γ A {lA eqTyA redTmA eqTmA lA' eqTyA' redTmA' eqTmA'}
  (lrA : LogRel lA Γ A eqTyA redTmA eqTmA) (lrA' : LogRel lA' Γ A eqTyA' redTmA' eqTmA') :
  forall t, redTmA t -> redTmA' t.
Proof.
  apply (LRIrrelevant _ _ _ lrA lrA').
  now eapply LRTyEqRefl.
Qed.

Corollary LRTmRedIrrelevant lA lA' Γ A (lrA : [Γ ||-< lA > A]) (lrA' : [Γ ||-< lA'> A]) :
  forall t, [Γ ||-< lA > t : A | lrA] -> [Γ ||-< lA' > t : A | lrA'].
Proof.
  destruct lrA, lrA'.
  cbn in *.
  now eapply RedTmIrrelevant.
Qed.

Corollary TmEqIrrelevant Γ A {lA eqTyA redTmA eqTmA lA' eqTyA' redTmA' eqTmA'}
  (lrA : LogRel lA Γ A eqTyA redTmA eqTmA) (lrA' : LogRel lA' Γ A eqTyA' redTmA' eqTmA') :
  forall t u, eqTmA t u -> eqTmA' t u.
Proof.
  apply (LRIrrelevant _ _ _ lrA lrA').
  now eapply LRTyEqRefl.
Qed.

Corollary LRTmEqIrrelevant lA lA' Γ A (lrA : [Γ ||-< lA > A]) (lrA' : [Γ ||-< lA'> A]) :
  forall t u, [Γ ||-< lA > t ≅ u : A | lrA] -> [Γ ||-< lA' > t ≅ u : A | lrA'].
Proof.
  destruct lrA, lrA'.
  cbn in *.
  now eapply TmEqIrrelevant.
Qed.


Corollary TyEqSym Γ A A' {lA eqTyA redTmA eqTmA lA' eqTyA' redTmA' eqTmA'}
  (lrA : LogRel lA Γ A eqTyA redTmA eqTmA) (lrA' : LogRel lA' Γ A' eqTyA' redTmA' eqTmA') :
  eqTyA A' -> eqTyA' A.
Proof.
  intros.
  apply (LRIrrelevant _ _ _ lrA lrA').
  1: eauto.
  now eapply LRTyEqRefl.
Qed.

Corollary LRTyEqSym lA lA' Γ A A' (lrA : [Γ ||-< lA > A]) (lrA' : [Γ ||-< lA'> A']) :
  [Γ ||-< lA > A ≅ A' | lrA] -> [Γ ||-< lA' > A' ≅ A | lrA'].
Proof.
  destruct lrA, lrA'.
  cbn in *.
  now eapply TyEqSym.
Qed.

Corollary RedTmConv Γ A A' {lA eqTyA redTmA eqTmA lA' eqTyA' redTmA' eqTmA'}
  (lrA : LogRel lA Γ A eqTyA redTmA eqTmA) (lrA' : LogRel lA' Γ A' eqTyA' redTmA' eqTmA') :
  eqTyA A' ->
  forall t, redTmA t -> redTmA' t.
Proof.
  apply (LRIrrelevant _ _ _ lrA lrA').
Qed.

Corollary LRTmRedConv lA lA' Γ A A' (lrA : [Γ ||-< lA > A]) (lrA' : [Γ ||-< lA'> A' ]) :
  [Γ ||-< lA > A ≅ A' | lrA ] ->
  forall t, [Γ ||-< lA > t : A | lrA] -> [Γ ||-< lA' > t : A' | lrA'].
Proof.
  destruct lrA, lrA'.
  cbn in *.
  now eapply RedTmConv.
Qed.

Corollary TmEqRedConv Γ A A' {lA eqTyA redTmA eqTmA lA' eqTyA' redTmA' eqTmA'}
  (lrA : LogRel lA Γ A eqTyA redTmA eqTmA) (lrA' : LogRel lA' Γ A' eqTyA' redTmA' eqTmA') :
  eqTyA A' ->
  forall t u, eqTmA t u -> eqTmA' t u.
Proof.
  apply (LRIrrelevant _ _ _ lrA lrA').
Qed.

Corollary LRTmEqRedConv lA lA' Γ A A' (lrA : [Γ ||-< lA > A]) (lrA' : [Γ ||-< lA'> A']) :
  [Γ ||-< lA > A ≅ A' | lrA ] ->
  forall t u, [Γ ||-< lA > t ≅ u : A | lrA] -> [Γ ||-< lA' > t ≅ u : A' | lrA'].
Proof.
  destruct lrA, lrA'.
  cbn in *.
  now eapply TmEqRedConv.
Qed.

Set Printing Primitive Projection Parameters.

Lemma LRTmEqSym lA Γ A (lrA : [Γ ||-<lA> A]) : forall t u,
  [Γ ||-<lA> t ≅ u : A |lrA] -> [Γ ||-<lA> u ≅ t : A |lrA].
Proof.
  pattern lA, Γ, A, lrA. apply LR_rect_TyUr.
  - intros * []. unshelve econstructor; try eassumption.
    1: symmetry; eassumption.
    eapply LRTyEqSym. exact relEq.
  - intros * []. unshelve econstructor.
    3,4: eassumption.
    1,2: eassumption.
    symmetry; eassumption.
  - intros * ihdom ihcod * []. unshelve econstructor.
    1,2: eassumption.
    1: symmetry; eassumption.
    intros. apply ihcod. eapply eqApp.
Qed.


End Irrelevances.