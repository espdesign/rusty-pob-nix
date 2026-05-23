# rusty-pob-nix

Nix flake for [rusty-path-of-building](https://github.com/meehl/rusty-path-of-building) — an offline build planner for Path of Exile.

## Usage

### Run directly

```bash
# Path of Exile 1
nix run github:espdesign/rusty-pob-nix -- poe1

# Path of Exile 2
nix run github:espdesign/rusty-pob-nix -- poe2
```

### Run with custom branches, commits, or directories

You can run Path of Building with custom branches, commit hashes, or local folders:

```bash
# Run with a specific commit hash (downloads to a separate directory, blocks auto-updates)
nix run github:espdesign/rusty-pob-nix -- poe2 --branch f0ed15fd4e80dba1c276c4fde2e841ced21babc0

# Run with a branch name (e.g. dev)
nix run github:espdesign/rusty-pob-nix -- poe2 --branch dev

# Force redownload/reinstall of the specified branch or version
nix run github:espdesign/rusty-pob-nix -- poe2 --branch dev --force-install

# Run using a local directory containing POB's Launch.lua
nix run github:espdesign/rusty-pob-nix -- poe2 --pob-dir /path/to/local/pob
```

### Install to a NixOS/system configuration

```nix
{
  inputs = {
    rusty-pob-nix.url = "github:espdesign/rusty-pob-nix";
  };
  # then add rusty-pob-nix.packages.${system}.default to environment.systemPackages
}
```

Once installed, launch via `rusty-path-of-building poe1` or `rusty-path-of-building poe2`.

## Maintenance

### Automated updates (Renovate)

- **rusty-path-of-building** — checked hourly
- **nixpkgs**, **crane**, **flake-utils** — checked weekly (Monday before 9am)

Renovate opens a PR bumping `flake.lock` when newer commits are found. CI runs `nix flake check` + `nix build` on every PR. Merge if it passes.

### Manual updates

```bash
nix flake update rusty-path-of-building  # single input
nix flake update                         # all inputs
```

### If a PR breaks

- **rusty-path-of-building** — upstream may have changed files or dependencies; update `flake.nix` build inputs accordingly
- **nixpkgs / crane** — temporarily pin to a known-good revision by adding a `ref` in `flake.nix`, e.g. `github:NixOS/nixpkgs/<known-good-rev>`

### Updating or fixing patches (when upstream changes break the build)

If the upstream repository changes in a way that prevents the wrapper patch (`patches/branch-run-flag.patch`) from applying, the Nix build will fail with a failed hunk or malformed patch error.

To resolve and update the patch file:

1. **Clone the upstream repository**:
   ```bash
   git clone https://github.com/meehl/rusty-path-of-building.git
   cd rusty-path-of-building
   ```

2. **Apply the patch manually**, telling Git to reject hunks it cannot merge:
   ```bash
   git apply --reject /path/to/rusty-pob-nix/patches/branch-run-flag.patch
   ```

3. **Resolve conflict rejects**:
   For any hunks that fail to apply, Git will generate a `.rej` file (e.g., `src/app.rs.rej`). Open these files and manually port the rejected changes into the source files.

4. **Regenerate the patch**:
   Once all files are updated and compiling, recreate the patch file in your local flake directory:
   ```bash
   git diff > /path/to/rusty-pob-nix/patches/branch-run-flag.patch
   ```

5. **Test the build**:
   Verify that it now builds correctly in the flake directory:
   ```bash
   nix build
   ```

## Attribution

This flake wraps **rusty-path-of-building** ([github.com/meehl/rusty-path-of-building](https://github.com/meehl/rusty-path-of-building)), which is licensed under the [MIT License](https://github.com/meehl/rusty-path-of-building/blob/main/LICENSE).
