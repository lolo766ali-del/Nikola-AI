#!/bin/bash
# ════════════════════════════════════════════════════════════
#  Nikolas MEGA — سكريبت التشغيل لـ Termux/Andronix
# ════════════════════════════════════════════════════════════

echo "🚀 تشغيل Nikolas MEGA v2400..."
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

# فحص Python
if ! command -v python3 &>/dev/null; then
    echo "❌ Python3 غير موجود"
    echo "في Termux: pkg install python"
    echo "في Andronix: apt install python3"
    exit 1
fi

# تثبيت المكتبات الأساسية
echo "📦 فحص المكتبات..."
python3 -c "import fastapi" 2>/dev/null || pip install fastapi --break-system-packages -q
python3 -c "import uvicorn" 2>/dev/null || pip install uvicorn --break-system-packages -q
python3 -c "import aiohttp"  2>/dev/null || pip install aiohttp  --break-system-packages -q
python3 -c "import websockets" 2>/dev/null || pip install websockets --break-system-packages -q

echo "✅ المكتبات جاهزة"
echo ""
echo "══════════════════════════════════════════"
echo "  🌐 افتح في المتصفح بعد التشغيل:"
echo "     http://localhost:8080"
echo "     أو افتح: omni_ultimate_v2_mega.html"
echo "══════════════════════════════════════════"
echo ""

python3 nikolas_mega.py
