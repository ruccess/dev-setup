# Git Account Templates

Actual account files are generated locally under:

```text
~/.config/dev-setup/git/accounts/
```

Run:

```zsh
git-account init
```

The generated files are included conditionally by directory, so Welda repos and Ruccess repos can use different Git identities without changing global config by hand.
