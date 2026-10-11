# 作业工作流 skill

> 本项目由 AI 生成。

English: [README.md](README.md) · [Usage guide](docs/usage.md)

一套 Cursor skill，让开发者在 AI 协助下自己写代码、真正掌握代码。流程类似学校布置作业：AI 负责设计、答疑和批改，代码由你自己写。

各 skill 的使用场景与提示词见 [使用指南](docs/usage.zh-CN.md)。

```
                     +-----------+
                     |  hw-plan  |  （可选）大需求拆成多个作业
                     +-----+-----+
                           v
                     +-----------+
                     | hw-assign |  布置作业：设计 + 验收标准 + 进度清单
                     +-----+-----+
                           |
          +----------------+----------------+
          v                v                v
    +-----------+   +-------------+   （自己写代码）
    |  hw-hint  |   | hw-progress |
    +-----------+   +-------------+
      卡住求助         中期检查
          |                |
          +-------+--------+
                  v
            +-----------+   需修改
            | hw-review | ---------> 回去改
            +-----+-----+
                  | 通过
                  v
            +------------+
            | hw-archive |  归档，合并回项目大纲
            +------------+
```

## 六个 skill

| skill | 用途 | 怎么触发 |
|---|---|---|
| `hw-plan` | 对话式规划项目，把需求拆成有依赖关系的作业，产出 `plan.md`；也用于中途重新规划 | "规划项目""这个需求太大帮我拆一下" |
| `hw-assign` | 读代码，按档位布置单个作业 | "布置作业""我想自己实现 X，帮我设计" |
| `hw-hint` | 分级提示：方向 → 思路 → 片段，级别跨对话延续 | "卡住了""给点提示" |
| `hw-progress` | 查看作业列表；中期检查进度，发现偏离时预警 | "我做到哪了""中期检查" |
| `hw-review` | 对照验收标准批改，评估偏离，可选答辩，只批不改 | "交作业""我写完了" |
| `hw-archive` | 归档已通过的作业 | 只能手动调用 `hw-archive` |

## 三档脚手架

| 档位 | 给什么 | 适合 |
|---|---|---|
| 架构档 | 模块划分、职责、数据流、验收标准 | 熟悉的领域，接口也自己定 |
| 规格档（默认） | 架构档 + 接口签名、数据结构、关键思路、边界情况 | 一般任务 |
| 骨架档 | 规格档 + 文件落位、只含签名和 TODO 的函数桩、难点伪代码 | 陌生领域或新技术栈 |

无论哪一档，AI 都不会写出可运行的业务实现。

## 几条核心规则

- **设计是建议，不是合同**：可以偏离设计，批改时说明理由即可，理由合理的偏离会被认可并回写到设计里。
- **答辩可选**：在 `.homework/config.yaml` 中设置默认值，或者交作业时说"批改并答辩"。答辩只标出理解薄弱点，不会单独导致打回。
- **文件是唯一的记忆**：每个 skill 都只凭作业文件和 git 恢复上下文，换一个新对话也能接着做。
- **守护规则**：在新对话里直接让 AI 实现作业范围内的代码时，AI 会先提醒你；你确认后照做，并记为"AI 代写"。

## 安装

```bash
git clone https://github.com/Phi1ippa/homework-workflow-skills.git
cd homework-workflow-skills
```

Windows：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/install.ps1
```

macOS / Linux：

```bash
bash scripts/install.sh
```

脚本会把 `skills/` 下的 7 个目录（6 个 skill 加共享约定 `homework-shared`）复制到 `~/.cursor/skills/`，同名目录会被覆盖，其他 skill 不受影响。6 个 skill 都依赖 `homework-shared`，请整体安装，不要单独复制某一个。

更新时修改本仓库中的源码，再重新运行安装脚本。

## 卸载

```powershell
powershell -ExecutionPolicy Bypass -File scripts/install.ps1 -Uninstall
```

```bash
bash scripts/install.sh --uninstall
```

## 在目标项目中会产生的文件

目标项目必须是 git 仓库。

```
<目标项目>/
  .homework/
    config.yaml
    projects/<项目>/plan.md
    tasks/<作业>/
      meta.yaml  assignment.md  hints.md  progress.md  reviews/
    archive/YYYY-MM-DD-<作业>/
  .cursor/rules/homework-guard.mdc
```

`.homework/` 和 `homework-guard.mdc` 会被写进目标项目的 `.git/info/exclude`。这是 git 的本地忽略文件，所以这些文件不会出现在 `git status` 里，也不会被提交，项目的 `.gitignore` 不会被修改。

骨架档在你同意后，会创建一个只含函数桩的提交（`hw(<作业名>): scaffold stubs`），作为作业的起点。

## 仓库结构

```
skills/
  homework-shared/   共享约定 conventions.md 与 templates/
  hw-*/SKILL.md      六个 skill
scripts/             安装脚本
docs/usage.md        英文使用指南
docs/usage.zh-CN.md  中文使用指南
docs/testing.md      端到端测试指引（英文）
README.zh-CN.md      本文件
```
