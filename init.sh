#!/usr/bin/env bash
# 专升本仓库自检：改动后、声称"完成"前跑一次。
# 期望：全部检查通过（exit 0）。
set -u

fail=0

echo "== [1/4] 运行环境 =="
command -v node >/dev/null 2>&1 || { echo "MISSING: node"; fail=1; }
node --version

echo "== [2/4] *.mjs 语法检查 =="
for f in *.mjs; do
  [ -e "$f" ] || continue
  if node --check "$f" >/dev/null 2>&1; then
    echo "OK   $f"
  else
    echo "FAIL $f (语法错误)"; fail=1
  fi
done

echo "== [3/4] 错题本不应被 git 跟踪 =="
tracked=$(git ls-files | grep -F "错题本.md" || true)
if [ -z "$tracked" ]; then
  echo "OK   错题本.md 未被跟踪"
else
  echo "WARN 发现被跟踪的错题本.md:"; echo "$tracked"; fail=1
fi

echo "== [4/4] 各科数据源存在性 =="
for d in 计算机 英语 高数; do
  for f in "$d/题库.md" "$d/题库页.html" "$d/错题集/错题本.md"; do
    if [ -e "$f" ]; then echo "OK   $f"; else echo "WARN $f 缺失"; fi
  done
done

echo ""
if [ "$fail" -eq 0 ]; then
  echo "✅ init：全部通过"
else
  echo "❌ init：存在失败项（见上）"
fi
exit "$fail"