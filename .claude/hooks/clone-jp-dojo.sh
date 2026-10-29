#!/bin/bash
# 会话启动时自动把 Gitee 上的 jp-dojo 拉到 /home/user/jp-dojo,省掉每次开场让 Claude 手动克隆。
# 已经有了就更新到最新;网络抖动时重试几次。失败也不挡会话启动。
DIR=/home/user/jp-dojo
URL=https://gitee.com/wangfeng94/jp-dojo.git
[ -z "$GITEE_TOKEN" ] && { echo "jp-dojo: 没有 GITEE_TOKEN,跳过自动克隆"; exit 0; }
cred='!f() { echo username=oauth2; echo "password=$GITEE_TOKEN"; }; f'
for wait in 2 4 8 16; do
  if [ -d "$DIR/.git" ]; then
    git -C "$DIR" -c credential.helper="$cred" pull -q --ff-only 2>/dev/null && break
  else
    git -c credential.helper="$cred" clone -q "$URL" "$DIR" 2>/dev/null && break
  fi
  sleep "$wait"
done
if [ -d "$DIR/.git" ]; then
  echo "jp-dojo 已就绪: $DIR ($(git -C "$DIR" log -1 --format='%h %s'))"
else
  echo "jp-dojo 自动克隆失败,请按 CLAUDE.md 手动克隆"
  exit 0
fi

# 把测试环境备好,让 `npm run test:*` 开箱就能跑(细节见 jp-trainer-webapp/docs/lessons.md#guard-fake-env)。
# ① 假 .env:起浏览器的守卫要 vite 读到这两个变量,否则页面起不来。只在没有 .env 时建,不覆盖已有的。
#    ⚠️ 有了它,在这里 `npm run build` 出来的包连的是假地址 —— 不要拿本地 dist 去上线
#    (国内站是服务器自己拉代码构建的,不受影响)。
# ② 依赖:新容器里没有 node_modules,npm ci 约几秒。
APP="$DIR/jp-trainer-webapp"
if [ -d "$APP" ]; then
  [ -f "$APP/.env" ] || printf 'VITE_SUPABASE_URL=https://e2e.invalid\nVITE_SUPABASE_ANON_KEY=e2e-fake\n' > "$APP/.env"
  if [ ! -d "$APP/node_modules" ]; then
    ( cd "$APP" && PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 npm ci --no-audit --no-fund >/dev/null 2>&1 ) \
      && echo "测试环境已就绪(假 .env + 依赖)" || echo "npm ci 失败,跑测试前手动装一次依赖"
  fi
fi

# ③ impeccable 设计检测器扫网页要一个 Chromium;容器里是 root,Chromium 不带 --no-sandbox 起不来。
#    包一层脚本,用 IMPECCABLE_BROWSER 指过去(CLAUDE_ENV_FILE 里的变量会带进之后的每条命令)。
WRAP=/home/user/.local/bin/chrome-no-sandbox
if [ -x /opt/pw-browsers/chromium ] && [ ! -x "$WRAP" ]; then
  mkdir -p "$(dirname "$WRAP")"
  printf '#!/bin/sh\nexec /opt/pw-browsers/chromium --no-sandbox "$@"\n' > "$WRAP" && chmod +x "$WRAP"
fi
[ -n "$CLAUDE_ENV_FILE" ] && [ -x "$WRAP" ] && echo "export IMPECCABLE_BROWSER=$WRAP" >> "$CLAUDE_ENV_FILE"
exit 0
