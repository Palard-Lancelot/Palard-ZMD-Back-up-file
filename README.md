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

## ⚠️ 版本控制：两个独立仓库

本项目**刻意使用两个 git 仓库**，互不干扰：

| 仓库 | 位置 | 管什么 | 说明 |
|---|---|---|---|
| **根仓库** | `Palard-ZMD/.git` | `Documents/` + `tools/` + `README.md` | 设计文档与工具 |
| **代码仓库** | `Palard-ZMD/project/.git` | Godot 代码 | 保留完整提交历史 |

**为什么分开**：文档与代码的变更节奏不同。改玩法时先改 `DESIGN.md`（根仓库），
再改代码（代码仓库），两者分开提交更清晰。

根仓库的 `.gitignore` 已忽略 `project/`，所以不会出现嵌套仓库的混乱。

### 提交方式

```powershell
# 提交设计文档变更（根仓库）
cd C:\Users\ASUS\Desktop\Palard-ZMD
git add -A && git commit -m "docs: ..."

# 提交代码变更（代码仓库）
cd C:\Users\ASUS\Desktop\Palard-ZMD\project
git add -A && git commit -m "feat: ..."
```

> ⚠️ **两个仓库都设了 `core.autocrlf = false` 且用 `.gitattributes` 强制 LF**。
> 不要改成 `true` —— `DESIGN.md` 这类高频 diff 的文件会因换行符漂移
> 每次显示"整个文件被修改"，污染历史。

---

## 快速开始

### 打开项目

```powershell
# 方式 A：Godot 编辑器里「导入」然后选 project/project.godot
# 方式 B：命令行直接打开
& "$env:LOCALAPPDATA\Programs\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe" --path "C:\Users\ASUS\Desktop\Palard-ZMD\project" --editor
```

### 运行游戏

**两种关卡：**

| 关卡 | 启动方式 | 用途 |
|---|---|---|
| **手写测试关** | 直接运行项目 | 布局固定，供自动化测试使用 |
| **程序化生成关** | 桌面「Palard-ZMD 生成关卡」 | 每按 `R` 换一层，验证层内连通可回退 |

```powershell
# 手写测试关（默认主场景）
& "$env:LOCALAPPDATA\Programs\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe" --path "C:\Users\ASUS\Desktop\Palard-ZMD\project"

# 程序化生成关
& "$env:LOCALAPPDATA\Programs\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe" --path "C:\Users\ASUS\Desktop\Palard-ZMD\project" res://scenes/world/generated_level.tscn
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

### 跑全部测试

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\ASUS\Desktop\Palard-ZMD\tools\run-tests.ps1"
```

当前 10 个测试套件，共 66 项断言：

| 套件 | 覆盖 | 断言数 |
|---|---|---|
| 键位绑定 | 7 个动作的物理键码与设计一致 | 7 |
| 移动物理 | 落地精度 / 跳跃高度 / 最大速度 | 8 |
| 攻击系统 | 三段连击 / 伤害 / 顿帧 / 回位 | 6 |
| 冲刺与受击 | 冲刺位移 / 无敌免疫 / 扣血 / 硬直 / 受击无敌 | 9 |
| 相机跟随 | 唯一相机 / 死区内不动 / 超出后迅速跟上 | 6 |
| 敌人攻击 | 集成验证：前摇 → 攻击盒 → 玩家实际掉血 | 4 |
| 敌人 AI | 主动追击 / 前摇 / 攻击 / 逃跑时不被甩开 | 8 |
| 战斗闭环 | 击杀计数 / 死亡结算 / 重开重置 / 清场 | 9 |
| 连通图验证 | 1000 种子：连通性 / 环路 / 捷径 / 规模 | 4 |
| 生成关卡 | 门洞可通行 / 相机覆盖 / 跨越房间边界 | 5 |

---

## 操作键位

| 动作 | 按键 |
|---|---|
| 移动 | `W` `A` `S` `D` 或方向键 |
| 跳跃 | `Space` |
| 攻击 | `J` |
| 冲刺（带无敌帧） | `L` |
| 调参面板 | `F1` |
| 面板内保存 / 重置 | `F5` / `R` |
| 重生 | `R` |
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
