
Require Export Iron.SystemF2Effect.Step.Frame.
Require Export Iron.SystemF2Effect.Store.Bind.
Require Export Iron.SystemF2Effect.Store.TypeB.
Require Export Iron.SystemF2Effect.Store.StoreT.
Require Export Iron.SystemF2Effect.Store.StoreM.
Require Export Iron.SystemF2Effect.Store.StoreP.


(* Well formed store. *)
Definition WfS  (se: stenv) (sp: stprops)  (ss: store)
 := Forall ClosedT se
 /\ STOREM se    ss
 /\ STORET se sp ss.
Hint Unfold WfS.


(* Well formed store and frame stack. *)
Definition WfFS (se : stenv) (sp : stprops) (ss : store) (fs : stack) 
 := Forall ClosedT se
 /\ STOREM se ss
 /\ STORET se sp ss
 /\ STOREP sp fs.


Lemma wfFS_wfS 
 :  forall se sp ss fs
 ,  WfFS   se sp ss fs
 -> WfS    se sp ss.
Proof. firstorder. Qed.


Lemma wfFS_fuse_sregion
 :  forall se sp ss fs p
 ,  WfFS se sp ss fs
 -> In (FUse p)    fs
 -> In (SRegion p) sp.
Proof. firstorder. Qed.


Lemma wfFS_storem_length
 :  forall se sp ss fs
 ,  WfFS   se sp ss fs
 -> length se = length ss.
Proof.
 intros.
 inverts H. rip.
Qed.
Hint Resolve wfFS_storem_length.


(*******************************************************************)
(* Creating a new region preserves well-formedness of the store. *)
Lemma wfFS_region_create
 :  forall se sp ss fs p
 ,  WfFS se sp ss fs
 -> WfFS se (SRegion p <: sp) ss (fs :> FUse p).
Proof. 
 intros.
 unfold WfFS. 
 inverts H. inverts H1. inverts H2.
 auto.
Qed.
Hint Resolve wfFS_region_create.


(********************************************************************)
(* Deallocating a region preserves well-formedness of the store. *)
Lemma typeb_deallocate
 :  forall ke te se sp p b t
 ,  TYPEB  ke te se sp b t
 -> TYPEB  ke te se sp (deallocate p b) t.
Proof.
 intros.
 destruct b.
 - snorm. subst.
   inverts H. eauto.
 - snorm.
Qed.


Lemma storet_deallocate
 :  forall se sp ss p
 ,  STORET se sp ss
 -> STORET se sp (map (deallocate p) ss).
Proof.
 intros.
 unfold STORET in *.
 eapply Forall2_map_left.
 eapply Forall2_impl.
  intros.
  eapply typeb_deallocate. eauto. auto.
Qed.


(* Deallocating the region mentioned in a use frame on the stop
   of the stack preserves the well formedness of the store. *)
Lemma wfFS_region_deallocate
 :  forall se sp ss fs p
 ,  WfFS se sp ss                     (fs :> FUse p)
 -> WfFS se sp (map (deallocate p) ss) fs.
Proof.
 intros.
 unfold WfFS in *. rip.
 - unfold STOREM in *.
   rewrite map_length. auto.

 - eapply storet_deallocate. auto.
 
 - unfold STOREP in *.
   snorm.
Qed.



(*******************************************************************)
(* Appending a closed store binding to the store preserves its 
   well formedness. *)
Lemma wfFS_stbind_snoc
 :  forall se sp ss fs p v t
 ,  KindT  nil sp (TCap (TyCapRegion p)) KRegion
 -> TYPEV  nil nil se sp v t
 -> WfFS           se sp ss fs
 -> WfFS   (TRef (TCap (TyCapRegion p)) t <: se) sp 
           (StValue p v <: ss) fs.
Proof.
 intros.
 unfold WfFS.
 inverts H1. rip.
 snorm.
 rrwrite ( TRef (TCap (TyCapRegion p)) t <: se
        = (TRef (TCap (TyCapRegion p)) t <: nil) >< se) in H4.
 apply in_app_split in H4.
 inverts H4.
 - snorm.
 - snorm.
   inverts H6.
   + have (ClosedT t).
     have (ClosedT (TCap (TyCapRegion p))).
     eauto.
   + nope.
Qed.
Hint Resolve wfFS_stbind_snoc.


(* Updating bindings *********************************************************)
(* Store with an updated binding is still well formed. *)
Lemma wfFS_stbind_update
 :  forall se sp ss fs l p v t
 ,  get l se = Some (TRef (TCap (TyCapRegion p)) t)
 -> KindT nil sp (TCap (TyCapRegion p)) KRegion
 -> TYPEV nil nil se sp v t
 -> WfFS se sp ss fs
 -> WfFS se sp (update l (StValue p v) ss) fs.
Proof.
 intros se sp ss fs l p v t HG HK HV HWF1.
 inverts HWF1. rip.
 - have (length se = length ss).
   unfold STOREM.
   rewritess.
   rewrite update_length. auto.
 - unfold STORET.
   eapply Forall2_update_right; eauto.
Qed.



