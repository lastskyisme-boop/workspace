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
fi
exit 0
