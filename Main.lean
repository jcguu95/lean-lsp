import Mathlib.Tactic.Ring

def twice (x : Nat) : Nat :=
  x + x

theorem twice_twice (x : Nat) : twice (twice x) = 4 * x := by
  simp [twice]
  ring

def main : IO Unit :=
  IO.println s!"Hello, {twice 3}!"
