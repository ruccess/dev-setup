---
name: dev-setup
description: Use this skill when working in a dev-setup repository to install, extend, troubleshoot, or document a generic macOS developer environment with Homebrew sections, zsh aliases, Git account separation, Zellij/tmux workspaces, Claude Code, GitHub CLI, and Neovim starter profiles.
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

## 가이드 설치 모드

사용자가 "같이 설치", "하나하나 설치", "세팅해줘", "처음부터 잡아줘"처럼 말하면 가이드 설치 모드로 진행합니다.

- 한 번에 최종 설치 명령만 던지고 멈추지 않습니다.
- AI는 페어 셋업 도우미처럼 현재 단계, 실행한 명령, 결과, 다음 선택지를 짧게 설명합니다.
- 먼저 전체 체크리스트를 만들고, 단계가 끝날 때마다 완료/진행 상태를 갱신합니다.
- 명령은 작은 단위로 실행합니다. 한 단계가 끝나면 결과를 요약하고 다음 단계로 넘어갑니다.
- 조회 명령은 적극적으로 실행해도 됩니다. 예: `git status --short`, `brew --version`, `./install.sh --dry-run`, `./install.sh --list-tools`, `./scripts/doctor.sh`
- 실제 설치, shell 링크, Git 계정 설정, SSH 키 생성, remote 변경, push처럼 사용자 환경을 바꾸는 단계는 각 단계마다 명시적인 승인을 받습니다.
- 사용자가 선택을 어려워하면 추천안을 먼저 제시하되, 선택지는 3개 안팎으로 줄입니다.

가이드 설치의 기본 단계:

```text
1. 현황 확인
   git status, Homebrew/Git 존재 여부, dry-run, doctor
2. 설치 범위 선택
   추천 기본 묶음, AI 개발 묶음, 섹션별 커스텀 중 선택
3. Homebrew 도구 설치
   선택한 섹션만 실제 설치
4. shell/helper 링크
   zsh alias, dev-setup 메뉴, git-account, nvim-profile, zellij layout
5. runtime 초기화
   mise로 Node/Python 기본 버전 설정
6. AI/GitHub 로그인
   claude, gh auth login
7. Git 계정 분리
   personal/work 같은 계정 이름과 workspace 경로 확인 후 git-account init
8. 선택 기능
   Neovim 프로필, Zellij/tmux 작업대, GitHub remote alias
9. 최종 점검
   doctor, 버전 확인, 남은 수동 작업 요약
```

다음 단계가 환경을 바꾸는 작업이면 이런 식으로 멈춰서 확인합니다.

```text
다음 단계는 Homebrew 도구 실제 설치입니다.
선택한 섹션은 apps,terminal,shell,modern,logs,code,git,ai-dev,workflow 입니다.
실행해도 될까요?
```

## 주요 파일

```text
.env.example                    로컬 기본값 예시
install.sh                       설치/링크/선택형 Homebrew bootstrap
menu.sh                          루트 메뉴 wrapper
Brewfile                         전체 Homebrew catalog
docs/LEARN.md                    한국어 사용 설명서
config/zsh/dev-setup.zsh         zsh alias/function
config/zellij/dev.kdl            Zellij 개발 작업대 레이아웃
config/git/gitconfig             공통 Git 설정
scripts/git-accounts.sh          Git 계정/SSH alias 관리
scripts/neovim-profiles.sh       LazyVim/AstroNvim/NvChad 프로필 관리
scripts/menu.sh                  설치/점검/스크립트 선택 메뉴
scripts/doctor.sh                설치 상태 점검
```

## 설치 작업 흐름

사용자가 명령어 선택을 어려워하면 메뉴부터 실행합니다.

```zsh
./menu.sh
```

사용자가 계정 이름이나 workspace 기본값을 바꾸고 싶어하면 `.env.example`을 `.env`로 복사해서 수정하게 안내합니다. `.env`는 Git에 올리지 않습니다.

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
./install.sh --list-tools
./install.sh --brew-groups apps,terminal,shell,modern,logs,code,git,ai-dev,workflow
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
ai-dev     Claude Code, bun, pnpm, uv, gh, rg, fd, jq 등
workflow   gh, just, gum, hyperfine, xh
```

선택형 섹션:

```text
network, data, containers, cloud, security, media, runtimes, ai
```

`ai`에는 Claude Code cask가 포함됩니다. 필요할 때만 설치합니다.

도구 설명이나 추천 여부를 물으면 `./install.sh --list-tools`를 먼저 확인합니다.

AI와 함께 코딩하는 기본값을 물으면 `ai-dev`를 추천합니다. 이 섹션은 Claude Code, bun, pnpm, uv, mise, gh, rg/fd/jq, ast-grep, gitleaks, pre-commit, just를 한 묶음으로 설치합니다. `pnpm`을 쓰려면 Node가 필요하므로 설치 후 `mise use --global node@lts`를 안내합니다.

## Git 계정 관리

Git 계정 분리는 `git-account` helper를 사용합니다.

```zsh
git-account init
git-account list
git-account current
```

대표 예시는 다음과 같습니다.

```text
personal -> ~/workspace/personal
work     -> ~/workspace/work
```

GitHub SSH 키:

```zsh
git-account key personal
git-account key work
```

SSH remote는 계정별 host alias를 사용합니다.

```text
git@github.com-personal:<github-user>/dev-setup.git
git@github.com-work:<org-or-user>/repo.git
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
bash -n menu.sh scripts/menu.sh
zsh -n config/zsh/dev-setup.zsh
git diff --check
./install.sh --dry-run --brew-groups terminal,code,ai-dev,ai --skip-git-accounts
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
