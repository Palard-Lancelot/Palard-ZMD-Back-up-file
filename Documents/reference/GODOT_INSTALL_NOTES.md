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

## 还没做

- [ ] 下载**导出模板**（打 exe 给朋友玩才需要）：编辑器 → `编辑器` → `管理导出模板`
- [ ] Git 初始化 + `.gitignore` / `.gitattributes`
- [ ] 游戏项目骨架（状态机、数据驱动道具系统、实时调参面板）
