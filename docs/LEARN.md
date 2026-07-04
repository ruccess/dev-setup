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

현재 이 repo가 하는 일은 크게 세 가지입니다:

1. Homebrew로 설치할 앱과 CLI 도구 목록을 관리합니다.
2. zsh, starship, git 설정을 링크합니다.
3. 회사 계정과 개인 계정용 Git 설정을 분리해서 관리합니다.

## 처음 실행

기본 설치:

```zsh
cd ~/workspace/dev-setup
./install.sh
source ~/.zshrc
./scripts/doctor.sh
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

## 설치되는 CLI 도구

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
tmux        터미널 세션/창/패널 관리
```

개발 워크플로우 보조 도구:

```text
gh          GitHub CLI
just        프로젝트 명령어 모음 실행기
gum         쉘 스크립트에 선택/입력/확인 UI 추가
hyperfine   명령어 실행 시간 벤치마크
xh          HTTP 요청 CLI
```

## 설정으로 바뀌는 것

`install.sh`는 아래 파일들을 링크합니다.

```text
~/.config/dev-setup/dev-setup.zsh  -> config/zsh/dev-setup.zsh
~/.config/dev-setup/LEARN.md       -> docs/LEARN.md
~/.config/dev-setup/repo           -> 이 repo
~/.config/starship.toml            -> config/starship/starship.toml
~/.local/bin/git-account           -> scripts/git-accounts.sh
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

## 매일 쓰는 명령어

가장 자주 쓰게 될 명령:

```zsh
ws              # ~/workspace로 이동
p               # ~/workspace 아래 프로젝트를 fuzzy search로 선택
dh              # 이 설명서 열기
devhelp         # dh와 동일
devhelp-edit    # 이 설명서 수정
devrepo         # dev-setup repo로 이동
lg              # lazygit 실행
logs app.log    # 로그 파일 열기
z workspace     # zoxide로 workspace 이동
git-account     # Git 계정 관리
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
mkcd ~/workspace/personal/new-project
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

## 회사 Git 계정과 개인 Git 계정

회사 계정과 개인 계정을 처음 설정:

```zsh
git-account init
```

이 명령은 아래 파일들을 만듭니다:

```text
~/.config/dev-setup/git/accounts/work.gitconfig
~/.config/dev-setup/git/accounts/personal.gitconfig
```

기본 규칙:

```text
~/workspace/work/       회사 계정
~/workspace/company/    회사 계정
~/workspace/personal/   개인 계정
```

현재 repo에서 어떤 Git 계정이 적용되는지 확인:

```zsh
git-account current
git-account current ~/workspace/wd-cron
```

특정 repo 하나를 회사 계정으로 고정:

```zsh
git-account set-repo work ~/workspace/wd-cron
```

특정 repo 하나를 개인 계정으로 고정:

```zsh
git-account set-repo personal ~/workspace/personal/dotfiles
```

특정 폴더 아래 repo 전체에 계정 규칙 추가:

```zsh
git-account include work ~/workspace/work
git-account include personal ~/workspace/personal
```

GitHub용 SSH key 만들기:

```zsh
git-account key work
git-account key personal
```

이 명령은 공개키를 출력하고, 가능하면 클립보드에도 복사합니다.

GitHub에는 공개키만 등록합니다. 개인키는 절대 GitHub나 repo에 올리지 않습니다.

SSH remote는 이런 식으로 사용합니다:

```text
git@github.com-work:company/repo.git
git@github.com-personal:username/repo.git
```

기존 GitHub remote를 회사 계정용으로 바꾸기:

```zsh
git-account remote work origin ~/workspace/wd-cron
```

기존 GitHub remote를 개인 계정용으로 바꾸기:

```zsh
git-account remote personal origin ~/workspace/personal/dotfiles
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
gum choose work personal
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
ssh -T git@github.com-personal
ssh -T git@github.com-work
```

GitHub에 공개키가 등록되어 있는지도 확인합니다.

