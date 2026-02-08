def hello := "world"

-- A simple theorem
theorem test: 1 + 1 = 2 := by
  -- The only tactic necessary is `rfl`
  rfl

/-!
This is a doc comment.
-/
#check test

-- To see LSP output for this, put your cursor on the line below.
#eval 1 + 1
