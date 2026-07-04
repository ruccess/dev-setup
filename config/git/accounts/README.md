# Git Account Templates

Actual account files are generated locally under:

```text
~/.config/dev-setup/git/accounts/
```

Run:

```zsh
git-account init
```

The generated files are included conditionally by directory, so each workspace folder can use its own Git identity without changing global config by hand.
