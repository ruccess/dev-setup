# dev-setup

macOS 개발 환경을 빠르게 재현하기 위한 범용 bootstrap 템플릿입니다.

목표는 세 가지입니다.

1. 새 Mac에서도 터미널 개발 환경을 빠르게 세팅합니다.
2. 회사 계정과 개인 계정의 Git 설정을 폴더별로 분리합니다.
3. 나중에 AI에게 맡겨도 같은 기준으로 이어서 세팅할 수 있게 문서화합니다.

이 repo는 여러 번 실행해도 되도록 만들어졌습니다. 설치 전에는 항상 `--dry-run`으로 먼저 확인할 수 있습니다.

## 빠른 시작

repo를 받은 뒤 먼저 메뉴를 열어봅니다.

```zsh
cd path/to/dev-setup
./menu.sh
```

설치 전에 어떤 일이 일어날지 보고 싶으면:

```zsh
./install.sh --dry-run
```

대화형 설치:

```zsh
./install.sh
```

추천 핵심 섹션만 설치:

```zsh
./install.sh --brew-groups apps,terminal,shell,modern,logs,code,git,ai-dev,workflow
```

설치 후 새 터미널을 열거나:

```zsh
source ~/.zshrc
./scripts/doctor.sh
```

## 내 환경으로 바꾸기

기본 계정 이름이나 workspace 위치를 바꾸고 싶으면 `.env.example`을 복사해서 로컬 전용 `.env`를 만듭니다.

```zsh
cp .env.example .env
$EDITOR .env
```

예시:

```zsh
export DEV_SETUP_WORKSPACE_ROOT="$HOME/workspace"
export DEV_SETUP_ACCOUNT_DEFAULTS="personal,work"
export DEV_SETUP_ACCOUNT_COUNT="2"
```

`.env`는 Git에 올라가지 않습니다. `./menu.sh`와 `./install.sh`는 repo 안의 `.env`가 있으면 자동으로 읽습니다.

## 메뉴 사용법

명령어를 외우기 전에는 메뉴를 쓰면 됩니다.

repo 안에서:

```zsh
./menu.sh
```

설치 후 어디서든:

```zsh
dev-setup
devmenu
dm
```

메뉴에서 할 수 있는 일:

```text
install dry-run        설치 전 미리보기
install interactive    전체 대화형 설치
install recommended    핵심 추천 섹션 설치
install AI dev baseline  AI 개발 기본 묶음만 설치
tool catalog           도구 설명/추천 여부 보기
doctor                 설치 상태 점검
Git accounts           Git 계정/SSH 설정
GitHub CLI             gh 로그인/PR/workflow 확인
Neovim profiles        LazyVim/AstroNvim/NvChad 관리
Zellij dev workspace   개발 작업대 열기
script explorer        repo의 스크립트를 읽고 help/run/editor 선택
```

## 설치 섹션

설치할 도구는 섹션 단위로 고릅니다.

```zsh
./install.sh --list-brew-groups
./install.sh --list-tools
```

대화형 설치에서 각 섹션은 이렇게 선택합니다.

```text
Enter  기본값 선택
r      추천 도구 설치
a      섹션 전체 설치
n      이 섹션 건너뛰기
c      도구별로 하나씩 선택
```

비대화형으로 섹션을 지정할 수도 있습니다.

```zsh
./install.sh --brew-groups apps,terminal,shell,modern
./install.sh --all-brew
./install.sh --brew-groups none
```

## 도구 설명

### Apps

| 도구 | 설명 | 처음 써보기 |
| --- | --- | --- |
| Ghostty | 빠른 터미널 앱 | 앱에서 Ghostty 실행 |
| Raycast | Spotlight보다 강한 런처/명령 팔레트 | 앱에서 Raycast 실행 |
| JetBrains Mono Nerd Font | 터미널 아이콘과 글리프가 포함된 폰트 | 터미널 폰트로 지정 |

### Terminal

| 도구 | 설명 | 처음 써보기 |
| --- | --- | --- |
| zellij | 탭, 패널, 레이아웃을 관리하는 터미널 작업대 | `zellij`, `zjd` |
| tmux | 오래 검증된 터미널 세션/창/패널 관리자 | `tmux new -A -s dev` |

추천 구조:

```text
Ghostty      터미널 앱
Zellij       작업공간, 탭, 패널, 레이아웃
Claude Code  AI 코딩 탭
Neovim       코드 편집
tmux         오래 돌릴 세션/서버/팀 호환용
```

개발 작업대 열기:

```zsh
zjd
```

### Shell

| 도구 | 설명 | 처음 써보기 |
| --- | --- | --- |
| starship | 빠르고 예쁜 프롬프트 | 새 터미널 열기 |
| fzf | 목록을 fuzzy search로 고르는 도구 | `history | fzf` |
| zoxide | 자주 가는 폴더를 기억하는 똑똑한 `cd` | `z workspace` |
| atuin | 쉘 히스토리 검색/동기화 도구 | `atuin search` |
| mise | Node/Python/Go/Rust 등 런타임 버전 관리 | `mise list` |
| direnv | 폴더 진입 시 `.envrc` 환경변수 자동 로드 | `direnv allow` |

### Modern Unix

| 도구 | 설명 | 처음 써보기 |
| --- | --- | --- |
| eza | `ls` 대체 도구 | `ll`, `lt` |
| bat | syntax highlight가 있는 `cat` | `catp README.md` |
| fd | 빠른 `find` 대체 | `fd README` |
| ripgrep | 빠른 `grep` 대체, 명령어는 `rg` | `rg TODO` |
| sd | 단순한 문자열 치환 도구 | `sd old new file.txt` |
| jq | JSON 처리 | `cat data.json | jq .` |
| yq | YAML/JSON/XML 처리 | `yq . file.yml` |
| dust | 디스크 사용량 보기 | `dust` |
| duf | 디스크 여유 공간 보기 | `duf` |
| git-delta | `git diff`를 읽기 좋게 표시 | `git diff` |

### Logs / TUI

| 도구 | 설명 | 처음 써보기 |
| --- | --- | --- |
| lnav | 로그 파일을 터미널 UI로 분석 | `logs app.log` |
| tailspin | 로그를 색상으로 읽기 좋게 표시, 명령어는 `tspin` | `tspin app.log` |
| btop | CPU/메모리/프로세스 모니터 | `btop` |
| lazygit | Git 터미널 UI | `lg` |
| yazi | 터미널 파일 매니저 | `yazi` |

### Code

| 도구 | 설명 | 처음 써보기 |
| --- | --- | --- |
| neovim | 터미널 편집기, 명령어는 `nvim` | `nvim .` |
| ast-grep | AST 기반 코드 검색/치환 | `ast-grep --help` |
| tokei | 코드 라인/언어 통계 | `tokei` |
| typos-cli | 코드/문서 오타 검사 | `typos` |
| shellcheck | shell script linter | `shellcheck install.sh` |
| shfmt | shell script formatter | `shfmt -w install.sh` |
| actionlint | GitHub Actions linter | `actionlint` |
| hadolint | Dockerfile linter | `hadolint Dockerfile` |
| taplo | TOML formatter/linter | `taplo fmt file.toml` |
| yamllint | YAML linter | `yamllint .` |
| markdownlint-cli | Markdown linter | `markdownlint README.md` |

Neovim 배포판은 기본 `~/.config/nvim`을 바로 덮어쓰지 않고 프로필로 분리해서 시험합니다.

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

### Git

| 도구 | 설명 | 처음 써보기 |
| --- | --- | --- |
| git-lfs | 큰 파일을 Git에서 관리 | `git lfs install` |
| pre-commit | Git hook 관리 | `pre-commit install` |
| difftastic | 구문 인식 diff viewer | `difft` |
| git-filter-repo | Git history rewrite | `git filter-repo --help` |
| git-extras | 추가 Git subcommand 모음 | `git extras --help` |
| jj | Jujutsu version control | `jj --help` |

이 repo 자체의 Git 계정 분리는 `git-account` helper가 담당합니다.

```zsh
git-account init
git-account list
git-account current
```

### Network

| 도구 | 설명 | 처음 써보기 |
| --- | --- | --- |
| wget | 파일 다운로드 | `wget URL` |
| aria2 | 멀티 프로토콜 다운로드 | `aria2c URL` |
| doggo | DNS 조회 | `doggo example.com` |
| gping | 그래프로 보는 ping | `gping github.com` |
| mtr | ping + traceroute | `mtr github.com` |
| iperf3 | 네트워크 처리량 테스트 | `iperf3 --help` |
| nmap | 네트워크 스캐너 | `nmap localhost` |
| bandwhich | 프로세스별 네트워크 사용량 | `sudo bandwhich` |
| trippy | 네트워크 진단 TUI | `trip github.com` |

### Data

| 도구 | 설명 | 처음 써보기 |
| --- | --- | --- |
| duckdb | 로컬 분석용 SQL 엔진 | `duckdb` |
| sqlite | SQLite CLI | `sqlite3 db.sqlite` |
| miller | CSV/JSON/TSV 처리, 명령어는 `mlr` | `mlr --help` |
| csvkit | CSV 도구 모음 | `csvlook file.csv` |
| xsv | 빠른 CSV 도구 | `xsv headers file.csv` |
| jless | JSON viewer | `jless file.json` |
| fx | JSON viewer/processor | `fx file.json` |
| dasel | JSON/YAML/TOML/XML query | `dasel --help` |
| visidata | 터미널 데이터 탐색기 | `vd file.csv` |

### Containers / Kubernetes

| 도구 | 설명 | 처음 써보기 |
| --- | --- | --- |
| docker | Docker CLI | `docker ps` |
| docker-compose | Docker Compose CLI | `docker compose version` |
| colima | macOS용 컨테이너 런타임 | `colima start` |
| lazydocker | Docker TUI | `lzd` |
| kubectl | Kubernetes CLI | `kubectl get pods` |
| helm | Kubernetes 패키지 매니저 | `helm list` |
| kubectx | Kubernetes context/namespace 전환 | `kubectx` |
| stern | 여러 pod 로그 tail | `stern app` |
| k9s | Kubernetes TUI | `k9` |
| kind | 로컬 Kubernetes 클러스터 | `kind create cluster` |
| helmfile | Helm release 선언형 관리 | `helmfile apply` |

### Cloud / Infrastructure

| 도구 | 설명 | 처음 써보기 |
| --- | --- | --- |
| awscli | AWS CLI | `aws configure sso` |
| azure-cli | Azure CLI | `az login` |
| google-cloud-sdk | Google Cloud CLI | `gcloud auth login` |
| doctl | DigitalOcean CLI | `doctl auth init` |
| flyctl | Fly.io CLI | `fly auth login` |
| opentofu | Terraform 호환 IaC 도구 | `tofu init` |

### Security

| 도구 | 설명 | 처음 써보기 |
| --- | --- | --- |
| gitleaks | Git secret scanner | `gitleaks detect` |
| trufflehog | 검증형 secret scanner | `trufflehog git file://.` |
| age | 단순 파일 암호화 | `age --help` |
| sops | 암호화된 설정/secret 파일 관리 | `sops file.yaml` |
| cosign | 컨테이너 서명/검증 | `cosign version` |
| syft | SBOM 생성 | `syft .` |
| grype | 취약점 스캐너 | `grype .` |

### Media / Documents

| 도구 | 설명 | 처음 써보기 |
| --- | --- | --- |
| ffmpeg | 오디오/비디오 변환 | `ffmpeg -i input.mov output.mp4` |
| imagemagick | 이미지 변환/처리 | `magick input.png output.jpg` |
| pandoc | 문서 변환 | `pandoc README.md -o README.pdf` |
| poppler | PDF 유틸리티 | `pdftotext file.pdf -` |
| rclone | 클라우드 스토리지 동기화 | `rclone config` |
| sevenzip | 압축/해제 | `7zz x archive.7z` |

### AI Dev Baseline

AI와 같이 코딩할 때는 AI CLI만이 아니라 런타임, 검색, GitHub, 검증 도구가 같이 필요합니다.

```zsh
./install.sh --brew-groups ai-dev
```

이 묶음에 들어가는 기본 도구:

| 도구 | 왜 필요한가 | 처음 써보기 |
| --- | --- | --- |
| Claude Code | 터미널에서 AI와 코드 작업 | `claude` |
| bun | JS/TS 프로젝트 생성, 실행, 테스트를 빠르게 처리 | `bun --version` |
| pnpm | Node 프로젝트 의존성 설치/스크립트 실행 | `pnpm --version` |
| uv | Python 프로젝트/패키지 관리 | `uv --version` |
| mise | Node/Python 같은 런타임 버전 고정 | `mise use --global node@lts` |
| gh | GitHub 로그인, repo, PR, workflow 관리 | `gh auth login` |
| rg/fd/jq | 코드/파일/API 출력 검색과 분석 | `rg TODO`, `fd README`, `jq .` |
| ast-grep | 코드 구조 기반 검색/수정 | `ast-grep --help` |
| gitleaks | AI가 만든 변경에 secret이 섞였는지 검사 | `gitleaks detect` |
| pre-commit | 프로젝트 검증 hook 실행 | `pre-commit install` |
| just | 프로젝트 명령어를 한 곳에 정리 | `just --list` |

설치 후 추천 초기화:

```zsh
mise use --global node@lts
mise use --global python@latest
gh auth login
```

### Runtimes

| 도구 | 설명 | 처음 써보기 |
| --- | --- | --- |
| uv | 빠른 Python package/project 도구 | `uv --help` |
| bun | JavaScript runtime/package manager | `bun --help` |
| pnpm | JavaScript package manager | `pnpm --version` |
| deno | JavaScript/TypeScript runtime | `deno --version` |

### AI

`ai-dev`가 AI 코딩 기본 묶음이고, `ai` 섹션은 로컬 모델이나 별도 AI CLI까지 확장하고 싶을 때 고릅니다.

| 도구 | 설명 | 처음 써보기 |
| --- | --- | --- |
| Claude Code | 터미널 기반 AI 코딩 도우미, 명령어는 `claude` | `claude` |
| ollama | 로컬 모델 실행 | `ollama run llama3.2` |
| llm | 여러 LLM을 CLI에서 쓰는 도구 | `llm --help` |
| aichat | 터미널 AI 채팅 | `aichat` |
| mods | 파이프라인에 붙여 쓰기 좋은 AI 도우미 | `mods --help` |

### Workflow

| 도구 | 설명 | 처음 써보기 |
| --- | --- | --- |
| gh | GitHub CLI | `gh auth login` |
| just | 프로젝트 명령어 실행기 | `just --list` |
| gum | shell script용 선택/입력/확인 UI | `gum choose a b c` |
| hyperfine | 명령어 실행 시간 벤치마크 | `hyperfine 'npm test'` |
| xh | HTTP client | `xh GET https://example.com` |

`gh`로 GitHub 로그인을 해두면 repo 생성, PR 확인, workflow 확인을 터미널에서 바로 할 수 있습니다.

```zsh
gh auth login
gh repo view --web
gh pr list
```

## 설치 후 자주 쓰는 명령어

```zsh
ws              # ~/workspace로 이동
p               # ~/workspace 아래 프로젝트 fuzzy search
dh              # 한국어 사용 설명서 열기
devhelp         # dh와 동일
devhelp-edit    # 사용 설명서 수정
devrepo         # dev-setup repo로 이동
dev-setup       # 선택 메뉴 열기
devmenu         # dev-setup과 동일
dm              # dev-setup과 동일
zjd             # Zellij 개발 작업대 열기
lg              # lazygit 실행
logs app.log    # 로그 파일 열기
tspin app.log   # tailspin으로 로그 보기
z workspace     # zoxide로 이동
atuin search    # 쉘 히스토리 검색
git-account     # Git 계정 관리
nvprof          # Neovim 프로필 관리
nvl             # LazyVim 프로필로 nvim 실행
```

## Git 계정 관리

회사 계정과 개인 계정을 폴더별로 분리합니다.

예시:

```text
personal -> ~/workspace/personal
work     -> ~/workspace/work
```

초기 설정:

```zsh
git-account init
```

생성되는 파일:

```text
~/.config/dev-setup/git/accounts/<account>.gitconfig
```

현재 repo가 어떤 계정을 쓰는지 확인:

```zsh
git-account current
git-account current ~/workspace/work/api
```

특정 repo에 계정 지정:

```zsh
git-account set-repo work ~/workspace/work/api
```

GitHub SSH 키 생성:

```zsh
git-account key work
git-account key personal
```

SSH remote는 계정별 host alias를 씁니다.

```text
git@github.com-work:<org-or-user>/repo.git
git@github.com-personal:<github-user>/dev-setup.git
```

기존 remote를 계정 alias로 바꾸기:

```zsh
git-account remote personal origin ~/workspace/personal/dev-setup
```

`Permission denied (publickey)`가 나오면 해당 계정의 `.pub` 공개키를 GitHub에 등록해야 합니다.

## AI에게 맡길 때

이 repo에는 [SKILL.md](SKILL.md)가 있습니다.

Claude Code, Codex, ChatGPT 같은 AI에게 맡길 때는 먼저 이렇게 말하면 됩니다.

```text
이 repo의 SKILL.md를 먼저 읽고 dev-setup을 이어서 작업해줘.
```

`SKILL.md`에는 설치 전 dry-run, SSH 키 주의, Neovim 설정을 덮어쓰지 않는 규칙 등이 들어 있습니다.

## 파일 구조

```text
.env.example                    로컬 기본값 예시
Brewfile                         Homebrew 전체 catalog
SKILL.md                         AI assistant 작업 가이드
menu.sh                          선택 메뉴 wrapper
install.sh                       설치/링크 스크립트
docs/LEARN.md                    한국어 학습/치트시트
config/zsh/dev-setup.zsh         zsh alias/function
config/zellij/dev.kdl            Zellij 개발 작업대 레이아웃
config/starship/starship.toml    prompt 설정
config/git/gitconfig             Git 공통 설정
scripts/git-accounts.sh          Git 계정 관리
scripts/neovim-profiles.sh       Neovim 프로필 관리
scripts/menu.sh                  선택 메뉴 본체
scripts/doctor.sh                설치 상태 점검
```

`install.sh`는 마지막 선택 결과를 여기에 저장합니다.

```text
~/.config/dev-setup/Brewfile.selected
```

## 개발/검증

스크립트 수정 후에는:

```zsh
bash -n install.sh menu.sh scripts/*.sh
zsh -n config/zsh/dev-setup.zsh
git diff --check
./menu.sh --list
./install.sh --dry-run --skip-brew --skip-git-accounts
```

Homebrew catalog 확인:

```zsh
brew bundle check --file Brewfile
```

이 명령은 아직 설치하지 않은 패키지가 있으면 실패할 수 있습니다. Brewfile을 읽는 데 성공하는지만 확인해도 의미가 있습니다.

## GitHub push

remote 예시:

```zsh
git remote add origin git@github.com-personal:<github-user>/dev-setup.git
git push -u origin main
```

SSH 인증이 실패하면:

```zsh
ssh -T git@github.com-personal
cat ~/.ssh/id_ed25519_personal.pub
```

출력된 공개키를 해당 GitHub 계정에 등록합니다.
