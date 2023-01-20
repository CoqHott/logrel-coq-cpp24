From LogRel.AutoSubst Require Import core unscoped Ast.
From LogRel Require Import Utils BasicAst Notations Context Untyped Weakening UntypedReduction
  GenericTyping DeclarativeTyping Generation Reduction AlgorithmicTyping LogRelConsequences McBrideDiscipline.

Import AlgorithmicTypingData DeclarativeTypingProperties.

Lemma infer_red_equiv Γ t A :
  InferRedAlg Γ A t <~> [Γ |-[al] t ▹h A].
Proof.
  split ; intros [] ; now econstructor.
Qed.

Section AlgoConvConv.

  Lemma in_ctx_conv Γ' Γ n decl :
  [|-[de] Γ' ≅ Γ] ->
  in_ctx Γ n decl ->
  ∑ decl', (in_ctx Γ' n decl') × ([Γ' |-[de] decl'.(decl_type) ≅ decl.(decl_type)]).
  Proof.
  intros Hconv Hin.
  induction Hin in Γ', Hconv |- *.
  all: inversion Hconv ; subst ; clear Hconv.
  1: eexists ; split.
  - now econstructor.
  - cbn.
    eapply typing_shift ; tea.
    all: eapply validity in H3 as [].
    all: gen_typing.
  - destruct d as [? d].
    edestruct IHHin as [[? d'] []].
    1: eassumption.
    cbn in *.
    econstructor ; split.
    1: now econstructor.
    cbn.
    eapply typing_shift ; tea.
    all: now eapply validity in H3 as [] ; gen_typing.
  Qed.

  Let PTyEq (Γ : context) (A B : term) := True.
  Let PTyRedEq (Γ : context) (A B : term) := True.
  Let PNeEq (Γ : context) (A t u : term) := forall Γ',
    [|-[de] Γ' ≅ Γ] ->
    (∑ T, [Γ |-[de] t : T]) ->
    (∑ T, [Γ |-[de] u : T]) ->
    ∑ A', [Γ' |-[al] t ~ u ▹ A'] × [Γ' |-[de] A' ≅ A].
  Let PNeRedEq (Γ : context) (A t u : term) := forall Γ',
    [|-[de] Γ' ≅ Γ] ->
    (∑ T, [Γ |-[de] t : T]) ->
    (∑ T, [Γ |-[de] u : T]) ->
    ∑ A', [× [Γ' |- t ~h u ▹ A'], [Γ' |-[de] A' ≅ A] & isType A'].
  Let PTmEq (Γ : context) (A t u : term) := forall Γ' A',
    [|-[de] Γ' ≅ Γ] -> [Γ' |-[de] A ≅ A'] ->
    [Γ |-[de] t : A] -> [Γ |-[de] u : A ] ->
    [Γ' |-[al] t ≅ u : A'].
  Let PTmRedEq (Γ : context) (A t u : term) := forall Γ' A',
    [|-[de] Γ' ≅ Γ] -> [Γ' |-[de] A ≅ A'] -> isType A' ->
    [Γ |-[de] t : A] -> [Γ |-[de] u : A ] ->
    [Γ' |- t ≅h u : A'].

  Let PTyEq' (Γ : context) (A B : term) := True.
  Let PTyRedEq' (Γ : context) (A B : term) := True.
  Let PNeEq' (Γ : context) (A t u : term) := forall Γ',
    [|-[de] Γ' ≅ Γ] ->
    ∑ A', [Γ' |-[al] t ~ u ▹ A'] × [Γ' |-[de] A' ≅ A].
  Let PNeRedEq' (Γ : context) (A t u : term) := forall Γ',
    [|-[de] Γ' ≅ Γ] ->
    ∑ A', [× [Γ' |- t ~h u ▹ A'], [Γ' |-[de] A' ≅ A] & isType A'].
  Let PTmEq' (Γ : context) (A t u : term) := forall Γ' A',
    [|-[de] Γ' ≅ Γ] -> [Γ' |-[de] A ≅ A'] ->
    [Γ' |-[al] t ≅ u : A'].
  Let PTmRedEq' (Γ : context) (A t u : term) := forall Γ' A',
    [|-[de] Γ' ≅ Γ] -> [Γ' |-[de] A ≅ A'] -> isType A' ->
    [Γ' |- t ≅h u : A'].

  Theorem algo_conv_conv :
  AlgoConvInductionConcl PTyEq PTyRedEq PNeEq PNeRedEq PTmEq PTmRedEq.
  Proof.
    subst PTyEq PTyRedEq PNeEq PNeRedEq PTmEq PTmRedEq.
    enough (AlgoConvDisciplineInductionConcl PTyEq' PTyRedEq' PNeEq' PNeRedEq' PTmEq' PTmRedEq') as Hind.
    all: subst PTyEq' PTyRedEq' PNeEq' PNeRedEq' PTmEq' PTmRedEq'.
    {
      unfold AlgoConvDisciplineInductionConcl, AlgoConvInductionConcl in *.
      unshelve (repeat (split ; [destruct Hind as [Hind _] ; shelve | destruct Hind as [_ Hind]])).
      1-2: now constructor.
      all: intros ; eapply Hind ; tea.
      all: match goal with H : ConvCtx _ _ |- _ => symmetry in H ; now apply wf_conv_ctx in H end.
    }
    apply AlgoConvDisciplineInduction ; cbn in *.
    all: try solve [now constructor].
    - intros * HΓ ? _ _ ? ?.
      eapply in_ctx_conv in HΓ as [? []] ; tea.
      eexists ; split.
      1: now econstructor.
      eassumption.
    - intros * ? IHm Ht IHt ? ? ? ? HΓ.
      edestruct IHm as [[? [? HconvP]] ?]; tea.
      eapply red_ty_compl_prod_r in HconvP as (?&?&?&[HconvP HconvA]).
      eapply redty_red, red_whnf in HconvP as ->.
      2: gen_typing.
      destruct IHt as [IHt IHt'].
      specialize (IHt _ _ HΓ HconvA).
      eexists ; split.
      1: econstructor ; fold_algo ; tea.
      eapply typing_subst1 ; tea.
      econstructor.
      eapply stability ; tea.
      now eapply validity in IHt' as [].
    - intros * ? IHm ; intros.
      edestruct IHm as [[A'' [IHm' ?]] [Hconvm]]; tea.
      assert [Γ' |-[de] A' ≅ A''] as HconvA'.
      {
        symmetry.
        etransitivity ; tea.
        eapply RedConvTyC, subject_reduction_type ; tea.
        eapply validity in Hconvm as [].
        now eapply stability. 
      }
      pose proof (HconvA'' := HconvA').
      eapply red_ty_complete in HconvA'' as [? []]; tea.
      eexists ; split.
      + econstructor ; tea.
        now eapply redty_red.
      + symmetry ; etransitivity ; tea.
        now eapply RedConvTyC.
      + gen_typing. 
    - intros * ? ? ? Ht IH ? ? ? ? A'' ? HconvA; intros.
      pose proof Ht as Ht'.
      eapply algo_conv_wh in Ht' as [? ? HwhA].
      assert [Γ' |-[de] A' ≅ A''] as HconvA'.
      {
        etransitivity ; tea.
        symmetry.
        eapply RedConvTyC, subject_reduction_type ; tea.
        now apply validity in HconvA.
      }
      pose proof (HconvA'' := HconvA').
      eapply red_ty_complete in HconvA'' as [? []]; tea.
      econstructor ; tea.
      1: now eapply redty_red.
      eapply IH ; tea.
      etransitivity ; tea.
      now eapply RedConvTyC.
    - intros * ? IHA ? IHB ? ? ? * ? HconvU ?.
      symmetry in HconvU.
      eapply red_ty_compl_univ_r, redty_red, red_whnf in HconvU as ->.
      2: gen_typing.
      destruct IHA as [IHA HconvA].
      econstructor ; fold_algo.
      + eapply IHA ; tea.
        do 2 econstructor.
        now eapply wf_conv_ctx.
      + eapply IHB ; tea.
        all: econstructor ; tea.
        1: econstructor ; fold_decl.
        2: do 2 econstructor ; fold_decl.
        2: now eapply wf_conv_ctx.
        all: eapply stability ; tea.
        all: econstructor.
        all: now eapply validity in HconvA as [].
    - intros * ? ? ? IHf ? ? ? * ? HconvP ?.
      symmetry in HconvP ; eapply red_ty_compl_prod_r in HconvP as (?&?&?&[HconvP]).
      eapply redty_red, red_whnf in HconvP as ->.
      2:gen_typing.
      econstructor ; fold_algo ; tea.
      eapply IHf.
      + econstructor ; tea.
        now symmetry.
      + symmetry.
        eapply stability ; tea.
        econstructor.
        2: now symmetry.
        now eapply ctx_conv_refl, wf_conv_ctx.
    - intros * ? IHm ? ? ? ? * ? HconvN HtyA'.
      edestruct IHm as [[? []] ?] ; tea.
      econstructor ; fold_algo ; tea.
      unshelve eapply ty_conv_inj in HconvN.
      1: now constructor.
      1: assumption.
      cbn in HconvN.
      destruct HtyA'.
      1-2: easy.
      assumption.
  Qed.

End AlgoConvConv.

Module AlgorithmicTypingProperties.
  Include AlgorithmicTypingData.

  #[export, refine] Instance WfCtxAlgProperties : WfContextProperties (ta := al) := {}.
  Proof.
    all: now constructor.
  Qed.

  #[export, refine] Instance WfTypeAlgProperties : WfTypeProperties (ta := al) := {}.
  Proof.
    2-4: now econstructor.
    intros.
    now eapply algo_typing_wk.
  Qed.

  #[export, refine] Instance InferringAlgProperties : InferringProperties (ta := al) := {}.
  Proof.
    - intros.
      now eapply algo_typing_wk.
    - now econstructor.
    - econstructor.
      all: now eapply infer_red_equiv.
    - now econstructor.
    - econstructor.
      1: now eapply infer_red_equiv.
      eassumption. 
  Qed.  

  #[export, refine] Instance TypingAlgProperties : TypingProperties (ta := al) := {}.
  Proof.
    - intros.
      now eapply algo_typing_wk.
    - intros.
      now econstructor.
    - intros * Hc ?.
      destruct Hc as [? ? ? ? ? Hc].
      destruct Hc.
      econstructor ; fold_algo ; tea.
      econstructor ; fold_algo.
      2: etransitivity.
      all: eassumption.
    - intros * Hc ?.
      destruct Hc.
      econstructor ; fold_algo ; tea.
      red.
      admit.
  Admitted.

  #[export, refine] Instance ConvTypeAlgProperties : ConvTypeProperties (ta := al) := {}.
  Proof.
  Admitted.

  #[export, refine] Instance ConvTermAlgProperties : ConvTermProperties (ta := al) := {}.
  Proof.
  Admitted.

  #[export, refine] Instance ConvNeuAlgProperties : ConvNeuProperties (ta := al) := {}.
  Proof.
  Admitted.

  Lemma RedTermAlgProperties :
    RedTermProperties (ta := al).
  Proof.
  Admitted.

  #[export]Existing Instance RedTermAlgProperties.

  Lemma RedTypeAlgProperties :
    RedTypeProperties (ta := al).
  Proof.
  Admitted.

  #[export] Existing Instance RedTypeAlgProperties.

  #[export] Instance AlgorithmicTypingProperties : GenericTypingProperties al _ _ _ _ _ _ _ _ _ := {}.

End AlgorithmicTypingProperties.