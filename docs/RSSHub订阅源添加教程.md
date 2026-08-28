# RSSHub 订阅源添加教程（TrendRadar 专属）

> 适用场景：你想定点追踪「某个具体博主 / 公众号 / UP 主 / 频道」的热点，而不是只追新闻热榜。
> 修改文件：`config/config.yaml` 里的 `rss.feeds` 段。本地改完 → 推送到 GitHub → 云端下次 Actions 自动生效。

---

## 一、RSSHub 是什么

RSSHub 是一个开源项目，作用是**把没有 RSS 的网站（微博、B站、公众号、小红书、抖音、知乎、YouTube 等）转成标准 RSS 链接**。

TrendRadar 的 `config/config.yaml` 里有一段 `rss.feeds`，就是专门放这些 RSS 链接的地方。只要把源加进去，TrendRadar 每次运行就会去抓这些源的最新内容，经过你的关键词筛选 + AI 分类后推到飞书。

---

## 二、为什么需要它

你之前飞书里收到的那些平台（V2EX、稀土掘金、少数派等）基本是 **newsnow 热榜**——也就是「当下全网最热的话题」。

但「某个具体博主发了什么」**不在热榜里**，热榜只反映大众热度。所以：

| 你想追踪的 | 该用 |
|---|---|
| 全网都在热议的大事件 | newsnow 热榜（config.yaml 的 `platforms`） |
| 某个具体博主/公众号/UP主 | **RSS（RSSHub 生成）** ← 本教程 |
| 某个垂类媒体专栏 | RSS（原始 RSS 或 RSSHub） |

**一句话**：想盯「人」，用 RSS；想盯「大势」，用热榜。两者互补。

> ⚠️ **X / Twitter 已死**：官方 API 收费后，RSSHub 的 twitter 路由基本失效，别在它上面浪费时间。

---

## 三、两种用法：公共实例 vs 自建

### 1. 公共实例（新手推荐，先用这个）
- 官方：`https://rsshub.app`
- 国内常见社区实例：`https://rsshub.rssforever.com` 等
- 用法：把下面表格里的路由拼在实例域名后面即可，例如 `https://rsshub.app/weibo/user/123456`
- **缺点**：有反爬限流、免费额度有限，挂太多源会偶发抽风；国内访问 `rsshub.app` 有时不稳。

### 2. 自建（稳定不限流，进阶）
- 用 Docker 一行起：`docker run -d --name rsshub -p 1200:1200 diygod/rsshub`
- 起好后用 `http://你的IP:1200/路由` 代替 `https://rsshub.app/路由`
- 文档详见官方 README「自建」章节。
- 对磊哥的建议：**先用公共实例**，跑不起来或老抽风再考虑自建（占你一点机器资源，但 TrendRadar 本身就在用 Docker 思路，不冲突）。

---

## 四、平台 ID / 路由怎么找（核心）

每种平台有固定的「路由格式」，你只要把里面的「用户 ID」填进去。下面列出最常用平台的提取方法 + URL 模板（以官方实例 `rsshub.app` 为例，自建把域名换成你的即可）。

| 平台 | 怎么找 ID | RSSHub URL 模板 |
|---|---|---|
| **微博用户** | 打开博主主页，URL 里 `weibo.com/u/1234567890` 的数字，或昵称 `weibo.com/昵称` | `https://rsshub.app/weibo/user/1234567890`<br>`https://rsshub.app/weibo/user/昵称` |
| **B站 UP 主** | 主页 URL `space.bilibili.com/123456` 里的数字 | `https://rsshub.app/bilibili/user/dynamic/123456` |
| **知乎用户** | 主页 `zhihu.com/people/xxx` 里的 `xxx` | `https://rsshub.app/zhihu/people/activities/xxx` |
| **YouTube 频道** | 频道 URL 里的 `@handle` 或 `UCxxxx` | `https://rsshub.app/youtube/channel/UCxxxx`<br>`https://rsshub.app/youtube/user/xxx` |
| **微信公众号** | 官方路由不稳，推荐第三方 `feeddd.cn`：把公众号名/微信号粘进去生成 RSS | `https://feeddd.cn/feed/公众号ID.xml` |
| **小红书用户** | 主页分享链接里的用户 ID（公共实例常失效，建议用专用第三方） | `https://rsshub.app/xiaohongshu/user/用户ID` |
| **抖音用户** | 主页 `douyin.com/user/xxx` 的 sec_uid（需抓包，较难） | `https://rsshub.app/douyin/user/xxx` |

> **稳定性排序**：B站 / 知乎 / YouTube > 微博 > 小红书 / 抖音 / 公众号（公共实例上经常挂）。
> 小红书、抖音、公众号优先用专用第三方源（如 feeddd），或在公共实例抽风时放弃这些源。

---

## 五、在 TrendRadar 里添加（改哪个文件、什么格式）

**改的文件**：`config/config.yaml`（在项目根目录的 `config` 文件夹里）。

找到文件里的 `rss:` 段，在 `feeds:` 下面按「两行一组」添加：

```yaml
rss:
  enabled: true
  feeds:
    # ── 已有的源（示例） ──
    - name: "少数派"
      url: "https://rsshub.app/sspai/index"

    # ── 你新增的源（照抄格式） ──
    - name: "孙宇晨微博"          # 飞书里显示的名字，中文随意起
      url: "https://rsshub.app/weibo/user/这里填UID"

    - name: "某科技公众号"
      url: "https://feeddd.cn/feed/这里填公众号ID.xml"
```

**格式要求（必须照做，否则 YAML 解析报错）**：
- 每个源占 **两行**：`name:`（显示名，中文随意）+ `url:`（RSS 链接）。
- 缩进用 **空格**（和文件里其它行对齐，一般 4 个空格），**绝不能用 Tab**。
- `url:` 必须是**真正以 `http` 开头的 RSS 链接**，不能是博主主页的 HTML 网址。
- 一组和一组之间不用空行也能跑，但加个空行更清晰。
- 改完保存 → 推送到 GitHub → 下次 Actions 跑就自动抓取。

---

## 六、验证方法（改完别干等，先验证）

### 方法 A：本地先验证（最快，不用等 Actions）
在项目根目录开终端，运行：
```bash
uv run python -m trendradar
```
看日志里有没有「RSS 抓取 / rss」相关行，以及你的源名字有没有出现；飞书有没有收到对应内容。
（如果本地没装 uv，用你之前的方式跑也行。）

### 方法 B：云端验证
- GitHub 仓库 → **Actions** → 最新一次 **"Get Hot News"** run → 点进去看日志。
- 找 RSS 相关 step：有内容 = 源有效；报红 × / 解析失败 = 链接挂了或被限流。

---

## 七、常见坑（踩过一次就懂）

1. **链接是博主主页不是 RSS** → 飞书收不到，日志报「解析失败 / 不是有效 feed」。必须是 RSS 链接。
2. **公共实例限流** → 部分源偶尔为空。可多挂几个社区实例轮换，或直接自建。
3. **公众号 / 小红书 / 抖音在公共 RSSHub 经常失效** → 用 feeddd 等专用第三方，或干脆放弃这些源。
4. **X / Twitter 已死** → 别加，加了也是空。
5. **缩进用了 Tab** → YAML 直接报错，整个爬虫跑不起来。用空格。

---

## 八、想让我帮你加？发我这两样就行

1. **订阅链接**（RSSHub 生成的，或原始 RSS 链接）
2. **想在飞书显示的名字**

我直接加进 `config/config.yaml` 的 `rss.feeds` 并推送到 GitHub，下次 Actions 运行就自动抓取推送。
