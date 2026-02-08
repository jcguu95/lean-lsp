import Lake
open Lake DSL

package «lean_project» where
  -- Settings applied to both builds and interactive editing
  leanOptions := #[
    ⟨`pp.unicode.fun, true⟩, -- pretty-prints `fun a ↦ b`
    ⟨`pp.proofs.withType, false⟩
  ]
  -- add package configuration options here

@[default_target]
lean_lib «LeanProject» where
  -- add library configuration options here
