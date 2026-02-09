import Mathlib.Data.Nat.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Algebra.BigOperators.Basic

open BigOperators -- to use ∑ notation

theorem sum_of_first_n_odd_numbers (n : ℕ) :
  ∑ i in Finset.range n, (2 * i + 1) = n * n := by
  induction n with
  | zero => simp
  | succ k ih =>
    rw [Finset.sum_range_succ, ih]
    ring
