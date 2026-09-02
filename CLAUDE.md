# 先看这个

这个仓库（`lastskyisme-boop/workspace`）本身是空壳，只是 Claude Code 会话的挂载点。
**真正的产品代码在 Gitee，不在这里**——每个新会话第一件事，是把它克隆下来：

```bash
cd /home/user && git -c credential.helper='!f() { echo username=oauth2; echo "password=$GITEE_TOKEN"; }; f' \
  clone https://gitee.com/wangfeng94/jp-dojo.git
```

`GITEE_TOKEN`、`VERCEL_TOKEN`、`AZURE_TTS_KEY` 已经配在环境变量里，克隆、部署、合成发音
都不用问用户要密钥。**环境变量是会话启动那一刻抄进去的**——用户刚加的变量，当前会话读不到，
要开新会话才有。

克隆完之后，**先读 `jp-dojo/docs/backlog.md`**——待办、为什么想做、卡在哪、本周任务，
都集中在那一份里，是这个项目"接下来做什么"的唯一权威来源，比这份 CLAUDE.md 新得多。
如果需要更早的背景，`jp-dojo/docs/handoff-*.md` 是历史交接记录，按日期排的。

提交署名用 `qq694 <lastskyisme@gmail.com>`；改完代码要推的话推 Gitee 的
`jp-dojo` 仓库（不是这个 workspace 仓库）。改完自己部署，不用问用户——
命令和两个必踩的坑写在 `jp-dojo/jp-trainer-webapp/CLAUDE.md` 的「交流方式」里。

这个环境的能力边界（碰到类似情况不用重新试错）：
- **能**：拉/改/提交/推 Gitee 代码，`npm run build` / 跑那 30 个验证脚本，
  用 Vercel CLI 从 `jp-dojo` 仓库根目录部署到生产，`curl` 出网（走代理）访问
  Gitee / Vercel / 线上域名 / DeepSeek API / **Azure TTS**（`*.tts.speech.microsoft.com`，
  实测 334 条/分钟、零限流）/ **Supabase Storage 的 public 文件**（只读，不需要鉴权）。
- **不能**：SSH 到生产服务器（`106.52.103.28`，要作者自己上去跑）；
  Playwright/Chromium 访问外部 HTTPS 站点会 `ERR_CONNECTION_RESET`
  （2026-09-02 复验仍然如此；但 `localhost`/`127.0.0.1` 可以，本地 vite + Playwright 能跑）。
- **SQL 怎么跑**（2026-09-01 起变了）：**Supabase 云控制台已经永久进不去**
  （作者的账号是 GitHub OAuth 注册的，GitHub 被封找不回），所以**别再说"你去 SQL Editor 跑"**。
  现在的路子是作者 ssh 上服务器、用 docker + psql 跑，连接串在 `~/backup/.pgurl`，
  跑法写在 `jp-dojo/docs/自托管部署.md`。给的 SQL 照旧要幂等、带验证查询。
  背景和它带来的一串后果（免费项目闲置 7 天会暂停且无法恢复、迁移前必须把云端要的东西
  拿干净）看 backlog 的 **E0**，那是目前最要紧的一条运维约束。

有什么新想法、发现了新问题，随手记进 `jp-dojo/docs/backlog.md`，别指望聊天记录能留到下次。
