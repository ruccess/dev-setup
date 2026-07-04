---
name: dev-setup
description: Use this skill when working in the ruccess/dev-setup repository to install, extend, troubleshoot, or document a macOS developer environment with Homebrew sections, zsh aliases, Git account separation, Zellij/tmux workspaces, Claude Code, and Neovim starter profiles.
---

# dev-setup

이 repo는 macOS 개발 환경을 재현하기 위한 부트스트랩입니다. AI가 이 repo를 다룰 때는 먼저 이 파일을 읽고, 필요한 세부 내용은 [README.md](README.md)와 [docs/LEARN.md](docs/LEARN.md)를 확인합니다.

## 기본 원칙

- 사용자 언어는 한국어로 맞춥니다.
- 실제 설치, 계정 변경, SSH 설정 변경, push는 사용자가 명시적으로 요청했을 때만 실행합니다.
- 변경 전에는 `git status --short`를 확인하고, 사용자가 만든 변경을 되돌리지 않습니다.
- 패키지 추천이나 설치 방식처럼 최신성이 중요한 정보는 Homebrew 또는 공식 문서로 확인합니다.
- 비밀키는 절대 출력하지 않습니다. GitHub에 등록해야 할 때는 `.pub` 공개키만 보여주거나 클립보드에 복사합니다.
- `~/.config/nvim`은 자동으로 덮어쓰지 않습니다. Neovim 배포판은 `NVIM_APPNAME` 프로필로 분리해서 시험하게 합니다.

## 주요 파일

```text
install.sh                       설치/링크/선택형 Homebrew bootstrap
Brewfile                         전체 Homebrew catalog
docs/LEARN.md                    한국어 사용 설명서
config/zsh/dev-setup.zsh         zsh alias/function
config/zellij/dev.kdl            Zellij 개발 작업대 레이아웃
config/git/gitconfig             공통 Git 설정
scripts/git-accounts.sh          Git 계정/SSH alias 관리
scripts/neovim-profiles.sh       LazyVim/AstroNvim/NvChad 프로필 관리
scripts/doctor.sh                설치 상태 점검
```

## 설치 작업 흐름

먼저 dry-run을 실행합니다.

```zsh
./install.sh --dry-run
```

사용자가 실제 설치를 원하면 실행합니다.

```zsh
./install.sh
```

섹션만 고를 때는 목록을 먼저 보여줍니다.

```zsh
./install.sh --list-brew-groups
./install.sh --brew-groups apps,terminal,shell,modern,logs,code,git,workflow
```

설치 뒤 점검합니다.

```zsh
source ~/.zshrc
./scripts/doctor.sh
```

## Homebrew 섹션

핵심 추천 섹션:

```text
apps       Ghostty, Raycast, Nerd Font
terminal   Zellij, tmux
shell      starship, fzf, zoxide, atuin, mise, direnv
modern     eza, bat, fd, rg, jq, yq 등
logs       lnav, tailspin, btop, lazygit, yazi
code       neovim, ast-grep, shellcheck, shfmt 등
git        git-lfs, pre-commit, difftastic 등
workflow   gh, just, gum, hyperfine, xh
```

선택형 섹션:

```text
network, data, containers, cloud, security, media, runtimes, ai
```

`ai`에는 Claude Code cask가 포함됩니다. 필요할 때만 설치합니다.

## Git 계정 관리

Git 계정 분리는 `git-account` helper를 사용합니다.

```zsh
git-account init
git-account list
git-account current
```

이 머신의 대표 예시는 다음과 같습니다.

```text
ruccess -> ~/workspace/ruccess
welda   -> ~/workspace/welda
```

GitHub SSH 키:

```zsh
git-account key ruccess
git-account key welda
```

SSH remote는 계정별 host alias를 사용합니다.

```text
git@github.com-ruccess:ruccess/dev-setup.git
git@github.com-welda:welda/repo.git
```

push가 `Permission denied (publickey)`로 실패하면 `~/.ssh/id_ed25519_<account>.pub` 공개키를 GitHub 계정에 등록하도록 안내합니다.

## Zellij, tmux, Claude Code

권장 구조:

```text
Ghostty      터미널 앱
Zellij       탭/패널/레이아웃 작업대
Claude Code  AI 코딩 탭
Neovim       코드 편집
tmux         오래 돌릴 세션 또는 팀/서버 호환용
```

개발 작업대:

```zsh
zjd
```

`zjd`는 [config/zellij/dev.kdl](config/zellij/dev.kdl)을 열고 `code`, `claude`, `git`, `tmux`, `logs` 탭을 제공합니다.

## Neovim 프로필

Neovim 배포판은 `scripts/neovim-profiles.sh`로 분리 설치합니다.

```zsh
nvprof list
nvprof install lazyvim
nvl .
```

다른 프로필:

```zsh
nvprof install astronvim
nva .

nvprof install nvchad
nvc .
```

기본 추천은 LazyVim입니다. 사용자가 정착하겠다고 하기 전에는 프로필 폴더를 `~/.config/nvim`으로 옮기지 않습니다.

## 변경 검증

스크립트나 설정을 수정한 뒤에는 가능한 한 아래를 실행합니다.

```zsh
bash -n install.sh scripts/doctor.sh scripts/git-accounts.sh scripts/neovim-profiles.sh
zsh -n config/zsh/dev-setup.zsh
git diff --check
./install.sh --dry-run --brew-groups terminal,code,ai --skip-git-accounts
```

`brew bundle check --file Brewfile`은 Brewfile 문법 확인에는 유용하지만, 미설치 패키지가 있으면 실패하는 것이 정상입니다.

## 커밋과 푸시

사용자가 요청하면 커밋합니다.

```zsh
git add <files>
git commit -m "<message>"
```

push는 사용자가 요청했을 때만 시도합니다.

```zsh
git push origin main
```
