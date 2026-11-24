# Godot 4.7.2 绿色版安装记录

## 已安装

| 项 | 值 |
|---|---|
| 版本 | `4.7.2.stable.official.ed1daf0bf` |
| 安装目录 | `%LOCALAPPDATA%\Programs\Godot\4.7.2\` |
| 主程序 | `Godot_v4.7.2-stable_win64.exe` |
| 控制台版 | `Godot_v4.7.2-stable_win64_console.exe` |
| 用户 PATH | 已加入（指向目录） |
| 安装包 | 已清理 |

安装日期：2026-10-13

## 快速验证

```powershell
Godot_v4.7.2-stable_win64 --version
# 期望：4.7.2.stable.official.ed1daf0bf
```

> PATH 改动只对新开的终端生效。当前已开着的窗口需重开。

## 重装 / 升级

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File install-godot.ps1
```

脚本是幂等的：已装则直接跳过；默认装 4.7.2。

## 网络限制（重要，换机器会踩）

**中国大陆直连 GitHub Releases 被阻断**，官方 `downloads.godotengine.org` 下到 0.25 MB 就断，
国内高校镜像（交大 / 南大）当时也不可用。脚本因此内置了**多源回退**，实测可用的顺序：

| 源 | 实测结果 |
|---|---|
| `https://gh-proxy.com/` + GitHub 正式地址 | ✅ 可用，21.7s / 82 MB |
| `https://ghfast.top/` + GitHub 正式地址 | ✅ 可达（HEAD 200，86,013,866 字节） |
| `downloads.godotengine.org/?version=...` | ⚠️ 会中途断流 |
| `github.com/...` 直连 | ❌ 超时 |
| 交大 / 南大镜像 | ❌ 空文件 / 502 |

加速器用法就是把完整 GitHub 地址直接拼在后面：

```
https://gh-proxy.com/https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_win64.exe.zip
```

预期文件大小：**86,013,866 字节（约 82 MB）**。小于 80 MB 说明下到的是错误页，脚本会自动换源。

## 两个已踩的坑（别再犯）

### 1. 不要重命名主程序

`*_console.exe` 是个**薄壳**，靠硬编码的官方名字去定位主程序。把主程序改名成 `godot.exe`
之后，console 版会报 `Main executable ... not found.`。

PATH 指向的是**目录**，跟文件名无关，所以保留官方原名完全不影响 `godot` 前缀补全调用。

### 2. PowerShell 5.1 的编码陷阱（踩了两次）

- **`.ps1` 脚本**：无 BOM 的 UTF-8 文件里只要有中文字面量，`powershell.exe` 会按 GBK 解析，
  字符串错乱导致**语法错误**（报错信息里的乱码如 `澶辫触` 就是"失败"）。
  → 脚本一律**纯 ASCII**，或存成带 BOM 的 UTF-8。
- **`project.godot` / `.gd` / `.tscn`**：`Set-Content -Encoding UTF8` 会写入 **BOM**，
  Godot 解析失败并报 `Can't run project: no main scene defined`。
  → 写入 Godot 项目文件必须用无 BOM UTF-8：

```powershell
$enc = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($path, $text, $enc)
```

## 附带产物

`godot-roguelike/` 是为了验证安装而建的最小可运行项目（640×360、GL Compatibility 渲染器、
Nearest 纹理过滤），已用 `--headless` 跑通全链路：

```
[OK] Godot 4.7.2-stable (official) running a real project
[OK] renderer: gl_compatibility
```

它目前只是个冒烟测试，还没有游戏骨架。

## 导出模板（2026-11-24 已安装）

| 项 | 值 |
|---|---|
| 版本 | `4.7.2.stable` |
| 包文件 | `Godot_v4.7.2-stable_export_templates.tpz` |
| 大小 | **1,281,349,702 字节**（约 1.28 GB） |
| SHA-512 | `ca4d71c4d7b81dfc15d1a98baa07534aa95b03fdda78a0075b06672e1648d2e5f40980c9adc28d23e1b92e732ee7bf3461997aa804af74ec2fcd7a93ccb84079` |
| 校验来源 | `SHA512-SUMS.txt`（GitHub release 资产；`downloads.godotengine.org` 跳转域**不提供**该文件） |
| 安装目录 | `%APPDATA%\Godot\export_templates\4.7.2.stable\`（35 个文件，含 `version.txt`） |

**安装方法（换机器可照做）**：

```powershell
# 1. 下载（gh-proxy 加速，约 1.28 GB）
curl -L --retry 6 -C - -o "$env:TEMP\tpz.tpz" `
  "https://gh-proxy.com/https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz"

# 2. 校验 SHA-512（必须与上表一致）
Get-FileHash "$env:TEMP\tpz.tpz" -Algorithm SHA512 | Format-List

# 3. 解压并归位（注意：.tpz 内层目录名是 templates/，要剥掉这一层）
Expand-Archive "$env:TEMP\tpz.tpz" -DestinationPath "$env:TEMP\tpz"
New-Item -ItemType Directory -Force "$env:APPDATA\Godot\export_templates\4.7.2.stable" | Out-Null
Copy-Item "$env:TEMP\tpz\templates\*" "$env:APPDATA\Godot\export_templates\4.7.2.stable\" -Recurse -Force
```

**打包 exe**：跑 `tools\build-exe.ps1`（已封装导出命令与前置检查）。

```powershell
# 等价命令（脚本内部就是这个）
& "$env:LOCALAPPDATA\Programs\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe" `
  --headless --path "C:\Users\ASUS\Desktop\Palard-ZMD\project" `
  --export-release "Windows Desktop" "build\windows\Palard.zmd.exe"
```

**踩坑记录**：

| 坑 | 现象 | 解法 |
|---|---|---|
| `.tpz` 内层还有一层 `templates/` | 直接解压到版本目录 → Godot 找不到模板 | 把 `templates/` 的**内容**拷进 `4.7.2.stable\` |
| 版本目录名要靠 `version.txt` 定 | 猜 `4.7.stable` 会失败 | 解压后 `cat templates/version.txt` → `4.7.2.stable` |
| 下载会中途断流 | `Recv failure: Connection was reset` | `curl -C -` 续传 + `--retry`；最终大小必须等于 1,281,349,702 |
| 默认 `export_filter` 会把测试脚本打进包 | 包内出现 `res://tests/*.remap` | 预设里设 `exclude_filter="tests/*"` |

## 还没做

- [x] 下载**导出模板**（打 exe 给朋友玩才需要）—— 2026-11-24 完成
- [x] Git 初始化 + `.gitignore` / `.gitattributes` —— 已完成（根仓库 + 代码仓库双仓）
- [x] 游戏项目骨架（状态机、数据驱动道具系统、实时调参面板）—— 阶段 0 已完成 12/13
- [ ] **远端备份**（两仓库目前只在本地，无任何备份）
- [ ] 导出的 exe 目前只有手写测试关，没有进入随机生成关卡的入口
