(* (c) Copyright Microsoft Corporation and Inria.                       *)
(* You may distribute this file under the terms of the CeCILL-B license *)
Require Import ssreflect ssrbool ssrfun eqtype ssrnat seq.
Require Import fintype.

Lemma test15: forall (y : nat) (x : 'I_2), y < 1 -> val x = y -> Some x = insub y.
move=> y x le_1 defx; rewrite insubT ?(leq_trans le_1) // => ?.
by congr (Some _); apply: val_inj=> /=; exact: defx.
Qed.

Axiom P : nat -> Prop.
Axiom Q : forall n, P n -> Prop.
Definition R := fun (x : nat) (p : P x) m (q : P (x+1)) => m > 0.

Inductive myEx : Type := ExI : forall n (pn : P n) pn', Q n pn -> R n pn n pn' -> myEx.

Variable P1 : P 1.
Variable P11 : P (1 + 1).
Variable Q1 : forall P1, Q 1 P1.

Lemma testmE1 : myEx.
Proof.
apply: ExI 1 _ _ _ _. 
  match goal with |- P 1 => exact: P1 | _ => fail end.
  match goal with |- P (1+1) => exact: P11 | _ => fail end.
  match goal with |- forall p : P 1, Q 1 p => move=>*; exact: Q1 | _ => fail end.
match goal with |- forall (p : P 1) (q : P (1+1)), is_true (R 1 p 1 q) => done | _ => fail end.
Qed.

Lemma testE2 : exists y : { x | P x }, sval y = 1.
Proof.
apply: ex_intro (exist _ 1 _) _.
  match goal with |- P 1 => exact: P1 | _ => fail end.
match goal with |- forall p : P 1, @sval _ _ (@exist _ _ 1 p) = 1 => done | _ => fail end.
Qed.

Lemma testE3 : exists y : { x | P x }, sval y = 1.
Proof.
have := (ex_intro _ (exist _ 1 _) _); apply.
  match goal with |- P 1 => exact: P1 | _ => fail end.
match goal with |- forall p : P 1, @sval _ _ (@exist _ _ 1 p) = 1 => done | _ => fail end.
Qed.

Lemma testE4 : P 2 -> exists y : { x | P x }, sval y = 2.
Proof.
move=> P2; apply: ex_intro (exist _ 2 _) _.
match goal with |- @sval _ _ (@exist _ _ 2 P2) = 2 => done | _ => fail end.
Qed.

Hint Resolve P1.

Lemma testmE12 : myEx.
Proof.
apply: ExI 1 _ _ _ _. 
  match goal with |- P (1+1) => exact: P11 | _ => fail end.
  match goal with |- Q 1 P1 => exact: Q1 | _ => fail end.
match goal with |- forall (q : P (1+1)), is_true (R 1 P1 1 q) => done | _ => fail end.
Qed.

Create HintDb SSR.

Hint Resolve P11 : SSR.

Ltac ssrautoprop := trivial with SSR.

Lemma testmE13 : myEx.
Proof.
apply: ExI 1 _ _ _ _. 
  match goal with |- Q 1 P1 => exact: Q1 | _ => fail end.
match goal with |- is_true (R 1 P1 1 P11) => done | _ => fail end.
Qed.

Definition R1 := fun (x : nat) (p : P x) m (q : P (x+1)) (r : Q x p) => m > 0.

Inductive myEx1 : Type := 
  ExI1 : forall n (pn : P n) pn' (q : Q n pn), R1 n pn n pn' q -> myEx1.

Hint Resolve (Q1 P1) : SSR.

(* tests that goals in prop are solved in the right order, propagating instantiations,
   thus the goal Q 1 ?p1 is faced by trivial after ?p1, and is thus evar free *)
Lemma testmE14 : myEx1.
Proof.
apply: ExI1 1 _ _ _ _.  
match goal with |- is_true (R1 1 P1 1 P11 (Q1 P1)) => done | _ => fail end.
Qed.

