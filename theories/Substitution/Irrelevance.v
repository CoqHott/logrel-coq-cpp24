
From LogRel.AutoSubst Require Import core unscoped Ast Extra.
From LogRel Require Import Utils BasicAst Notations Context Untyped Weakening GenericTyping LogicalRelation Reduction Validity.
From LogRel.LogicalRelation Require Import Irrelevance Reflexivity Transitivity.

Set Universe Polymorphism.

Section Irrelevances.
Context `{GenericTypingProperties}.


Lemma VRirrelevant Γ {vsubst vsubst' veqsubst veqsubst'}
  (vr : VR Γ vsubst veqsubst) (vr' : VR Γ vsubst' veqsubst') :
  (forall Δ σ wfΔ wfΔ', vsubst Δ σ wfΔ <~> vsubst' Δ σ wfΔ') ×
  (forall Δ σ σ' wfΔ wfΔ' vs vs', veqsubst Δ σ σ' wfΔ vs <~> veqsubst' Δ σ σ' wfΔ' vs').
Proof.
  revert vsubst' veqsubst' vr'.  pattern Γ, vsubst, veqsubst, vr.
  apply VR_rect; clear Γ vsubst veqsubst vr.
  - intros ?? h. inversion h. split; reflexivity.
  - intros ??????? ih ?? h. inversion h.
    specialize (ih _ _ VΓad0); destruct ih as [ih1 ih2].
    split.
    + intros. split; intros []; unshelve econstructor.
      1,2: eapply ih1; eassumption.
      1,2: eapply LRTmRedIrrelevant; eassumption.
    + intros; split; intros []; unshelve econstructor.
      1,3: eapply ih2; eassumption.
      1,2: eapply LRTmEqIrrelevant; eassumption.
Qed.

Lemma irrelevanceSubst {Γ} (VΓ VΓ' : [||-v Γ]) {σ Δ} (wfΔ wfΔ' : [|- Δ]) :
  [Δ ||-v σ : Γ | VΓ | wfΔ] -> [Δ ||-v σ : Γ | VΓ' | wfΔ'].
Proof.
  apply (fst (VRirrelevant Γ VΓ.(VAd.adequate) VΓ'.(VAd.adequate))).
Qed.

Lemma irrelevanceSubstEq {Γ} (VΓ VΓ' : [||-v Γ]) {σ σ' Δ} (wfΔ wfΔ' : [|- Δ])
  (Vσ : [Δ ||-v σ : Γ | VΓ | wfΔ]) (Vσ' : [Δ ||-v σ : Γ | VΓ' | wfΔ']) :
  [Δ ||-v σ ≅ σ' : Γ | VΓ | wfΔ | Vσ] -> [Δ ||-v σ ≅ σ' : Γ | VΓ' | wfΔ' | Vσ'].
Proof.
  apply (snd (VRirrelevant Γ VΓ.(VAd.adequate) VΓ'.(VAd.adequate))).
Qed.

Set Printing Primitive Projection Parameters.

Lemma reflSubst {Γ} (VΓ : [||-v Γ]) : forall {σ Δ} (wfΔ : [|- Δ])
  (Vσ : [Δ ||-v σ : Γ | VΓ | wfΔ]),
  [Δ ||-v σ ≅ σ : Γ | VΓ | wfΔ | Vσ].
Proof.
  pattern Γ, VΓ; apply validity_rect; clear Γ VΓ.
  - constructor.
  - intros * ih. unshelve econstructor.
    1: apply ih.
    apply LREqTermRefl_. exact (validHead Vσ).
Qed.

Lemma symmetrySubstEq {Γ} (VΓ VΓ' : [||-v Γ]) : forall {σ σ' Δ} (wfΔ wfΔ' : [|- Δ])
  (Vσ : [Δ ||-v σ : Γ | VΓ | wfΔ]) (Vσ' : [Δ ||-v σ' : Γ | VΓ' | wfΔ']),
  [Δ ||-v σ ≅ σ' : Γ | VΓ | wfΔ | Vσ] -> [Δ ||-v σ' ≅ σ : Γ | VΓ' | wfΔ' | Vσ'].
Proof.
  revert VΓ'; pattern Γ, VΓ; apply validity_rect; clear Γ VΓ.
  - intros VΓ'. rewrite (invValidityEmpty VΓ'). constructor.
  - intros * ih VΓ'. pose proof (x := invValiditySnoc VΓ').
    destruct x as [lA'[ VΓ'' [VA' ->]]].
    intros ????? [tl hd] [tl' hd'] [tleq hdeq].
    unshelve econstructor.
    1: now eapply ih.
    eapply LRTmEqSym. cbn in *.
    revert hdeq. apply LRTmEqRedConv.
    eapply validTyExt. 2:eassumption.
    eapply irrelevanceSubst; eassumption.
Qed.

Lemma transSubstEq {Γ} (VΓ : [||-v Γ]) :
  forall {σ σ' σ'' Δ} (wfΔ : [|- Δ])
    (Vσ : [Δ ||-v σ : Γ | VΓ | wfΔ])
    (Vσ' : [Δ ||-v σ' : Γ | VΓ | wfΔ]),
    [Δ ||-v σ ≅ σ' : Γ | VΓ | wfΔ | Vσ] ->
    [Δ ||-v σ' ≅ σ'' : Γ | VΓ | wfΔ | Vσ'] ->
    [Δ ||-v σ ≅ σ'' : Γ | VΓ | wfΔ | Vσ].
Proof.
  pattern Γ, VΓ; apply validity_rect; clear Γ VΓ.
  - constructor.
  - intros * ih * [] []; unshelve econstructor.
    1: now eapply ih.
    eapply transEqTerm; tea.
    eapply LRTmEqRedConv; tea.
    unshelve eapply LRTyEqSym; tea.
    2: unshelve eapply validTyExt.
    7: eassumption.
    1: tea.
    now eapply validTail.
Qed.

Lemma irrelevanceValidity {Γ} : forall (VΓ VΓ' : [||-v Γ]) {l A},
  [Γ ||-v<l> A | VΓ] -> [Γ ||-v<l> A | VΓ'].
Proof.
  intros VΓ VΓ' l A [VA VAext]; unshelve econstructor; intros.
  - unshelve eapply VA. 2: eapply irrelevanceSubst. all:eassumption.
  - eapply VAext; [eapply irrelevanceSubst| eapply irrelevanceSubstEq]; eassumption.
Qed.


Lemma irrelevanceLift {l A nF F nG G Γ} (VΓ : [||-v Γ])
  (VF: [Γ ||-v<l> F | VΓ]) (VG: [Γ ||-v<l> G | VΓ])
  (VFeqG : [Γ ||-v<l> F ≅ G | VΓ | VF]) :
  [Γ ,, vass nF F ||-v<l> A | validSnoc nF VΓ VF] ->
  [Γ ,, vass nG G ||-v<l> A | validSnoc nG VΓ VG].
Proof.
  intros [VA VAext]; unshelve econstructor.
  - intros ??? [hd tl]. eapply VA.
    unshelve econstructor. 1: eassumption.
    eapply LRTmRedConv. 2: eassumption.
    eapply LRTyEqSym; unshelve eapply VFeqG; eassumption.
  - intros ???? [??] [??] [??]. eapply VAext.
    + unshelve econstructor. 1: eassumption.
      eapply LRTmRedConv. 2: eassumption.
      eapply LRTyEqSym; unshelve eapply VFeqG; eassumption.
    + unshelve econstructor. 1: eassumption.
      eapply LRTmEqRedConv. 2: eassumption.
      eapply LRTyEqSym; unshelve eapply VFeqG; eassumption.
Qed.

Lemma irrelevanceEq {Γ l A B} (VΓ VΓ' : [||-v Γ]) (VA : [Γ ||-v<l> A | VΓ]) (VA' : [Γ||-v<l> A | VΓ']) :
  [Γ ||-v< l > A ≅ B | VΓ | VA] -> [Γ ||-v< l > A ≅ B | VΓ' | VA'].
Proof.
  intros [h]; constructor; intros.
  eapply LRTyEqIrrelevant.
  unshelve apply h. 1:eassumption.
  eapply irrelevanceSubst; eassumption.
Qed.

Lemma irrelevanceTm {Γ l t A} (VΓ VΓ' : [||-v Γ]) (VA : [Γ ||-v<l> A | VΓ]) (VA' : [Γ||-v<l> A | VΓ']) :
  [Γ ||-v<l> t : A | VΓ | VA] -> [Γ ||-v<l> t : A | VΓ' | VA'].
Proof.
  intros [h1 h2]; unshelve econstructor.
  - intros. eapply LRTmRedIrrelevant.
    unshelve apply h1. 1:eassumption.
    eapply irrelevanceSubst; eassumption.
  - intros. eapply LRTmEqIrrelevant.
    unshelve eapply h2. 1: eassumption.
    1,2: eapply irrelevanceSubst; eassumption.
    eapply irrelevanceSubstEq; eassumption.
Qed.

Lemma irrelevanceTmLift {l t A nF F nG G Γ} (VΓ : [||-v Γ])
  (VF: [Γ ||-v<l> F | VΓ]) (VG: [Γ ||-v<l> G | VΓ])
  (VFeqG : [Γ ||-v<l> F ≅ G | VΓ | VF])
  (VA : [Γ ,, vass nF F ||-v<l> A | validSnoc nF VΓ VF])
  (VA' : [Γ ,, vass nG G ||-v<l> A | validSnoc nG VΓ VG])  :
  [Γ ,, vass nF F ||-v<l> t : A | validSnoc nF VΓ VF | VA] ->
  [Γ ,, vass nG G ||-v<l> t : A | validSnoc nG VΓ VG | VA'].
Proof.
  intros [Vt Vtext]; unshelve econstructor.
  - intros ??? [hd tl]. eapply LRTmRedIrrelevant.
    unshelve eapply Vt. 1: eassumption.
    unshelve econstructor. 1: eassumption.
    eapply LRTmRedConv. 2: eassumption.
    eapply LRTyEqSym; unshelve eapply VFeqG; eassumption.
  - intros ???? [??] [??] [??]. eapply LRTmEqIrrelevant.
    unshelve eapply Vtext. 1: eassumption.
    + unshelve econstructor. 1: eassumption.
      eapply LRTmRedConv. 2: eassumption.
      eapply LRTyEqSym; unshelve eapply VFeqG; eassumption.
    + unshelve econstructor. 1: eassumption.
      eapply LRTmRedConv. 2: eassumption.
      eapply LRTyEqSym; unshelve eapply VFeqG; eassumption.
    + unshelve econstructor. 1: eassumption.
      eapply LRTmEqRedConv. 2: eassumption.
      eapply LRTyEqSym; unshelve eapply VFeqG; eassumption.
Qed.

Lemma irrelevanceTmEq {Γ l t u A} (VΓ VΓ' : [||-v Γ]) (VA : [Γ ||-v<l> A | VΓ]) (VA' : [Γ||-v<l> A | VΓ']) :
  [Γ ||-v<l> t ≅ u : A | VΓ | VA] -> [Γ ||-v<l> t ≅ u : A | VΓ' | VA'].
Proof.
  intros [h]; constructor; intros.
  eapply LRTmEqIrrelevant; unshelve apply h.
  1: eassumption.
  eapply irrelevanceSubst; eassumption.
Qed.

Lemma irrelevanceSubstExt {Γ} (VΓ : [||-v Γ]) {σ σ' Δ} (wfΔ : [|- Δ]) :
  σ =1 σ' -> [Δ ||-v σ : Γ | VΓ | wfΔ] -> [Δ ||-v σ' : Γ | VΓ | wfΔ].
Proof.
  revert σ σ'; pattern Γ, VΓ; apply validity_rect; clear Γ VΓ.
  - constructor.
  - intros ?????? ih ?? eq.  unshelve econstructor.
    + eapply ih. 2: now eapply validTail.
      now rewrite eq.
    + rewrite <- (eq var_zero).
      pose proof (validHead X).
      irrelevance. now rewrite eq.
Qed.

Lemma irrelevanceSubstEqExt {Γ} (VΓ : [||-v Γ]) {σ1 σ1' σ2 σ2' Δ}
  (wfΔ : [|- Δ]) (eq1 : σ1 =1 σ1') (eq2 : σ2 =1 σ2')
  (Vσ1 : [Δ ||-v σ1 : Γ | VΓ | wfΔ]) :
  [Δ ||-v σ1 ≅ σ2 : Γ | VΓ | wfΔ | Vσ1] ->
  [Δ ||-v σ1' ≅ σ2' : Γ | VΓ | wfΔ | irrelevanceSubstExt VΓ wfΔ eq1 Vσ1].
Proof.
  revert σ1 σ1' σ2 σ2' eq1 eq2 Vσ1; pattern Γ, VΓ; apply validity_rect; clear Γ VΓ.
  - constructor.
  - intros ?????? ih ???? eq1 eq2 ? X. unshelve econstructor.
    + eapply irrelevanceSubstEq.
      unshelve eapply ih.
      6: now eapply eqTail.
      all: now (rewrite eq1 + rewrite eq2).
    + rewrite <- (eq1 var_zero); rewrite <- (eq2 var_zero).
      pose proof (eqHead X).
      irrelevance.
      rewrite eq1; reflexivity.
Qed.

End Irrelevances.
