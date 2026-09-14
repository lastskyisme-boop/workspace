# 先看这个

这个仓库（`lastskyisme-boop/workspace`）本身是空壳，只是 Claude Code 会话的挂载点。
**真正的产品代码在 Gitee，不在这里**——每个新会话第一件事，是把它克隆下来：

```bash
cd /home/user && git -c credential.helper='!f() { echo username=oauth2; echo "password=$GITEE_TOKEN"; }; f' \
  clone https://gitee.com/wangfeng94/jp-dojo.git
```

`GITEE_TOKEN` 已经配在环境变量里，拉代码和部署都不用问用户要密钥。

克隆完之后，**先读 `jp-dojo/docs/backlog.md`**——待办、为什么想做、卡在哪、本周任务，
都集中在那一份里，是这个项目"接下来做什么"的唯一权威来源，比这份 CLAUDE.md 新得多。
如果需要更早的背景，`jp-dojo/docs/handoff-*.md` 是历史交接记录，按日期排的。

⚠️ **这份文件只管"沙箱里能做什么"。产品本身的规矩在 `jp-dojo/jp-trainer-webapp/CLAUDE.md`，
那份是权威**——两边对不上时以那份为准，并且**顺手回来把这份改掉**。
2026-09-14 吃过一次亏：这份还写着"用 Vercel CLI 部署"（割接前的老说法），
于是照着去改了 `vercel.json`，而那个文件早就不参与部署了。

提交署名用 `qq694 <lastskyisme@gmail.com>`；改完代码要推的话推 Gitee 的
`jp-dojo` 仓库（不是这个 workspace 仓库）。

## 上线：推 `deploy` 分支，不是 `vercel --prod`

**2026-09-06 割接到自托管之后，线上是广州那台腾讯云轻量服务器**
（`juxingdaochang.cn`，应用 :8080 + 自建 Supabase :8000 同机），**不是 Vercel**。
Vercel 上那份只服务过 `juxingdaochang.online`，9/13 已停用、作者决定不再补部署。
**去跑 `vercel --prod`，CLI 会说成功、线上一点不会变**——看起来成功，其实没上线。

沙箱连不上 22 端口、SSH 不了服务器，所以做法是**反过来让服务器自己拉**：
它每 2 分钟看一眼 Gitee 的 `deploy` 分支，指到哪个提交就跑哪个。
**移动 `deploy` 分支就是按下上线按钮**：

```bash
# ①「写完了」——一天推十几次都行，不会上线
git push origin main
# ②「验过了可以上线」——这一步才是上线
git push -f origin <sha>:deploy
```

部署完**自己验证**，判据不是"包名变了"：

```bash
curl -sS https://juxingdaochang.cn/deploy-status.json
# status 要是 ok（不是 build-failed / rolled-back / deps-failed），sha 要是你推的那个
curl -sS https://juxingdaochang.cn/assets/index-XXXX.js | grep <这次新加的字符串>
```

细节（构建到 `dist.new`、健康检查、自动回滚）见 `jp-dojo/deploy/deploy.sh` 和
`jp-trainer-webapp/CLAUDE.md`「交流方式」那节。**那份里写着「改完自己部署，不要问我」。**

⚠️ 推 `deploy` 前先看一眼 `main` 上有没有**别的会话留下的、还没上线的提交**——
按上面这么推会把它们一起发出去。要发就先把它们的守卫跑一遍，并且在汇报里说清楚。

## ⚠️ 「不用 Vercel 了」≠「不用 Supabase 了」

这两件事经常被一起说掉，但只有前半句是真的：

- **Vercel**：2026-09-14 起彻底没关系了。`.online` 已停用，`vercel.json` 不参与部署，
  账号上不服务任何生产流量。**看到 `vercel` 字样一律当历史遗留。**
- **Supabase**：脱离的只是 **Supabase 云**（那个控制台 2026-09-01 起永久进不去，见 backlog E0）。
  **自建的那一套还是这个产品的心脏** —— 广州那台 `~/supabase-self` 跑着
  `db / meta / rest / auth / api-gw / studio` 六个容器，登录、注册、全部业务数据、
  每一次读写都走它；`src/supabaseClient.js` 和 `shared/apiAuth.js` 都在调。
  **改 schema、改登录设置、查数据，以后还是天天要碰 Supabase**，
  只是路径从「云控制台」换成了「`docker exec psql` / 改 `~/supabase-self/.env`」（见下）。

## 这个环境的能力边界（碰到类似情况不用重新试错）

**能**：
- 拉/改/提交/推 Gitee 代码；`npm run build`；跑仓库里那 50 来个守卫脚本
- 推 `deploy` 分支上线，并 `curl` 线上域名验证（见上）
- `curl` 出网（走代理）访问 Gitee / 线上域名 / DeepSeek API
- **Playwright + Chromium 跑本地 vite**（那批守卫有一半靠它）。两个坑：
  - 默认那条路径是坏的（报 `Executable doesn't exist … chromium_headless_shell-1234`）。
    **传** `CHROMIUM_PATH=/opt/pw-browsers/chromium-1194/chrome-linux/chrome`，
    别去跑 `npx playwright install`。
  - **先建一份内容随便的 `.env`**（要有 `VITE_SUPABASE_URL` / `VITE_SUPABASE_ANON_KEY`，
    值可以是假的），否则起浏览器那批守卫全红在 `supabaseUrl is required` ——
    一次红一大片最像"是不是我改坏了"。见 `docs/lessons.md#guard-fake-env`。
  - 守卫之间**端口写死**（`--strictPort`），两个守卫同时跑会互相打死，一个一个来。

**不能**：
- SSH 到生产服务器（22 端口不通）
- Playwright/Chromium 访问**外部** HTTPS 站点（`ERR_CONNECTION_RESET`）；
  `localhost`/`127.0.0.1` 可以
- **直接执行 SQL**。写好之后交给用户，让他在**服务器上**跑：

  ```bash
  cd ~/jp-dojo && git pull origin main
  docker exec -i supabase-db psql -U postgres -d postgres -1 -v ON_ERROR_STOP=1 \
    < jp-trainer-webapp/supabase/schema.sql
  ```

  🚨 **不要再让他去"Supabase 控制台的 SQL Editor"**——云端那份控制台
  2026-09-01 起永久进不去了（账号走 GitHub OAuth，GitHub 被封找不回，见 backlog E0），
  而数据库已经在 2026-09-07 割接到自建那套。命令行是唯一不依赖控制台的路。
  给的 SQL 要**单条、幂等、带验证查询**；`-1 -v ON_ERROR_STOP=1` 不能省（单事务+遇错即停）。
  写给别人抄的命令里**不要用 `<占位符>`**，bash 会把 `<` 当重定向，报错完全不像占位符没替换。
  完整说明见 `docs/自托管部署.md`「跑 SQL」那节。

有什么新想法、发现了新问题，随手记进 `jp-dojo/docs/backlog.md`，别指望聊天记录能留到下次。
