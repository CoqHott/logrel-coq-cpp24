From Coq Require Import Lia.
From LogRel.AutoSubst Require Import core unscoped Ast.
From LogRel Require Import Utils BasicAst Notations Context Untyped.

Inductive weakening : Set :=
  | _wk_empty : weakening
  | _wk_step (w : weakening) : weakening
  | _wk_up (w : weakening) : weakening.

Fixpoint _wk_id (Γ : context) : weakening :=
  match Γ with
    | nil => _wk_empty
    | cons _ Γ' => _wk_up (_wk_id Γ')
  end.

(* Transforms an (intentional) weakening into a renaming *)
Fixpoint wk_to_ren (ρ : weakening) : nat -> nat :=
  match ρ with
    | _wk_empty => id
    | _wk_step ρ' => (wk_to_ren ρ') >> S
    | _wk_up ρ' => up_ren (wk_to_ren ρ')
  end.

Lemma wk_to_ren_id Γ : (wk_to_ren (_wk_id Γ)) =1 id.
Proof.
  induction Γ.
  1: reflexivity.
  intros [] ; cbn.
  2: rewrite IHΓ.
  all: reflexivity.
Qed.

Coercion wk_to_ren : weakening >-> Funclass.

#[global] Instance RenWk_term : (Ren1 weakening term term) :=
  fun ρ t => ren_term (wk_to_ren ρ) t.

Arguments RenWk_term /.

#[global] Instance RenWk_subst : (Ren1 weakening (nat -> term) (nat -> term)) :=
  fun ρ σ i => (σ i) ⟨ ρ ⟩.

Arguments RenWk_subst /.


Inductive well_weakening : weakening -> context -> context -> Type :=
  | well_empty : well_weakening _wk_empty ε ε
  | well_step {Γ Δ : context} (na : aname) (A : term) (ρ : weakening) :
    well_weakening ρ Γ Δ -> well_weakening (_wk_step ρ) (Γ,,vass na A) Δ
  | well_up {Γ Δ : context} (na : aname) (A : term) (ρ : weakening) :
    well_weakening ρ Γ Δ -> well_weakening (_wk_up ρ) (Γ,,vass na (ren_term ρ A)) (Δ,, vass na A).

Lemma well_wk_id (Γ : context) : well_weakening (_wk_id Γ) Γ Γ.
Proof.
  induction Γ as [|d].
  1: econstructor.
  replace d with (d⟨wk_to_ren (_wk_id Γ)⟩) at 2.
  all: destruct d as [na A].
  1: now econstructor.
  cbn.
  f_equal.
  rewrite wk_to_ren_id.
  now asimpl.
Qed.

Fixpoint wk_compose (ρ ρ' : weakening) : weakening :=
  match ρ, ρ' with
    | _wk_empty , _ => ρ'
    | _wk_step ν , _ => _wk_step (wk_compose ν ρ')
    | _wk_up ν, _wk_empty => ρ
    | _wk_up ν, _wk_step ν' => _wk_step (wk_compose ν ν')
    | _wk_up ν, _wk_up ν' => _wk_up (wk_compose ν ν')
  end.

Lemma wk_compose_compose (ρ ρ' : weakening) : wk_to_ren (wk_compose ρ ρ') =1 ρ' >> ρ.
Proof.
  induction ρ in ρ' |- *.
  - reflexivity.
  - cbn.
    rewrite IHρ.
    now fsimpl.
  - destruct ρ'.
    + reflexivity.
    + cbn.
      rewrite IHρ.
      now asimpl.
    + cbn.
      asimpl.
      rewrite IHρ.
      now asimpl.
Qed.

Lemma well_wk_compose {ρ ρ' : weakening} {Δ Δ' Δ'' : context} :
  well_weakening ρ Δ Δ' -> well_weakening ρ' Δ' Δ'' -> well_weakening (wk_compose ρ ρ') Δ Δ''.
Proof.
  intros H H'.
  induction H as [| | ? ? ? ? ν] in ρ', Δ'', H' |- *.
  all: cbn.
  - eassumption.
  - econstructor. auto.
  - inversion H' as [| | ? ? na' A' ν']; subst ; clear H'.
    1: now econstructor ; auto.
    asimpl.
    replace (ren_term (ν' >> ν) A') with (ren_term (wk_compose ν ν') A')
      by now rewrite wk_compose_compose.
    econstructor ; auto.
Qed.

#[projections(primitive)]Record wk_well_wk {Γ Δ : context} :=
  { wk :> weakening ; well_wk :> well_weakening wk Γ Δ}.
Arguments wk_well_wk : clear implicits.
Arguments Build_wk_well_wk : clear implicits.
Notation "Γ ≤ Δ" := (wk_well_wk Γ Δ).

Definition wk_empty : (ε ≤ ε) := {| wk := _wk_empty ; well_wk := well_empty |}.

Definition wk_step {Γ Δ} na A (ρ : Γ ≤ Δ) : (Γ,, vass na A) ≤ Δ :=
  {| wk := _wk_step ρ ; well_wk := well_step na A ρ ρ |}.

Definition wk_up {Γ Δ} na A (ρ : Γ ≤ Δ) : (Γ,, vass na A⟨wk_to_ren ρ⟩) ≤ (Δ ,, vass na A) :=
  {| wk := _wk_up ρ ; well_wk := well_up na A ρ ρ |}.

Definition wk_id {Γ} : Γ ≤ Γ :=
  {| wk := _wk_id Γ ; well_wk := well_wk_id Γ |}.

#[global] Hint Resolve well_wk : core.

#[global] Instance RenWlWk_term {Γ Δ : context }: (Ren1 (Γ ≤ Δ) term term) :=
  fun ρ t => ren_term (wk_to_ren ρ.(wk)) t.

Arguments RenWlWk_term /.

#[global] Instance RenWlWk_subst {Γ Δ : context }: (Ren1 (Γ ≤ Δ) (nat -> term) (nat -> term)) :=
  fun ρ σ i => ren_term (wk_to_ren ρ.(wk)) (σ i).

Arguments RenWlWk_subst /.

Definition wk_well_wk_compose {Γ Γ' Γ'' : context} (ρ : Γ ≤ Γ') (ρ' : Γ' ≤ Γ'') : Γ ≤ Γ'' :=
  {| wk := wk_compose ρ.(wk) ρ'.(wk) ; well_wk := well_wk_compose ρ.(well_wk) ρ'.(well_wk) |}.
Notation "ρ ∘w ρ'" := (wk_well_wk_compose ρ ρ').

Lemma well_length {Γ Δ : context} (ρ : Γ ≤ Δ) : #|Δ| <= #|Γ|.
Proof.
  destruct ρ as [ρ wellρ].
  induction wellρ.
  all: cbn ; lia.
Qed.

(* Testing that the definitions are right *)
Lemma id_ren (Γ : context) (ρ : Γ ≤ Γ) : ρ =1 id.
Proof.
  destruct ρ as [ρ wellρ].
  cbn in *.
  pose proof (@eq_refl _ #|Γ|) as eΓ.
  revert eΓ wellρ.
  generalize Γ at 2 4.
  intros Δ e wellρ.
  induction wellρ in e |- *.
  all: cbn.
  - reflexivity.
  - pose proof (well_length {| wk := ρ ; well_wk := wellρ |}).
    now cbn in * ; lia.
  - asimpl.
    setoid_rewrite IHwellρ.
    2: now cbn in * ; lia.
    now intros [] ; reflexivity.
Qed.


Definition wk1 {Γ} nA A := wk_step nA A (@wk_id Γ).

Lemma wk1_ren {Γ nA A} : @wk1 Γ nA A =1 ↑.
Proof.
  intros ?; cbv -[wk_to_ren _wk_id]. cbn. 
  rewrite (id_ren Γ (@wk_id Γ)). reflexivity.
Qed.

Lemma map_decl_lift (ρ : weakening) d :
  map_decl (ren_term (up_ren ρ)) (map_decl (ren_term shift) d) =
  map_decl (ren_term shift) (map_decl (ren_term ρ) d).
Proof.
  rewrite ! compose_map_decl.
  eapply map_decl_ext.
  intros t.
  asimpl.
  reflexivity.
Qed.

Lemma in_ctx_wk (Γ Δ : context) n decl (ρ : Δ ≤ Γ) :
  in_ctx Γ n decl ->
  in_ctx Δ (ρ n) (map_decl (ren_term ρ) decl).
Proof.
  intros Hdecl.
  destruct ρ as [ρ wfρ] ; cbn.
  induction wfρ in n, decl, Hdecl |- *.
  - cbn.
    rewrite map_decl_id.
    1: eassumption.
    now asimpl.
  - cbn.
    change ((ρ >> S) n) with (S (ρ n)).
    replace (map_decl _ _) with (map_decl (ren_term shift) (map_decl (ren_term ρ) decl))
      by (now rewrite compose_map_decl ; asimpl).
    now econstructor.
  - destruct n ; cbn.
    + cbn.
      inversion Hdecl ; subst ; clear Hdecl.
      cbn -[map_decl].
      rewrite map_decl_lift.
      now constructor.
    + inversion Hdecl ; subst ; cbn in *.
      rewrite map_decl_lift.
      now econstructor.
  Qed.

Section RenWhnf.

  Variable (ρ : nat -> nat).

  Lemma whne_ren t : whne t -> whne (ren_term ρ t).
  Proof.
    induction 1 ; cbn.
    all: now econstructor.
  Qed.

  Lemma whnf_ren t : whnf t -> whnf (ren_term ρ t).
  Proof.
    induction 1 ; cbn.
    all: econstructor.
    now eapply whne_ren.
  Qed.
  
  Lemma isType_ren A : isType A -> isType (ren_term ρ A).
  Proof.
    induction 1 ; cbn.
    all: econstructor.
    now eapply whne_ren.
  Qed.
  
  Lemma isFun_ren f : isFun f -> isFun (ren_term ρ f).
  Proof.
    induction 1 ; cbn.
    all: econstructor.
    now eapply whne_ren.
  Qed.

End RenWhnf.

#[global] Hint Resolve whne_ren whnf_ren isType_ren isFun_ren : gen_typing.

