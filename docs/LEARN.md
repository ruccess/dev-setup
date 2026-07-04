# dev-setup 사용 설명서

이 파일은 내 개발 환경을 다시 기억하기 위한 치트시트입니다.

터미널에서 언제든 열 수 있습니다:

```zsh
dh
devhelp
```

이 파일을 바로 수정하려면:

```zsh
devhelp-edit
```

이 설정 repo로 이동하려면:

```zsh
devrepo
```

## 먼저 알아둘 것

아직 `Brewfile`에 적힌 앱과 CLI 도구들이 전부 설치된 것은 아닙니다.

실제로 설치되는 시점은 이 명령을 실행할 때입니다:

```zsh
./install.sh
```

설치 전에 어떤 일이 일어날지 미리 보고 싶으면:

```zsh
./install.sh --dry-run
```

설치할 도구 섹션을 직접 고르고 싶으면:

```zsh
./install.sh --list-brew-groups
./install.sh --brew-groups apps,terminal,shell,modern
```

전부 설치하려면:

```zsh
./install.sh --all-brew
```

추천 도구 설치 목록만 비우려면:

```zsh
./install.sh --brew-groups none
```

Homebrew 관련 작업 자체를 건너뛰고 설정만 적용하려면:

```zsh
./install.sh --skip-brew
```

현재 이 repo가 하는 일은 크게 네 가지입니다:

1. Homebrew로 설치할 앱과 CLI 도구 목록을 관리합니다.
2. zsh, starship, git 설정을 링크합니다.
3. Zellij 작업대 레이아웃과 Neovim 프로필 도우미를 제공합니다.
4. Git 계정별 폴더와 SSH 설정을 입력받아 분리해서 관리합니다.

## 처음 실행

기본 설치:

```zsh
cd path/to/dev-setup
./install.sh
source ~/.zshrc
./scripts/doctor.sh
```

내 현재 로컬 경로 예시는:

```zsh
cd ~/workspace/ruccess/dev-setup
```

설치 중 Git 계정 설정을 바로 진행할 수도 있습니다.

```zsh
./install.sh --git-accounts
```

이때 아래 내용을 물어봅니다:

```text
Workspace root              예: ~/workspace
Number of Git accounts      예: 2
Account id                  예: ruccess, welda
Git name                    커밋 작성자 이름
Git email                   커밋 작성자 이메일
GitHub username/org login   GitHub 사용자명 또는 조직명
Repo directory              해당 계정 repo들을 모아둘 폴더
```

앱 설치 없이 CLI와 설정만 보고 싶으면:

```zsh
./install.sh --no-casks
```

Homebrew 설치를 건너뛰고 설정만 적용하려면:

```zsh
./install.sh --skip-brew
```

설치 후 새 터미널을 열거나 아래 명령을 실행합니다:

```zsh
source ~/.zshrc
```

## 설치되는 앱

`Brewfile` 기준으로 아래 앱들이 설치됩니다.

```text
ghostty                         터미널 앱
raycast                         Spotlight 대체 런처
font-jetbrains-mono-nerd-font   터미널용 Nerd Font
```

내 추천 기본 조합은:

```text
Ghostty + Raycast + zsh + Starship + fzf + zoxide + atuin
```

## 설치 묶음 선택

`./install.sh`를 대화형으로 실행하면 섹션을 하나씩 보여줍니다.

각 섹션에서 선택할 수 있는 값:

```text
Enter  기본값 선택
r      추천 도구 설치
a      섹션 전체 설치
n      이 섹션 건너뛰기
c      도구별로 하나씩 선택
```

섹션 목록:

```text
apps        앱: Ghostty, Raycast, JetBrains Mono Nerd Font
terminal    터미널 작업대: zellij, tmux
shell       쉘 사용감: starship, fzf, zoxide, atuin, mise, direnv
modern      기본 명령어 대체: eza, bat, fd, rg, jq/yq, disk helpers
logs        로그/TUI: lnav, tailspin, btop, lazygit, yazi
code        코드 편집/품질: neovim, ast-grep, shellcheck, shfmt, actionlint
git         Git 확장: git-lfs, pre-commit, difftastic, git-filter-repo
network     네트워크: wget, doggo, gping, mtr, iperf3, nmap, trippy
data        데이터 처리: duckdb, sqlite, miller, xsv, jless, fx, visidata
containers  Docker/Kubernetes: docker, colima, lazydocker, kubectl, helm, k9s
cloud       클라우드/IaC: awscli, azure-cli, google-cloud-sdk, doctl, opentofu
security    보안: gitleaks, trufflehog, age, sops, syft, grype
media       미디어/문서: ffmpeg, imagemagick, pandoc, poppler, sevenzip
runtimes    런타임 보조: uv, bun, pnpm, deno
ai          AI CLI: Claude Code, ollama, llm, aichat, mods
workflow    워크플로우: gh, just, gum, hyperfine, xh
```

기본값은 핵심 섹션만 `r`입니다. `network`, `data`, `containers`, `cloud`, `security`, `media`, `runtimes`, `ai`는 취향과 업무 환경을 많이 타서 기본값이 `n`입니다.

예시:

```zsh
./install.sh --brew-groups apps,terminal,shell,modern,logs,code,git,workflow
```

Docker/Kubernetes를 안 쓰면 `containers`는 빼도 됩니다. AI 도구나 클라우드 CLI도 필요한 사람만 고르면 됩니다.

## 설치되는 CLI 도구

터미널 작업대를 만드는 도구:

```text
zellij     터미널 탭/패널/레이아웃 작업대
tmux       오래 검증된 터미널 세션/창/패널 관리
```

쉘 사용감을 좋게 만드는 도구:

```text
starship    프롬프트를 예쁘고 빠르게 표시
fzf         fuzzy finder, 목록에서 빠르게 검색/선택
zoxide      자주 가는 폴더를 기억하는 똑똑한 cd
atuin       터미널 명령 기록 검색
mise        Node/Python/Go/Rust 같은 런타임 버전 관리
direnv      프로젝트 폴더에 들어갈 때 환경변수 자동 로드
```

기본 Unix 명령어를 더 편하게 바꿔주는 도구:

```text
eza         ls 대체
bat         cat 대체, 코드 하이라이트 지원
fd          find 대체
ripgrep     grep 대체, 명령어는 rg
sd          sed보다 단순한 문자열 치환 도구
jq          JSON 처리
yq          YAML/JSON/XML 처리
dust        디스크 사용량 보기
duf         디스크 여유 공간 보기
git-delta   git diff를 더 읽기 좋게 표시
```

로그, 모니터링, TUI 도구:

```text
lnav        로그 파일을 터미널 UI로 보기
tailspin    로그 하이라이터, 명령어는 tspin
btop        CPU/메모리/프로세스 모니터
lazygit     Git 터미널 UI
lazydocker  Docker 터미널 UI
k9s         Kubernetes 터미널 UI
yazi        터미널 파일 매니저
```

코드 편집/품질/검색 도구:

```text
neovim         터미널 편집기, 명령어는 nvim
ast-grep        AST 기반 코드 검색/치환
tokei           코드 라인/언어 통계
typos-cli       코드 오타 검사
shellcheck      shell script linter
shfmt           shell script formatter
actionlint      GitHub Actions linter
hadolint        Dockerfile linter
taplo           TOML formatter/linter
yamllint        YAML linter
markdownlint    Markdown linter
```

Git 확장:

```text
git-lfs          큰 파일 관리
pre-commit      Git hook 관리
difftastic      구문 인식 diff
git-filter-repo Git history rewrite
git-extras      추가 Git subcommand
jj              Jujutsu version control
```

네트워크/데이터/보안 쪽은 필요한 경우 선택합니다:

```text
doggo, gping, trippy, nmap
duckdb, miller, xsv, jless, fx
gitleaks, trufflehog, age, sops, syft, grype
```

개발 워크플로우 보조 도구:

```text
gh          GitHub CLI
just        프로젝트 명령어 모음 실행기
gum         쉘 스크립트에 선택/입력/확인 UI 추가
hyperfine   명령어 실행 시간 벤치마크
xh          HTTP 요청 CLI
```

AI CLI 도구:

```text
Claude Code 터미널 기반 AI 코딩 도우미, 명령어는 claude
ollama      로컬 모델 실행
llm         여러 LLM을 CLI에서 쓰는 도구
aichat      터미널 AI 채팅
mods        파이프라인에 붙여 쓰기 좋은 AI 도우미
```

## 설정으로 바뀌는 것

`install.sh`는 아래 파일들을 링크합니다.

```text
~/.config/dev-setup/dev-setup.zsh  -> config/zsh/dev-setup.zsh
~/.config/dev-setup/LEARN.md       -> docs/LEARN.md
~/.config/dev-setup/repo           -> 이 repo
~/.config/dev-setup/Brewfile.selected
                                      마지막으로 선택한 Homebrew 설치 목록
~/.config/starship.toml            -> config/starship/starship.toml
~/.config/zellij/layouts/dev.kdl    -> config/zellij/dev.kdl
~/.local/bin/git-account           -> scripts/git-accounts.sh
~/.local/bin/nvim-profile          -> scripts/neovim-profiles.sh
```

그리고 `~/.zshrc`에는 아래 managed block 하나만 추가합니다.

```zsh
# >>> dev-setup >>>
if [ -f "$HOME/.config/dev-setup/dev-setup.zsh" ]; then
  source "$HOME/.config/dev-setup/dev-setup.zsh"
fi
# <<< dev-setup <<<
```

즉, 기존 `~/.zshrc` 전체를 덮어쓰지 않습니다.

Git 설정도 `~/.gitconfig` 전체를 소유하지 않고, `include.path` 방식으로 이 repo의 공통 설정을 불러옵니다.

## AI에게 맡길 때

이 repo에는 [SKILL.md](../SKILL.md)가 있습니다.

나중에 Claude Code, Codex, ChatGPT 같은 AI에게 이 repo를 맡길 때는 먼저 이렇게 말하면 됩니다.

```text
이 repo의 SKILL.md를 먼저 읽고 dev-setup을 이어서 작업해줘.
```

`SKILL.md`에는 설치 전에 dry-run을 먼저 돌리기, Git 계정/SSH 키를 조심해서 다루기, Neovim 설정을 바로 덮어쓰지 않기 같은 작업 규칙이 들어 있습니다.

## 매일 쓰는 명령어

가장 자주 쓰게 될 명령:

```zsh
ws              # ~/workspace로 이동
p               # ~/workspace 아래 프로젝트를 fuzzy search로 선택
dh              # 이 설명서 열기
devhelp         # dh와 동일
devhelp-edit    # 이 설명서 수정
devrepo         # dev-setup repo로 이동
zjd             # Zellij 개발 작업대 열기
lg              # lazygit 실행
logs app.log    # 로그 파일 열기
z workspace     # zoxide로 workspace 이동
git-account     # Git 계정 관리
nvprof          # Neovim 프로필 관리
nvl             # LazyVim 프로필로 nvim 실행
```

## 폴더 이동

`~/workspace`로 이동:

```zsh
ws
```

`~/workspace` 아래 프로젝트를 검색해서 이동:

```zsh
p
```

다른 폴더 아래에서 프로젝트를 검색:

```zsh
p ~/code
```

폴더를 만들고 바로 들어가기:

```zsh
mkcd ~/workspace/ruccess/new-project
```

`zoxide`로 자주 가는 폴더에 빠르게 이동:

```zsh
z workspace
z dev-setup
zi
```

`zi`는 이동 후보를 검색해서 선택하는 명령입니다.

## 파일 찾기와 내용 검색

문자열 검색:

```zsh
rg "someFunction"
rg "TODO" ~/workspace
```

파일 찾기:

```zsh
fd package.json
fd README ~/workspace
```

파일 목록 보기:

```zsh
ll
la
lt
```

의미:

```text
ll    자세히 보기
la    숨김 파일 포함해서 보기
lt    트리 형태로 보기
```

파일 내용 예쁘게 보기:

```zsh
bat README.md
catp README.md
```

`catp`는 `bat --paging=never`의 alias입니다.

## 로그 보기

로그 파일을 TUI로 열기:

```zsh
logs app.log
lnav app.log
lnav logs/*.log
```

실시간 로그를 색깔로 보기:

```zsh
tail -f app.log | tspin
tspin app.log
```

`lnav`에서 자주 쓰는 키:

```text
/        검색
f        필터 입력
e        error 사이 이동
w        warning 사이 이동
q        종료
```

## Git 기본 사용

짧은 alias:

```zsh
g st
g lg
g last
lg
```

의미:

```text
g st      git status --short --branch
g lg      git log --graph --decorate --oneline --all
g last    마지막 커밋 보기
lg        lazygit 실행
```

현재 repo를 `lazygit`으로 열기:

```zsh
lg
```

`git-delta`가 설정되어 있어서 아래 명령 결과가 더 읽기 좋게 나옵니다.

```zsh
git diff
git show
```

## Git 계정별 폴더 나누기

이 설정은 계정 이름을 고정하지 않습니다.

예를 들어 내 컴퓨터에서는 이렇게 쓸 수 있습니다:

```text
ruccess -> ~/workspace/ruccess
welda   -> ~/workspace/welda
```

다른 사람은 이렇게 쓸 수도 있습니다:

```text
personal -> ~/workspace/personal
company  -> ~/workspace/company
```

중요한 건 설치할 때 직접 계정 ID와 폴더를 정한다는 점입니다.

처음 설정:

```zsh
git-account init
```

이 명령은 아래 파일들을 만듭니다:

```text
~/.config/dev-setup/git/accounts/<account>.gitconfig
```

예시:

```text
~/.config/dev-setup/git/accounts/ruccess.gitconfig
~/.config/dev-setup/git/accounts/welda.gitconfig
```

그리고 각 계정에 입력한 repo 폴더 아래에서는 해당 Git 계정이 자동으로 적용됩니다.

현재 repo에서 어떤 Git 계정이 적용되는지 확인:

```zsh
git-account current
git-account current ~/workspace/welda/api
```

특정 repo 하나를 회사 계정으로 고정:

```zsh
git-account set-repo welda ~/workspace/welda/api
```

특정 repo 하나를 개인 계정으로 고정:

```zsh
git-account set-repo ruccess ~/workspace/ruccess/dev-setup
```

특정 폴더 아래 repo 전체에 계정 규칙 추가:

```zsh
git-account include welda ~/workspace/welda
git-account include ruccess ~/workspace/ruccess
```

GitHub용 SSH key 만들기:

```zsh
git-account key welda
git-account key ruccess
```

이 명령은 공개키를 출력하고, 가능하면 클립보드에도 복사합니다.

GitHub에는 공개키만 등록합니다. 개인키는 절대 GitHub나 repo에 올리지 않습니다.

SSH remote는 이런 식으로 사용합니다:

```text
git@github.com-<account>:owner/repo.git
```

예시:

```text
git@github.com-welda:welda/repo.git
git@github.com-ruccess:ruccess/dev-setup.git
```

기존 GitHub remote를 회사 계정용으로 바꾸기:

```zsh
git-account remote welda origin ~/workspace/welda/api
```

기존 GitHub remote를 개인 계정용으로 바꾸기:

```zsh
git-account remote ruccess origin ~/workspace/ruccess/dev-setup
```

## 런타임 버전 관리

`mise`는 Node, Python, Go, Rust 같은 언어 버전을 프로젝트별로 관리합니다.

Node LTS 사용:

```zsh
mise use node@lts
```

최신 Python 사용:

```zsh
mise use python@latest
```

Go/Rust 사용:

```zsh
mise use go@latest
mise use rust@latest
```

프로젝트에 적힌 버전 설치:

```zsh
mise install
```

현재 적용된 버전 확인:

```zsh
mise current
```

## 프로젝트 환경변수

`direnv`는 특정 프로젝트 폴더에 들어갈 때 환경변수를 자동으로 불러옵니다.

예시:

```zsh
cd my-project
echo 'export API_URL=http://localhost:3000' > .envrc
direnv allow
```

이후 해당 폴더에 들어갈 때마다 `.envrc`가 자동 적용됩니다.

주의:

```text
.envrc에는 민감한 값을 넣을 수 있으므로 repo에 올릴지 조심합니다.
```

## 시스템과 디스크 확인

CPU, 메모리, 프로세스 보기:

```zsh
btop
```

디스크 사용량 보기:

```zsh
dust
```

디스크 여유 공간 보기:

```zsh
duf
```

명령어 실행 시간 비교:

```zsh
hyperfine 'npm test' 'pnpm test'
```

## TUI 도구

터미널 작업대:

```zsh
zellij
zj
zjd
```

Git:

```zsh
lazygit
lg
```

Docker:

```zsh
lazydocker
lzd
```

Kubernetes:

```zsh
k9s
k9
```

파일 매니저:

```zsh
yazi
```

터미널 세션 관리:

```zsh
tmux
```

## Zellij 작업대

처음에는 이렇게 나눠 쓰는 것을 추천합니다.

```text
Ghostty      터미널 앱
Zellij       작업공간, 탭, 패널, 레이아웃
Claude Code  AI 코딩 탭
Neovim       코드 편집
tmux         오래 돌릴 별도 세션, 서버 접속, 익숙한 팀 환경
```

개발 작업대를 열기:

```zsh
zjd
```

`zjd`는 아래 레이아웃을 엽니다.

```text
code    nvim + shell
claude  Claude Code 전용 탭
git     lazygit 탭
tmux    tmux dev 세션
logs    로그/쉘 탭
```

프로젝트 폴더에서 `zjd`를 실행하면 그 폴더를 기준으로 탭들이 열립니다.

Claude Code가 아직 없다면 설치할 때 `ai` 섹션에서 고르거나 아래처럼 설치합니다.

```zsh
brew install --cask claude-code
```

Claude Code 실행:

```zsh
claude
```

## Neovim 프로필

맞습니다. Neovim은 이미 세팅이 잘 된 배포판이 많습니다. 처음부터 모든 설정을 직접 만들기보다, 하나를 골라 익숙해진 뒤 필요한 부분만 바꾸는 편이 빠릅니다.

추천 순서:

```text
LazyVim    가장 무난한 추천. IDE 느낌이 있고 확장하기 쉬움.
AstroNvim  기능이 풍부하고 구조가 잘 잡힌 편.
NvChad     빠르고 UI가 예쁨. 가볍게 시작하기 좋음.
```

이 repo는 기존 `~/.config/nvim`을 바로 덮어쓰지 않습니다. 대신 `NVIM_APPNAME`을 써서 여러 설정을 나란히 시험할 수 있게 합니다.

프로필 목록 보기:

```zsh
nvprof list
```

LazyVim 설치:

```zsh
nvprof install lazyvim
```

LazyVim으로 현재 프로젝트 열기:

```zsh
nvl .
```

다른 프로필:

```zsh
nvprof install astronvim
nva .

nvprof install nvchad
nvc .
```

기본 `nvim`으로 정착하고 싶다면 충분히 써본 뒤에 `~/.config/lazyvim` 같은 프로필 폴더를 `~/.config/nvim`으로 옮기면 됩니다.

## 프로젝트 명령어 관리

`just`는 프로젝트별 자주 쓰는 명령어를 `justfile`에 모아두는 도구입니다.

예시 `justfile`:

```make
default:
    just --list

dev:
    npm run dev

test:
    npm test

lint:
    npm run lint
```

실행:

```zsh
just
just dev
just test
```

## 쉘 스크립트를 편하게 만들기

`gum`은 쉘 스크립트에 선택창, 확인창, 입력창 같은 UI를 붙여줍니다.

예시:

```zsh
gum choose welda ruccess
gum confirm "계속할까요?"
gum input --placeholder "브랜치 이름"
```

## 상태 점검

설치된 도구 확인:

```zsh
devrepo
./scripts/doctor.sh
```

쉘 스크립트 문법 확인:

```zsh
devrepo
bash -n install.sh scripts/*.sh
zsh -n config/zsh/dev-setup.zsh
```

Git 상태 확인:

```zsh
devrepo
git status --short --branch
```

## 이 설정을 수정하는 법

이 설명서 수정:

```zsh
devhelp-edit
```

alias나 함수 수정:

```zsh
devrepo
$EDITOR config/zsh/dev-setup.zsh
source ~/.zshrc
```

설치할 패키지 추가:

```zsh
devrepo
$EDITOR Brewfile
brew bundle --file Brewfile
```

변경사항 커밋:

```zsh
devrepo
git status --short
git add .
git commit -m "Update dev setup"
```

## 문제가 생겼을 때

설정이 이상하면 새 터미널을 열어봅니다.

그래도 이상하면:

```zsh
source ~/.zshrc
```

명령어가 없다고 나오면:

```zsh
devrepo
./scripts/doctor.sh
```

Git 계정이 이상하면:

```zsh
git-account current
git config --show-origin --get user.email
```

SSH 접속이 안 되면:

```zsh
ssh -T git@github.com-ruccess
ssh -T git@github.com-welda
```

GitHub에 공개키가 등록되어 있는지도 확인합니다.
