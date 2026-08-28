# GitHub Actions 未按时推送排查手册（TrendRadar）

> 症状：飞书某天开始不推了 / 到了设定时间没收到 / 怀疑 Actions 挂了。
> 适用：磊哥的 `652900956/TrendRadar-Windows` 仓库，云端 `Get Hot News` 工作流。

---

## 先记住一句话（最重要）

TrendRadar 官方版是 **「试用制」**：每 **7 天**必须「签到」一次，否则 **"Get Hot News" 工作流会被自动禁用**，飞书就再也不推了。

**90% 的「没推送」都是这个原因** —— 不是代码错了，是你忘了签到。

---

## 一、常见原因 Top 榜（按发生频率）

| 排序 | 原因 | 一句话判断 |
|---|---|---|
| 1 | **7 天试用期到期，工作流被禁用** | Actions 里 "Get Hot News" 显示 Disabled |
| 2 | cron 时区理解错 | 你以为北京 X 点，其实配的是 UTC |
| 3 | Secret 缺失（FEISHU_WEBHOOK_URL 等） | Settings → Secrets 里少了某个 |
| 4 | 代码没推到 main 分支 | 本地改了没 push，或推到别的分子 |
| 5 | 仓库被归档 / Actions 被关 / 私有库额度用完 | 仓库设置里看 |
| 6 | 上游 newsnow 平台 500 | 个别平台失败，日志标红，但不影响整体 |
| 7 | concurrency 取消上一次运行 | 很少见，两条同时跑会取消旧的 |

---

## 二、逐步排查（按顺序来，别跳）

### 第 1 步：看工作流是不是被「禁用」了 ← 先看这个
1. 进 GitHub 仓库 → 顶部点 **Actions**。
2. 左侧列表找 **"Get Hot News"**。
3. 如果它是**灰的 / 旁边写 "Disabled"** → 就是 7 天到期被禁了。

**解决方法（二选一）：**
- **网页**：左侧点 **"Check In"**（这是 `clean-crawler.yml` 工作流）→ 右边点 **"Run workflow"** → 确认运行。它会清空历史运行记录、重置 7 天计时、并自动重新启用 "Get Hot News"。
- **命令行**（需 `gh` 已登录）：
  ```bash
  gh workflow enable crawler
  ```

> 原理：过期检查看的是「最早一次运行时间」。Check In 清空所有运行记录后，下一次 crawler 运行就成了新的「第一次」，7 天计时重新开始。

### 第 2 步：确认下次运行时间（别被时区骗）
- Actions → 点 "Get Hot News" → 页面里会显示下次触发时间（**GitHub 显示的是 UTC**）。
- 我们现在的配置（北京时间）：**07:00 / 12:30 / 20:30**
- 对应 UTC：**23:00（前日）/ 04:30 / 12:30**
- 所以你在 GitHub 上看到的下次时间如果是 `04:30` 或 `12:30` 或 `23:00`，都是对的，别以为是没生效。

### 第 3 步：看最近一次 run 的日志
- Actions → "Get Hot News" → 点最新一条 → 看每个 step：
  - **Check Expiration** 步：出现 `Trial expired` → 被禁用（回到第 1 步）。
  - **Run crawler** 步：看到 `[AI] 模型: ...` 和 `飞书发送` → 成功跑完。
  - 任何**红色 ×** 的 step → 点开看具体报错。

### 第 4 步：检查 Secrets 是否齐全
- 仓库 → **Settings** → **Secrets and variables** → **Actions**。
- 必看这几个在不在：`FEISHU_WEBHOOK_URL`、`AI_API_KEY`、`AI_MODEL`。
- 缺了就补：网页点 `New repository secret`，或命令行：
  ```bash
  gh secret set FEISHU_WEBHOOK_URL
  ```
  （执行后会让你粘贴值，粘贴完回车。）
- 注意：Secret **值不会显示**，只能看到名字在不在。

### 第 5 步：确认代码已推送
- 仓库首页看「最新 commit 时间」是否和你本地改动一致。
- 本地改了没 push = 云端还在跑旧配置。
- 本地命令行确认：
  ```bash
  git -C 你的项目目录 status     # 看有没有未提交
  git -C 你的项目目录 log -1     # 看最新提交
  ```

### 第 6 步：手动触发一次验证
- Actions → "Get Hot News" → **"Run workflow"** → 立即跑一次。
- 能收到飞书 = 配置没问题，只是还没到 cron 触发点（或排队中）。
- 收不到 = 看第 3 步日志定位。

---

## 三、为什么「到了点却没推」

1. **GitHub Actions 定时任务是「尽力而为」**：公共仓库在高峰时段可能延迟几分钟到几十分钟 —— 不是不跑，是在排队。
2. **连续 7 天没签到**：第 7 天结束那次之后就被禁用，后面全停（回到第 1 步）。
3. **私有仓库每月有免费额度**：你的量基本用不完；公共仓库无限但排队更明显。

---

## 四、命令速查表

| 目的 | 命令 / 操作 |
|---|---|
| 签到续期（重置 7 天） | 网页：Actions → "Check In" → Run workflow |
| 命令行启用被禁的工作流 | `gh workflow enable crawler` |
| 查看所有工作流状态 | `gh workflow list` |
| 手动跑一次 | `gh workflow run crawler` |
| 查看最近运行 | `gh run list` |

---

## 五、给磊哥的省心建议

- **手机日历设提醒**：每 7 天（比如每周日晚）签到一次 "Check In"。这是唯一会让你断推的日常操作。
- **想彻底免签到**：按官方建议自建 **Docker 版** TrendRadar，长期跑在你自己机器/服务器上，没有 7 天限制（详见 README「Docker 部署」章节）。
- **改完配置先本地验证**：`uv run python -m trendradar` 跑一遍，确认飞书能收到，再 push 到 GitHub，避免云端空跑。
