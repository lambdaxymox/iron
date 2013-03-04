
Require Export Iron.SystemF2Effect.Store.Wf.


(* Reading bindings **********************************************************)
(* Values read from the store have the types predicted by
   the store environment *)
Lemma storet_get_typev
 :  forall se sp ss ix r v t
 ,  STORET se sp ss
 -> get ix se = Some (TRef (TCap (TyCapRegion r)) t)
 -> get ix ss = Some (StValue r v)
 -> TYPEV nil nil se sp v t.
Proof.
 intros.
 unfold STORET in *.
 lets D: (@Forall2_get_get_same stbind ty) H1 H0. eauto.
 inverts D. auto.
Qed.


(* Updating bindings *********************************************************)
(* Store with an updated binding is still well formed. *)
Lemma store_update_wf
 :  forall se sp ss l r v t
 ,  WfS se sp ss
 -> get l se = Some (TRef (TCap (TyCapRegion r)) t)
 -> TYPEV nil nil se sp v t
 -> WfS se sp (update l (StValue r v) ss).
Proof.
 intros se sp ss l r v t HWF1 HG HV.
 inverts HWF1. rip.
  have (length se = length ss).
   unfold STOREM.
   rewritess.
   rewrite update_length. auto.
  unfold STORET.
   eapply Forall2_update_right; eauto.
Qed.

