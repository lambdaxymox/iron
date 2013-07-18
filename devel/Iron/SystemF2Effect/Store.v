
Require Export Iron.SystemF2Effect.Store.Wf.
Require Export Iron.SystemF2Effect.Store.TypeB.
Require Export Iron.SystemF2Effect.Store.StoreT.
Require Export Iron.SystemF2Effect.Store.LiveE.
Require Export Iron.SystemF2Effect.Store.LiveS.


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
