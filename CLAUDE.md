# 先看这个

这个仓库（`lastskyisme-boop/workspace`）本身是空壳，只是 Claude Code 会话的挂载点。
**真正的产品代码在 Gitee，不在这里**——每个新会话第一件事，是把它克隆下来：

```bash
cd /home/user && git -c credential.helper='!f() { echo username=oauth2; echo "password=$GITEE_TOKEN"; }; f' \
  clone https://gitee.com/wangfeng94/jp-dojo.git
```

`GITEE_TOKEN`、`VERCEL_TOKEN` 已经配在环境变量里，克隆和部署都不用问用户要密钥。

克隆完之后，**先读 `jp-dojo/docs/backlog.md`**——待办、为什么想做、卡在哪、本周任务，
都集中在那一份里，是这个项目"接下来做什么"的唯一权威来源，比这份 CLAUDE.md 新得多。
如果需要更早的背景，`jp-dojo/docs/handoff-*.md` 是历史交接记录，按日期排的。

提交署名用 `qq694 <lastskyisme@gmail.com>`；改完代码要推的话推 Gitee 的
`jp-dojo` 仓库（不是这个 workspace 仓库）。

这个环境的能力边界（碰到类似情况不用重新试错）：
- **能**：拉/改/提交/推 Gitee 代码，`npm run build`/跑本地测试脚本，
  用 Vercel CLI 从 `jp-dojo` 仓库根目录部署到生产，`curl` 出网（走代理）访问
  Gitee/Vercel/线上域名/DeepSeek API。
- **不能**：SSH 到生产服务器；直接执行 SQL（写好后交给用户去 Supabase SQL Editor 跑，
  给的 SQL 要单条、幂等、带验证查询）；Playwright/Chromium 访问外部 HTTPS 站点会
  `ERR_CONNECTION_RESET`（但 `localhost`/`127.0.0.1` 可以，本地 vite + Playwright 能跑）。

有什么新想法、发现了新问题，随手记进 `jp-dojo/docs/backlog.md`，别指望聊天记录能留到下次。
