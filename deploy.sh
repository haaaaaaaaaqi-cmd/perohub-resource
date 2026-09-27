#!/bin/bash
# ============================================================
# Perohub - 一键部署到 Vercel
# 使用方法: bash deploy.sh
# ============================================================

set -e

# 配置
# 请设置环境变量 VERCEL_TOKEN，或在此处填入你的 Vercel Token
VERCEL_TOKEN="${VERCEL_TOKEN}"
PROJECT_ID="prj_28s5FeAyVjOPf01sNU8EcGPSPt2N"
ORG_ID="team_sQE3owTSTlD0AwZCKIYRnyNQ"
SITE_URL="https://perohub-perohub1.vercel.app"
SOURCE_FILE="${SOURCE_FILE:-$(dirname "$0")/perohub.html}"
WORK_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -z "$VERCEL_TOKEN" ]; then
  echo "❌ 错误: 请先设置 VERCEL_TOKEN 环境变量"
  echo "   例如: export VERCEL_TOKEN='你的token'"
  exit 1
fi

echo "🚀 开始部署 Perohub 到 Vercel..."
echo ""

# 1. 准备部署文件
echo "📦 准备部署文件..."
cd "$WORK_DIR"
cp "$SOURCE_FILE" index.html

# 写入 Vercel 配置
cat > vercel.json << 'EOF'
{
  "cleanUrls": true,
  "trailingSlash": false
}
EOF

# 链接项目
mkdir -p .vercel
cat > .vercel/project.json << EOF
{"projectId":"$PROJECT_ID","orgId":"$ORG_ID"}
EOF

echo "✅ 准备完成"

# 2. 部署
echo "☁️  部署到 Vercel..."
npx vercel deploy --prod --yes --token="$VERCEL_TOKEN"

echo ""
echo "🎉 部署成功!"
echo ""
echo "🌐 在线地址: $SITE_URL"
echo ""
