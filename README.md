# vm-setup.sh

Personal bootstrap script for quickly configuring CTF boxes, Kali VMs, and macOS with my preferred shell, vim, tmux, Go, and pentest tooling setup.

## One-command install

```bash
curl -fsSL https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/vm-setup.sh | bash -s -- --profile ctf
```

By default, the script prompts before making changes. On a throwaway box where you want it to run unattended:

```bash
curl -fsSL https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/vm-setup.sh | bash -s -- --profile ctf --yes
```

Preview what would happen without changing files:

```bash
curl -fsSL https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/vm-setup.sh | bash -s -- --profile full --dry-run
```

## Offline config install

If the target has no internet access, copy a zip of this repo to the box, unzip it, and run the config profile in offline mode:

```bash
unzip vm-setup.sh-main.zip
cd vm-setup.sh-main
bash vm-setup.sh --profile configs --offline
```

For unattended offline config installation:

```bash
bash vm-setup.sh --profile configs --offline --yes
```

`--offline` never fetches from GitHub. It only uses the `dotfiles/` directory next to `vm-setup.sh` and fails clearly if those files are missing.

## Profiles

- `configs`: install vim, tmux, aliases, functions, and bash/zsh source blocks only
- `ctf`: configs, base packages, Go, and the curated CTF tool set
- `full`: everything in `ctf` plus the larger tool set
- `mac`: macOS/Homebrew path for configs, base packages, Go, and the curated tool set

## Useful flags

```bash
--profile <configs|ctf|full|mac>
--only <configs,base,go,tools>
--yes
--dry-run
--offline
--backup-dir <path>
--source-url <url>
--tools-dir <path>
--force-go
--help
```

Examples:

```bash
# Just configs
./vm-setup.sh --profile configs

# Install only Go
./vm-setup.sh --only go

# Full local install without prompts
./vm-setup.sh --profile full --yes
```

## Safety behavior

- Existing dotfiles are backed up before replacement.
- Shell startup files are edited through managed blocks, so reruns do not duplicate entries.
- The installer configures bash and zsh, but never switches your shell and never runs `exec zsh`.
- Unsupported operating systems or package managers fail before install steps run.

## Local development

```bash
git clone https://github.com/intrudir/vm-setup.sh.git
cd vm-setup.sh
./vm-setup.sh --dry-run --profile ctf
```

Compatibility wrappers still exist:

```bash
./install-configs.sh
./install-golang.sh
./install-tools.sh -t ctf
```
