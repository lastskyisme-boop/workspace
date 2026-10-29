# 先看这个

这个仓库（`lastskyisme-boop/workspace`）本身是空壳，只是 Claude Code 会话的挂载点。
**真正的产品代码在 Gitee，不在这里**。会话启动时 `.claude/hooks/clone-jp-dojo.sh`
会自动把它克隆/更新到 `/home/user/jp-dojo`，开场看到「jp-dojo 已就绪」就**不用再克隆**。
只有看到「自动克隆失败」或目录不存在时，才手动跑：

```bash
cd /home/user && git -c credential.helper='!f() { echo username=oauth2; echo "password=$GITEE_TOKEN"; }; f' \
  clone https://gitee.com/wangfeng94/jp-dojo.git
```

`GITEE_TOKEN`、`VERCEL_TOKEN` 已经配在环境变量里，克隆和部署都不用问用户要密钥。

克隆完之后，**先读 `jp-dojo/docs/backlog.md`**——待办、为什么想做、卡在哪、本周任务，
都集中在那一份里，是这个项目"接下来做什么"的唯一权威来源，比这份 CLAUDE.md 新得多。
**开场只读 `backlog.md` 这一份**，别通读 `backlog-archive.md` 和 `handoff-*.md`——
只有要动某一条、backlog 里指过去时，才去读对应那一段。用户给了具体任务时，
直接从相关代码下手，不用先把整个项目摸一遍。

提交署名用 `qq694 <lastskyisme@gmail.com>`；改完代码要推的话推 Gitee 的
`jp-dojo` 仓库（不是这个 workspace 仓库）。

这个环境的能力边界（碰到类似情况不用重新试错）：
- **能**：拉/改/提交/推 Gitee 代码，`npm run build`/跑本地测试脚本，
  用 Vercel CLI 从 `jp-dojo` 仓库根目录部署到生产，`curl` 出网（走代理）访问
  Gitee/Vercel/线上域名/DeepSeek API。
- **不能**：SSH 到生产服务器；直接执行 SQL（写好后交给用户去 Supabase SQL Editor 跑，
  给的 SQL 要单条、幂等、带验证查询）；Playwright/Chromium 访问外部 HTTPS 站点会
  `ERR_CONNECTION_RESET`（但 `localhost`/`127.0.0.1` 可以，本地 vite + Playwright 能跑）。

界面设计检查用 impeccable(`.claude/skills/impeccable`,10-29 装的,没装钩子):
- 检测器在 `/home/user/workspace` 下跑才会读到 `.impeccable/config.json` 里的忽略名单(米色底、左侧色条、青海波这些是有意的设计)。
- 扫网页:`IMPECCABLE_BROWSER` 由启动脚本设好;应用内页面要先起 vite,用 `e2e-harness.html` 跳过登录,再 `detect --cdp <端口>`。
- 会话启动脚本已建好假 `.env`、装好依赖,`npm run test:*` 直接能跑。

有什么新想法、发现了新问题，随手记进 `jp-dojo/docs/backlog.md`，别指望聊天记录能留到下次。
