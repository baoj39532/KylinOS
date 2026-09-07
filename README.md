# KylinOS 基础镜像构建仓库

本仓库用于构建并推送基于 **银河麒麟高级服务器操作系统 V10 SP2** 的 AMD64/x86_64 与 ARM64/aarch64 容器镜像。项目的主依赖链以 [`os/`](os/) 生成的麒麟基础镜像为唯一根节点，再逐层叠加 JDK、Maven、Python、Node.js、Nginx、Tomcat、Rust 等运行时。

> 给 agent 的第一原则：先理解并构建 `os`，再处理其余镜像；除文末明确列出的两个例外外，不要把上游 CentOS、Debian 或 openEuler 镜像直接引入麒麟镜像链。

## 构建依赖图

```text
centos:centos8（仅用于 bootstrap）
├── v10-sp2-amd64-<date>                         AMD64 os
│   ├── openjdk8 / openjdk17
│   │   └── openjdk8-maven3.9 / openjdk17-maven3.9
│   ├── dragonwell-extended8 / 11 / 21
│   │   ├── 对应的 *-maven3.9 镜像
│   │   └── dragonwell-extended11-tomcat9
│   ├── oraclejdk8u202
│   │   └── oraclejdk8u202-maven3.9
│   ├── pyenv
│   │   └── pyenv-oracle
│   ├── nvm
│   ├── nginx
│   └── all-tools
└── v10-sp2-arm64-<date>                         ARM64 os
    └── rust1.98.1
```

所有统一管理的镜像均推送到 `botmark/kylinos`。完整标签由 [`common.sh`](common.sh) 生成：

```text
botmark/kylinos:v10-sp2-<amd64|arm64>[-<组件>]-YYYYMMDD
```

日期默认取构建机当天的 `date +%Y%m%d`，也可用 `BUILD_DATE` 固定。存在上下游依赖的构建必须使用同一个 `BUILD_DATE`，否则下游会引用另一天、通常不存在的基础镜像。

## 目录与文件职责

| 路径 | 作用 | 产物/备注 |
| --- | --- | --- |
| [`os/`](os/) | 镜像链的起点。用 `centos:centos8` 执行 `yum --installroot`，从麒麟 V10 SP2 软件源安装最小 rootfs，最后用 `FROM scratch` 输出纯麒麟基础镜像。AMD64 与 ARM64 复用同一个 Dockerfile，通过构建平台让 `$basearch` 分别解析为 `x86_64` 与 `aarch64`。 | `v10-sp2-amd64-<date>`、`v10-sp2-arm64-<date>`；包含麒麟 repo、GPG key、基础命令、CA、curl、nc，以及 `en`/`zh` locale；默认命令为 `/bin/bash`。 |
| [`openjdk/`](openjdk/) | 在 `os` 上安装 Eclipse Temurin OpenJDK。 | OpenJDK 8u452-b09、17.0.9+9。 |
| [`openjdk-maven/`](openjdk-maven/) | 在对应 OpenJDK 镜像上安装 Maven。 | OpenJDK 8/17 + Maven 3.9.16。 |
| [`dragonwell-extended-jdk/`](dragonwell-extended-jdk/) | 在 `os` 上安装 Alibaba Dragonwell Extended。下载 URL 可通过 Docker build arg 覆盖。 | Dragonwell 8.29.28、11.0.31.28.11、21.0.9.0.9+10。 |
| [`dragonwell-extended-jdk-maven/`](dragonwell-extended-jdk-maven/) | 在对应 Dragonwell 镜像上安装 Maven。 | Dragonwell 8/11/21 + Maven 3.9.16。 |
| [`oraclejdk/`](oraclejdk/) | 在 `os` 上安装 Oracle JDK 8u202。 | 需要构建上下文中存在未随仓库提供的 `oraclejdk/jdk-8u202-linux-x64.tar.gz`。 |
| [`oraclejdk-maven/`](oraclejdk-maven/) | 在 Oracle JDK 镜像上安装 Maven。 | Oracle JDK 8u202 + Maven 3.9.16。 |
| [`python3/`](python3/) | 第一层用 pyenv 编译多个 Python；第二层添加 Oracle Instant Client。 | Python 3.8.20、3.9.25、3.10.19、3.11.14、3.12.12、3.13.9、3.14.0；默认 `PYENV_VERSION=3.12`。Oracle 层为 Instant Client 21.20.0.0.0。 |
| [`nodejs/`](nodejs/) | 在 `os` 上安装 nvm 0.40.3、多个 Node.js 版本，并给每个版本全局安装 Yarn。 | Node.js 14.21.3 至 24.11.1（Dockerfile 中列出的离散版本）；默认 20.19.5。nvm 位于 root 用户目录。 |
| [`tomcat/`](tomcat/) | 在 Dragonwell Extended 11 镜像上安装并校验 Tomcat。 | Tomcat 9.0.120，暴露 8080，以 `catalina.sh run` 启动。 |
| [`nginx/`](nginx/) | 从源码构建麒麟版 Nginx，附带接近官方镜像的 entrypoint、模板变量替换、IPv6 和 worker 自动调优逻辑。 | Nginx 1.29.3 + njs 0.9.4，暴露 80；实际构建文件是 `kylin-V10SP2.nginx.Dockerfile`。 |
| [`rust/`](rust/) | 在 ARM64 麒麟基础镜像上安装可复现的系统级 Rust 编译工具链和常用 native crate 构建依赖。 | ARM64/aarch64 专用；Rust 1.98.1，包含 Cargo、rustfmt、Clippy、GCC/G++、Make、CMake、pkg-config 与 OpenSSL 开发库。 |
| [`copaw/`](copaw/) | 独立的工具型实验镜像，包含 SQLite、Python、Node.js、Chrome、LibreOffice、PDF/图像/OCR 依赖。 | **不属于麒麟依赖链**：直接基于 openEuler 22.03，且没有 `build.sh`、统一标签或 CI job。 |
| [`.github/workflows/`](.github/workflows/) | GitHub Actions 自动构建。 | push 到 `main` 或手动触发；统一生成日期、登录 Docker Hub，并按依赖层级构建。 |
| [`.claude/`](.claude/) | Claude 的本地权限配置。 | 仅允许若干 Git 命令，与镜像内容及构建链无关。 |
| [`common.sh`](common.sh) | 全部统一镜像名称和构建日期的单一来源。 | Docker Hub 仓库目前硬编码为 `botmark/kylinos`。 |
| [`build-all-tools.sh`](build-all-tools.sh) / [`kylin-V10SP2.all-tools.Dockerfile`](kylin-V10SP2.all-tools.Dockerfile) | 构建一体化 CI 工具镜像。 | OpenJDK 8/11、Dragonwell 8/11/21、Maven 3.9.16、SonarScanner 8.0.1/4.8.1、全部 pyenv Python、全部 nvm Node.js 及常用编译工具；默认 Java 为 OpenJDK 8、Python 为 3.12.12、Node.js 为 20.19.5。 |

### `os/` 内部流程

1. `kylin-V10SP2.repo` 定义 `base`、`updates` 和默认禁用的 `addons` 软件源；地址为麒麟 V10 SP2 的 `$basearch` 仓库。
2. `RPM-GPG-KEY-kylin` 同时复制到 bootstrap 环境和目标 rootfs，repo 保持 `gpgcheck=1`。
3. `bootstrap` 阶段借用 CentOS 8 的 yum，把麒麟包安装到 `/target`，并不把 CentOS rootfs 带入最终产物。
4. `runner` 阶段以第一次生成的麒麟 rootfs 为基础补齐包、清理 yum cache/日志并生成中英文 locale。
5. 最后一层再次 `FROM scratch`，只复制清理后的 rootfs。

## 构建与推送

### 前置条件

- 可用的 Docker daemon；构建过程需要访问麒麟软件源、GitHub、Apache、Alibaba、Oracle 等下载站点。
- 已执行 `docker login`，因为所有 `build.sh` 都会在构建成功后立即 `docker push`，没有单独的“只构建”开关。Docker Hub 推送不使用 SSH 公钥；推荐为本机创建具备 Read & Write 权限的 Personal Access Token，然后运行 `docker login --username botmark`，在 Password 提示处输入该 token。不要把 token 写入仓库或 shell 脚本。
- 构建 Oracle JDK 分支前，自行合法取得 `jdk-8u202-linux-x64.tar.gz` 并放入 `oraclejdk/`。
- JDK、Node.js、Python、Nginx 等现有运行时分支仍是 AMD64/x86_64 约定；ARM64 当前只发布 `os` 和 Rust 1.98.1，不能把 AMD64 组件标签直接用于 ARM 构建。

### 手动构建示例

脚本使用相对路径 `source ../common.sh`，因此必须从指定目录运行。建议显式用 `bash`，并为整批构建固定同一日期：

```bash
export BUILD_DATE=20260907

(cd os && bash build.sh)

# 第一层：都只依赖 os，可按需并行
(cd openjdk && bash build.sh)
(cd oraclejdk && bash build.sh)
(cd dragonwell-extended-jdk && bash build.sh)
(cd python3 && bash build.sh)
(cd nodejs && bash build.sh)
(cd nginx && bash build.sh)
bash build-all-tools.sh

# 第二层：等待各自的第一层完成
(cd openjdk-maven && bash build.sh)
(cd oraclejdk-maven && bash build.sh)
(cd dragonwell-extended-jdk-maven && bash build.sh)
(cd tomcat && bash build.sh)
```

ARM64 镜像使用独立标签，可在 ARM64 Linux 或启用了 Docker Linux/ARM64 的 Apple Silicon 主机上依次构建：

```bash
export BUILD_DATE=20260907

(cd os && bash build-arm64.sh)
(cd rust && bash build.sh)
```

Docker 平台名使用 `linux/arm64`，而 Linux 内核与 RPM/yum 报告的架构名为 `aarch64`；二者表示同一种 ARM 64 位架构。两个 ARM 构建脚本都会在推送前验证实际架构，Rust 脚本还会编译并运行一个最小程序。

每个构建都使用 `--no-cache`。只想测试 Dockerfile、暂时不推送时，不要直接执行 `build.sh`；请从相应脚本复制其 `docker build` 命令并移除后续 `docker push`。

### CI 构建顺序

[`build-and-push.yml`](.github/workflows/build-and-push.yml) 使用以下顺序：

1. `prepare`：生成本次统一的 `BUILD_DATE`。
2. `os` 与 `os-arm64`：分别在 x86 runner 和 `ubuntu-24.04-arm` 原生 ARM runner 上构建两种麒麟基础镜像。
3. `rust-arm64`：等待 ARM64 OS 完成后，在原生 ARM runner 上构建并验证 Rust 1.98.1 镜像。
4. `all-tools` 与 `runtimes`：等待 AMD64 OS；前者单独构建，后者用 matrix 并行构建 OpenJDK、Dragonwell、Python、Node.js、Nginx。
5. `maven-and-tomcat`：等待全部 AMD64 runtime 完成后，用 matrix 构建 OpenJDK/Dragonwell Maven 镜像和 Tomcat。

CI 依赖仓库 Secrets：`DOCKERHUB_USERNAME`（值为 `botmark`）和 `DOCKERHUB_TOKEN`（具备推送权限的 Docker Hub token）。`copaw/` 不在该 workflow 中。Oracle JDK 及其 Maven 镜像因仓库不包含闭源安装包，当前也明确排除在 CI matrix 之外，只能在准备好合法的本地构建输入后手动构建。

## Agent 修改备忘

- **保持依赖一致**：增加/改名镜像时，通常要同步修改 Dockerfile、目录 `build.sh`、`common.sh`，以及需要自动发布时的 GitHub Actions matrix。
- **保持同一构建日期**：下游通过带日期的完整 tag 找父镜像；单独重跑下游时应复用父镜像构建时的 `BUILD_DATE`。
- **不要混用架构标签**：Docker 平台使用 `arm64`，麒麟 RPM 仓库使用 `aarch64`；Rust Dockerfile 会拒绝非 ARM64 构建，Rust 下游只能使用同一天的 `arm64_os_image`。
- **保持正确 build context**：各 Dockerfile 的 `COPY` 和各脚本的 `source` 都依赖当前目录，不能随意从仓库根目录改为 `docker build -f path/... .`。
- **保持脚本可执行位**：尤其是 `nginx/docker-entrypoint.sh` 和 `/docker-entrypoint.d` 下的脚本；Docker `COPY` 会保留权限，丢失 `+x` 会造成入口程序无法启动或初始化脚本被忽略。提交前可用 `git diff --summary` 检查 mode 变化。
- **区分两个 Nginx Dockerfile**：`nginx/kylin-V10SP2.nginx.Dockerfile` 才是本仓库构建脚本使用的麒麟版；`nginx/Dockerfile` 是生成式的 Debian trixie 上游参考文件，文件头明确要求不要直接编辑。
- **识别独立实验目录**：`copaw/` 当前基于 openEuler，不要默认把它算作 `os` 的下游，也不要在没有明确设计决定时把它加入麒麟 CI 链。
- **注意本地闭源输入**：Oracle JDK Dockerfile 使用本地 `COPY`，仓库当前不包含所需压缩包；相关构建在文件缺失时必然失败。
- **注意 root 用户范围**：`nodejs/` 与 `all-tools` 将 nvm 安装在 `/root/.nvm`；若镜像改为非 root 用户，需要重新设计共享位置和 profile 初始化。
- **切换 Java 要影响当前 shell**：`all-tools` 内的 `switch-java` 通过 `export` 改环境，直接作为子进程执行不会改变调用者；需要 `source /usr/local/bin/switch-java <版本>`，或由调用方直接设置 `JAVA_HOME`/`PATH`。
- **校验现状**：Tomcat 下载有 SHA-512 校验，绝大多数其他远程 tar/安装脚本没有固定摘要；升级版本时应同时核对 URL、解压目录名、环境变量及可复现性。

## 镜像清单

以 `BUILD_DATE=YYYYMMDD` 为例，`common.sh` 定义的完整 tag 后缀如下：

```text
v10-sp2-amd64-YYYYMMDD
v10-sp2-amd64-openjdk8-YYYYMMDD
v10-sp2-amd64-openjdk17-YYYYMMDD
v10-sp2-amd64-openjdk8-maven3.9-YYYYMMDD
v10-sp2-amd64-openjdk17-maven3.9-YYYYMMDD
v10-sp2-amd64-dragonwell-extended8-YYYYMMDD
v10-sp2-amd64-dragonwell-extended11-YYYYMMDD
v10-sp2-amd64-dragonwell-extended21-YYYYMMDD
v10-sp2-amd64-dragonwell-extended8-maven3.9-YYYYMMDD
v10-sp2-amd64-dragonwell-extended11-maven3.9-YYYYMMDD
v10-sp2-amd64-dragonwell-extended21-maven3.9-YYYYMMDD
v10-sp2-amd64-oraclejdk8u202-YYYYMMDD
v10-sp2-amd64-oraclejdk8u202-maven3.9-YYYYMMDD
v10-sp2-amd64-pyenv-YYYYMMDD
v10-sp2-amd64-pyenv-oracle-YYYYMMDD
v10-sp2-amd64-dragonwell-extended11-tomcat9-YYYYMMDD
v10-sp2-amd64-nginx-YYYYMMDD
v10-sp2-amd64-nvm-YYYYMMDD
v10-sp2-amd64-all-tools-YYYYMMDD
v10-sp2-arm64-YYYYMMDD
v10-sp2-arm64-rust1.98.1-YYYYMMDD
```
