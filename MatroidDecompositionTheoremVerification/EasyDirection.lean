import Mathlib


abbrev Z2 : Type := Fin 2

variable {X Y : Type} [DecidableEq X] [DecidableEq Y]

/-- Binary prematroid generated by its standard representation matrix. -/
def Matrix.IndepCols (A : Matrix X Y Z2) (S : Set (X ⊕ Y)) : Prop :=
  LinearIndependent Z2 ((Matrix.fromColumns 1 A).submatrix id ((↑) : S → X ⊕ Y)).transpose

theorem Matrix.IndepCols_empty (A : Matrix X Y Z2) : A.IndepCols ∅ := by
  sorry

theorem Matrix.IndepCols_subset (A : Matrix X Y Z2) (I J : Set (X ⊕ Y)) (hAJ : A.IndepCols J) (hIJ : I ⊆ J) :
    A.IndepCols I := by
  sorry

theorem Matrix.IndepCols_aug (A : Matrix X Y Z2) (I B : Set (X ⊕ Y))
    (hAI : A.IndepCols I) (nonmax : ¬Maximal A.IndepCols I) (hAB : Maximal A.IndepCols B) :
    ∃ x ∈ B \ I, A.IndepCols (insert x I) := by
  sorry

theorem Matrix.IndepCols_maximal (A : Matrix X Y Z2) (S : Set (X ⊕ Y)) (hS : S ⊆ Set.univ) :
    Matroid.ExistsMaximalSubsetProperty A.IndepCols S := by
  sorry

/-- Binary matroid generated by its standard representation matrix. -/
def Matrix.toIndepMatroid (A : Matrix X Y Z2) : IndepMatroid (X ⊕ Y) where
  E := Set.univ
  Indep := A.IndepCols
  indep_empty := A.IndepCols_empty
  indep_subset := A.IndepCols_subset
  indep_aug := A.IndepCols_aug
  indep_maximal := A.IndepCols_maximal
  subset_ground := fun _ _ _ _ => trivial

structure BinaryMatroid (X Y : Type) [DecidableEq X] [DecidableEq Y]
  extends IndepMatroid (X ⊕ Y) where
    B : Matrix X Y Z2
    hB : B.toIndepMatroid = toIndepMatroid

def Matrix.TU (A : Matrix X Y ℚ) : Prop :=
  ∀ k : ℕ, ∀ f : Fin k → X, ∀ g : Fin k → Y,
    Function.Injective f → Function.Injective g →
      (A.submatrix f g).det = 0 ∨
      (A.submatrix f g).det = 1 ∨
      (A.submatrix f g).det = -1

structure RegularMatroid (X Y : Type) [DecidableEq X] [DecidableEq Y]
  extends BinaryMatroid X Y where
    A : Matrix X Y ℚ
    hA : (Matrix.fromColumns (1 : Matrix X X ℚ) A).TU
    hBA : ∀ i : X, ∀ j : Y, if B i j = 0 then A i j = 0 else A i j = 1 ∨ A i j = -1

def IndepMatroid.cast (M : IndepMatroid X) (hXY : X = Y) : IndepMatroid Y where
  E := hXY ▸ M.E
  Indep := hXY ▸ M.Indep
  indep_empty := by subst hXY; exact M.indep_empty
  indep_subset := by subst hXY; exact M.indep_subset
  indep_aug := by subst hXY; exact M.indep_aug
  indep_maximal := by subst hXY; exact M.indep_maximal
  subset_ground := by subst hXY; exact M.subset_ground

def IndepMatroid.mapEquiv (M : IndepMatroid X) (eXY : X ≃ Y) : IndepMatroid Y where
  E := eXY '' M.E
  Indep I := ∃ I₀, M.Indep I₀ ∧ I = eXY '' I₀
  indep_empty := ⟨∅, M.indep_empty, (Set.image_empty eXY).symm⟩
  indep_subset I J hI hJ := by
    refine ⟨eXY.symm '' I, ?_, (Equiv.eq_image_iff_symm_image_eq eXY _ I).mpr rfl⟩
    obtain ⟨I', hIJ⟩ := hI
    have := M.indep_subset (I := eXY.symm '' I) (J := eXY.symm '' J)
    simp_all
  indep_aug := by sorry
  indep_maximal I := by sorry
  subset_ground I hI := by have := M.subset_ground (eXY.symm '' I); aesop

variable {X₁ X₂ Y₁ Y₂ : Type} [DecidableEq X₁] [DecidableEq Y₁] [DecidableEq X₂] [DecidableEq Y₂]

def Matrix.OneSumComposition (A₁ : Matrix X₁ Y₁ Z2) (A₂ : Matrix X₂ Y₂ Z2) :
    Matrix (X₁ ⊕ X₂) (Y₁ ⊕ Y₂) Z2 :=
  Matrix.fromBlocks A₁ 0 0 A₂

def Matrix.TwoSumComposition (A₁ : Matrix X₁ Y₁ Z2) (x : Y₁ → Z2) (A₂ : Matrix X₂ Y₂ Z2) (y : X₂ → Z2) :
    Matrix (X₁ ⊕ X₂) (Y₁ ⊕ Y₂) Z2 :=
  Matrix.fromBlocks A₁ 0 (fun i j => y i * x j) A₂

noncomputable def Matrix.ThreeSumComposition (A₁ : Matrix X₁ (Y₁ ⊕ Fin 2) Z2) (A₂ : Matrix (Fin 2 ⊕ X₂) Y₂ Z2)
    (z₁ : Y₁ → Z2) (z₂ : X₂ → Z2)
    (D : Matrix (Fin 2) (Fin 2) Z2) [Invertible D] (D₁ : Matrix (Fin 2) Y₁ Z2) (D₂ : Matrix X₂ (Fin 2) Z2) :
    Matrix ((X₁ ⊕ Unit) ⊕ (Fin 2 ⊕ X₂)) ((Y₁ ⊕ Fin 2) ⊕ (Unit ⊕ Y₂)) Z2 :=
  let D₁₂ := D₂ * D⁻¹ * D₁
  Matrix.fromBlocks
    (Matrix.fromRows A₁ (Matrix.row Unit (Sum.elim z₁ ![1, 1]))) 0
    (Matrix.fromBlocks D₁ D D₁₂ D₂) (Matrix.fromColumns (Matrix.col Unit (Sum.elim ![1, 1] z₂)) A₂)

def BinaryMatroid.OneSum (M₁ : BinaryMatroid X₁ Y₁) (M₂ : BinaryMatroid X₂ Y₂) :
    IndepMatroid ((X₁ ⊕ X₂) ⊕ (Y₁ ⊕ Y₂)) :=
  (Matrix.OneSumComposition M₁.B M₂.B).toIndepMatroid -- TODO refactor to return `BinaryMatroid`

def BinaryMatroid.TwoSum (M₁ : BinaryMatroid (X₁ ⊕ Unit) Y₁) (M₂ : BinaryMatroid X₂ (Unit ⊕ Y₂)) :
    IndepMatroid ((X₁ ⊕ X₂) ⊕ (Y₁ ⊕ Y₂)) :=
  let B₁ := M₁.B
  let B₂ := M₂.B
  let A₁ : Matrix X₁ Y₁ Z2 := B₁ ∘ .inl -- the top submatrix
  let A₂ : Matrix X₂ Y₂ Z2 := (B₂ · ∘ .inr) -- the right submatrix
  let x : Y₁ → Z2 := (B₁ ∘ .inr) ()       -- makes sense only if `x ≠ 0`
  let y : X₂ → Z2 := ((B₂ · ∘ .inl) · ()) -- makes sense only if `y ≠ 0`
  (Matrix.TwoSumComposition A₁ x A₂ y).toIndepMatroid -- TODO refactor to return `BinaryMatroid`

def BinaryMatroid.ThreeSum
    (M₁ : BinaryMatroid ((X₁ ⊕ Unit) ⊕ Fin 2) ((Y₁ ⊕ Fin 2) ⊕ Unit))
    (M₂ : BinaryMatroid (Unit ⊕ (Fin 2 ⊕ X₂)) (Fin 2 ⊕ (Unit ⊕ Y₂))) :
    IndepMatroid (((X₁ ⊕ Unit) ⊕ (Fin 2 ⊕ X₂)) ⊕ ((Y₁ ⊕ Fin 2) ⊕ (Unit ⊕ Y₂))) :=
  let B₁ := M₁.B
  let B₂ := M₂.B
  let A₁ : Matrix X₁ (Y₁ ⊕ Fin 2) Z2 := ((B₁ ∘ .inl ∘ .inl) · ∘ .inl) -- the top left submatrix
  let A₂ : Matrix (Fin 2 ⊕ X₂) Y₂ Z2 := ((B₂ ∘ .inr) · ∘ .inr ∘ .inr) -- the bottom right submatrix
  let z₁ : Y₁ → Z2 := fun j => B₁ (.inl (.inr ())) (.inl (.inl j))
  let z₂ : X₂ → Z2 := fun i => B₂ (.inr (.inr i)) (.inr (.inl ()))
  let D : Matrix (Fin 2) (Fin 2) Z2 := fun i j => B₁ (.inr i) (.inl (.inr j)) -- the bottom middle 2x2 submatrix
  let D : Matrix (Fin 2) (Fin 2) Z2 := fun i j => B₂ (.inr (.inl i)) (.inl j) -- the middle left 2x2 submatrix
  -- TODO require both `D` are identical
  have : Invertible D := sorry -- TODO makes sense only if
  let D₁ : Matrix (Fin 2) Y₁ Z2 := fun i j => B₁ (.inr i) (.inl (.inl j)) -- the bottom left submatrix
  let D₂ : Matrix X₂ (Fin 2) Z2 := fun i j => B₂ (.inr (.inr i)) (.inl j) -- the bottom left submatrix
  (Matrix.ThreeSumComposition A₁ A₂ z₁ z₂ D D₁ D₂).toIndepMatroid -- TODO refactor to return `BinaryMatroid`

def BinaryMatroid.IsOneSum (M : BinaryMatroid X Y) (M₁ : BinaryMatroid X₁ Y₁) (M₂ : BinaryMatroid X₂ Y₂) : Prop :=
  ∃ eX : X ≃ (X₁ ⊕ X₂), ∃ eY : Y ≃ (Y₁ ⊕ Y₂),
    M.toIndepMatroid = (BinaryMatroid.OneSum M₁ M₂).mapEquiv (Equiv.sumCongr eX eY).symm

def BinaryMatroid.IsTwoSum (M : BinaryMatroid X Y) (M₁ : BinaryMatroid X₁ Y₁) (M₂ : BinaryMatroid X₂ Y₂) : Prop :=
  let B₁ := M₁.B
  let B₂ := M₂.B
  ∃ X' Y' : Type, ∃ _ : DecidableEq X', ∃ _ : DecidableEq Y',
    ∃ hX : X₁ = (X' ⊕ Unit), ∃ hY : Y₂ = (Unit ⊕ Y'), ∃ eX : X ≃ (X' ⊕ X₂), ∃ eY : Y ≃ (Y₁ ⊕ Y'),
      M.toIndepMatroid = IndepMatroid.mapEquiv (
        BinaryMatroid.TwoSum
          ⟨M₁.cast (congr_arg (· ⊕ Y₁) hX), hX ▸ B₁, by subst hX; convert M₁.hB⟩
          ⟨M₂.cast (congr_arg (X₂ ⊕ ·) hY), hY ▸ B₂, by subst hY; convert M₂.hB⟩
      ) (Equiv.sumCongr eX eY).symm ∧
      (hX ▸ B₁) (Sum.inr ()) ≠ (0 : Y₁ → Z2) ∧ (fun i : X₂ => (hY ▸ B₂ i) (Sum.inl ())) ≠ (0 : X₂ → Z2)

def BinaryMatroid.IsThreeSum (M : BinaryMatroid X Y) (M₁ : BinaryMatroid X₁ Y₁) (M₂ : BinaryMatroid X₂ Y₂) : Prop :=
  let B₁ := M₁.B
  let B₂ := M₂.B
  ∃ X₁' Y₁' : Type, ∃ _ : DecidableEq X₁', ∃ _ : DecidableEq Y₁',
  ∃ X₂' Y₂' : Type, ∃ _ : DecidableEq X₂', ∃ _ : DecidableEq Y₂',
    ∃ hX₁ : X₁ = ((X₁' ⊕ Unit) ⊕ Fin 2), ∃ hY₁ : Y₁ = ((Y₁' ⊕ Fin 2) ⊕ Unit),
    ∃ hX₂ : X₂ = (Unit ⊕ (Fin 2 ⊕ X₂')), ∃ hY₂ : Y₂ = (Fin 2 ⊕ (Unit ⊕ Y₂')),
      ∃ eX : X ≃ ((X₁' ⊕ Unit) ⊕ (Fin 2 ⊕ X₂')), ∃ eY : Y ≃ ((Y₁' ⊕ Fin 2) ⊕ (Unit ⊕ Y₂')),
        M.toIndepMatroid = IndepMatroid.mapEquiv (
          BinaryMatroid.ThreeSum
            ⟨M₁.cast (by subst hX₁ hY₁; rfl), hX₁ ▸ hY₁ ▸ B₁, (by subst hX₁ hY₁; convert M₁.hB)⟩
            ⟨M₂.cast (by subst hX₂ hY₂; rfl), hX₂ ▸ hY₂ ▸ B₂, (by subst hX₂ hY₂; convert M₂.hB)⟩
        ) (Equiv.sumCongr eX eY).symm ∧
        True ∧ -- TODO require `Invertible D`
        True -- TODO require consistency between
             -- the bottom middle 2x2 submatrix of `B₁` and the middle left 2x2 submatrix of `B₂`

noncomputable
def BinaryMatroid.IsOneSum.toRegular {M : BinaryMatroid X Y} {M₁ : RegularMatroid X₁ Y₁} {M₂ : RegularMatroid X₂ Y₂}
    (hM : M.IsOneSum M₁.toBinaryMatroid M₂.toBinaryMatroid) :
    RegularMatroid X Y where
  toBinaryMatroid := M
  A := sorry
  hA := sorry
  hBA := sorry

noncomputable
def BinaryMatroid.IsTwoSum.toRegular {M : BinaryMatroid X Y} {M₁ : RegularMatroid X₁ Y₁} {M₂ : RegularMatroid X₂ Y₂}
    (hM : M.IsTwoSum M₁.toBinaryMatroid M₂.toBinaryMatroid) :
    RegularMatroid X Y where
  toBinaryMatroid := M
  A := sorry
  hA := sorry
  hBA := sorry

noncomputable
def BinaryMatroid.IsThreeSum.toRegular {M : BinaryMatroid X Y} {M₁ : RegularMatroid X₁ Y₁} {M₂ : RegularMatroid X₂ Y₂}
    (hM : M.IsThreeSum M₁.toBinaryMatroid M₂.toBinaryMatroid) :
    RegularMatroid X Y where
  toBinaryMatroid := M
  A := sorry
  hA := sorry
  hBA := sorry
