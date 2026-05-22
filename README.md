# rusty-pob-nix

Nix flake for [rusty-path-of-building](https://github.com/meehl/rusty-path-of-building) — an offline build planner for Path of Exile.

## Usage

```bash
nix build github:espdesign/rusty-pob-nix
```

Or add to your flake inputs:

```nix
rusty-pob-nix.url = "github:espdesign/rusty-pob-nix";
```

## Maintenance

### Automated updates (Renovate)

- **rusty-path-of-building** — checked hourly
- **nixpkgs**, **crane**, **flake-utils** — checked weekly (Monday before 9am)

Renovate opens a PR bumping `flake.lock` when newer commits are found. CI runs `nix flake check` on every PR. Merge if it passes.

### Manual updates

```bash
nix flake update rusty-path-of-building  # single input
nix flake update                         # all inputs
```

### If a PR breaks

- **rusty-path-of-building** — upstream may have changed files or dependencies; update `flake.nix` build inputs accordingly
- **nixpkgs / crane** — temporarily pin to a known-good revision by adding a `ref` in `flake.nix`, e.g. `github:NixOS/nixpkgs/<known-good-rev>`

## Attribution

This flake wraps **rusty-path-of-building** ([github.com/meehl/rusty-path-of-building](https://github.com/meehl/rusty-path-of-building)), which is licensed under the [MIT License](https://github.com/meehl/rusty-path-of-building/blob/main/LICENSE).
