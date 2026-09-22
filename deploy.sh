#!/bin/bash
# ============================================================
# Perohub - 一键部署到 Netlify
# 使用方法: bash deploy.sh
# ============================================================

set -e

# 配置
NETLIFY_TOKEN="nfp_PNGboeHuudmziBbJCX4Tvb23UidoPW5847e2"
SITE_ID="9460b832-2728-4a18-af3d-71bceac72b3a"
SITE_URL="https://perohub.netlify.app"
SOURCE_FILE="/workspace/perohub.html"
DEPLOY_DIR="/workspace/deploy"

echo "🚀 开始部署 Perohub 到 Netlify..."
echo ""

# 1. 准备部署文件
echo "📦 准备部署文件..."
mkdir -p "$DEPLOY_DIR"
cp "$SOURCE_FILE" "$DEPLOY_DIR/index.html"

# 写入 headers 配置（确保 HTML 文件以正确的 Content-Type 提供）
cat > "$DEPLOY_DIR/_headers" << 'EOF'
/*.html
  Content-Type: text/html; charset=UTF-8

/
  Content-Type: text/html; charset=UTF-8
EOF

# 2. 打包 zip
cd "$DEPLOY_DIR"
rm -f deploy.zip
zip -q deploy.zip index.html _headers

echo "✅ 文件已打包 ($(du -h deploy.zip | cut -f1))"

# 3. 上传部署
echo "☁️  上传到 Netlify..."
RESPONSE=$(curl -s -X POST "https://api.netlify.com/api/v1/sites/$SITE_ID/deploys" \
  -H "Authorization: Bearer $NETLIFY_TOKEN" \
  -H "Content-Type: application/zip" \
  --data-binary @deploy.zip)

# 4. 提取部署信息
DEPLOY_ID=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
DEPLOY_URL=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('deploy_url',''))" 2>/dev/null)

if [ -z "$DEPLOY_ID" ]; then
  echo "❌ 部署失败!"
  echo "$RESPONSE"
  exit 1
fi

# 5. 等待部署完成
echo "⏳ 等待部署完成..."
for i in {1..30}; do
  sleep 2
  STATE=$(curl -s "https://api.netlify.com/api/v1/sites/$SITE_ID/deploys/$DEPLOY_ID" \
    -H "Authorization: Bearer $NETLIFY_TOKEN" \
    | python3 -c "import sys,json; print(json.load(sys.stdin).get('state',''))" 2>/dev/null)
  
  if [ "$STATE" = "ready" ]; then
    echo ""
    echo "🎉 部署成功!"
    echo ""
    echo "🌐 在线地址: $SITE_URL"
    echo "🔗 本次部署: $DEPLOY_URL"
    echo ""
    exit 0
  elif [ "$STATE" = "error" ] || [ "$STATE" = "failed" ]; then
    echo "❌ 部署失败!"
    exit 1
  fi
  
  echo -n "."
done

echo ""
echo "⚠️  部署超时，但文件已上传，请稍后访问: $SITE_URL"
