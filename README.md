# Palard-ZMD

> 以《明日方舟：终末地》为背景的 **2D 横板肉鸽闯关游戏**
> 对标 Dead Cells，单人开发 · 每周 15 小时 · 工期不限

---

## 目录结构

```
Palard-ZMD/
├── README.md                    ← 本文件
│
├── project/                     ← Godot 4.7.2 项目（可直接用 Godot 打开）
│   ├── project.godot
│   ├── .gitignore               ← 首行 .gdignore，防 Godot 导入 .git 内部文件
│   ├── .gitattributes           ← 强制 LF，正确声明二进制资产
│   ├── scenes/
│   │   ├── boot/boot.tscn       ← 启动场景
│   │   └── debug/debug_panel.tscn
│   └── scripts/
│       ├── boot/boot.gd
│       ├── config/feel_config.gd    ← 手感参数（35 个可调项）
│       └── debug/debug_panel.gd     ← 实时调参面板
│
├── Documents/
│   ├── design/
│   │   ├── DESIGN.md            ← ⭐ 设计权威文档（改玩法先改它，再改代码）
│   │   └── PROGRESS.md          ← ⭐ 进度台账（每周更新）
│   ├── reference/
│   │   ├── feel-spec-deadcells.md
│   │   ├── plan-20weeks-solo.md
│   │   ├── game-design-pillar-template.md
│   │   └── GODOT_INSTALL_NOTES.md
│   └── _archive_vscode-buffer-20261013.md
│
└── tools/
    └── check-progress.ps1       ← 只读巡检脚本（每周复盘跑一次）
```

---

## 快速开始

### 打开项目

```powershell
# 方式 A：Godot 编辑器里「导入」然后选 project/project.godot
# 方式 B：命令行直接打开
& "$env:LOCALAPPDATA\Programs\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe" --path "C:\Users\ASUS\Desktop\Palard-ZMD\project" --editor
```

### 运行游戏

```powershell
& "$env:LOCALAPPDATA\Programs\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe" --path "C:\Users\ASUS\Desktop\Palard-ZMD\project"
```

### 命令行自检（不开窗口）

```powershell
& "$env:LOCALAPPDATA\Programs\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe" --headless --path "C:\Users\ASUS\Desktop\Palard-ZMD\project" --quit-after 300
```

期望输出末尾：`参数自洽性检查：通过 ✓`

### 每周巡检

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\ASUS\Desktop\Palard-ZMD\tools\check-progress.ps1"
```

---

## 操作键位

| 动作 | 按键 |
|---|---|
| 移动 | `W` `A` `S` `D` 或方向键 |
| 跳跃 | `Space` 或 `J` |
| 攻击 | `L` |
| 冲刺 | `K` |
| 调参面板 | `F1` |
| 面板内保存 / 重置 | `F5` / `R` |
| 退出 | `Esc` |

---

## 当前进度

**阶段 0：核心验证**（约 8 人周 / 5 个月）—— 🟡 进行中

| # | 任务 | 状态 |
|---|---|---|
| 0.1 | 项目骨架 + Git | ✅ |
| 0.2 | 输入映射 | ✅ |
| 0.3 | `FeelConfig`（35 参数） | ✅ |
| 0.4 | 实时调参面板 | ✅ |
| 0.5 | 玩家移动 | ⬜ 下一步 |
| 0.6 | 玩家状态机 | ⬜ |
| 0.7 | 攻击（3 段连击） | ⬜ |
| 0.8 | 顿帧 / 屏震 / 受击反馈 | ⬜ |
| 0.9 | 受击 + 冲刺无敌帧 | ⬜ |
| 0.10 | 敌人 AI 框架 + 冲锋兵 | ⬜ |
| 0.11 | 战斗闭环 | ⬜ |
| 0.12 | 手感调参 + 试玩 | ⬜ |
| 0.13 | 层内连通图可行性验证 | ⬜ |

详细进度见 `Documents/design/PROGRESS.md`。

---

## 设计要点（速查）

| 项 | 决定 |
|---|---|
| 地图结构 | **分层推进（Dead Cells 式）+ 每层内连通可回退**；层间单向不可回退 |
| 单局时长 | 60–90 分钟 |
| 可操作角色 | **仅「管理员」1 名** |
| 道具归属 | 局内解锁 → **计入掉落池，非永久持有** |
| 死亡惩罚 | 丢当局金币，留永久解锁 |
| IP | **非 IP 化运营**：不商业化、不授权、不变现 |
| 技巧 : 运气 | 7 : 3 |

---

## 两条必须遵守的约束

### 1. 改玩法 → 先改 `DESIGN.md`，再改代码

`DESIGN.md` 是设计的**唯一权威来源**。任何玩法改动都要先在文档里改，
并在「修订记录」表追加一行版本号。**不要反过来。**

### 2. 手感参数必须实时可调

任何脚本读取手感数值都必须走 `FeelConfig`，**不得硬编码在逻辑里**。
往 `FeelConfig` 加参数后，调参面板会**自动出现新滑块**（靠反射生成），无需改面板代码。

---

## 已知的技术陷阱（踩过的坑，别再踩）

| 陷阱 | 现象 | 解法 |
|---|---|---|
| `class_name` + `preload()` 混用 | 首帧报 `Could not find type Xxx` | 用 `Resource` 类型 + 显式 cast |
| 变量声明为 `Resource` 类型 | 其方法返回值无法类型推断 | 写 `var x: Array = obj.method()` |
| `CanvasLayer` 上的 UI 用 `set_anchors_preset` | 锚点解析为 0，UI 跑到屏幕外 | 直接设 `anchor_*` + `offset` |
| PowerShell `Set-Content -Encoding UTF8` 写 `project.godot` | 写入 BOM → Godot 报 `no main scene defined` | 用 `UTF8Encoding($false)` 写无 BOM |
| `.ps1` 里含中文却无 BOM | PowerShell 5.1 按 GBK 解析 → 语法错误 | 存为 **UTF-8 with BOM** |
| `.gitignore` 缺 `.gdignore` | Godot 尝试导入 `.git` 内部对象 | `.gdignore` 放**第一行** |

---

## 手感基准数值（已校验自洽）

```
重力       682.7 px/s²     跳跃初速   256.0 px/s
→ 跳跃高度  48.0 px（3 格）  → 滞空时间  0.750 s
```

> ⚠️ **勘误备查**：早期文档把跳跃初速写成 `128`（误用 `v₀ = 2h/t`，漏因子 2），
> 那会得到 12px 高度 / 0.375s 滞空。正确公式是 **`v₀ = 4h/t`**。

---

## 项目状态

- **开始日期**：2026-10-13
- **引擎**：Godot 4.7.2 stable（绿色版，位于 `%LOCALAPPDATA%\Programs\Godot\4.7.2\`）
- **性质**：个人作品集项目，非商业
