#!/bin/bash
# ════════════════════════════════════════════════════════════
#  Nikolas MEGA v2500 — سكريبت التشغيل لـ Termux/Andronix
#  يدعم: Termux · Andronix · UserLAnd · Ubuntu/Debian عادي
# ════════════════════════════════════════════════════════════

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

# ── ألوان ──────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;93m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

echo -e "${BOLD}${CYAN}"
echo "  ███╗   ██╗██╗██╗  ██╗ ██████╗ ██╗      █████╗ ███████╗"
echo "  ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝"
echo -e "                      MEGA v2500${RESET}"
echo ""

# ── كشف البيئة ─────────────────────────────────────────────
detect_env() {
    if [ -n "${TERMUX_VERSION:-}" ] || [ -d "/data/data/com.termux" ]; then
        echo "termux"
    elif grep -qi "ubuntu\|debian\|kali" /etc/os-release 2>/dev/null; then
        echo "ubuntu"
    else
        echo "linux"
    fi
}

ENV_TYPE=$(detect_env)
case "$ENV_TYPE" in
    termux)  echo -e "${GREEN}🤖 بيئة: Termux${RESET}" ;;
    ubuntu)  echo -e "${GREEN}🐧 بيئة: Andronix/Ubuntu${RESET}" ;;
    *)       echo -e "${GREEN}💻 بيئة: Linux عام${RESET}" ;;
esac

# ── فحص Python ─────────────────────────────────────────────
if ! command -v python3 &>/dev/null; then
    echo -e "${RED}❌ Python3 غير موجود${RESET}"
    echo "   في Termux:   pkg install python"
    echo "   في Andronix: apt install python3"
    exit 1
fi

# فحص نسخة Python >= 3.9
PY_VER=$(python3 -c "import sys; print(sys.version_info.major * 10 + sys.version_info.minor)")
if [ "$PY_VER" -lt 39 ]; then
    PY_FULL=$(python3 --version)
    echo -e "${RED}❌ Python 3.9+ مطلوب — الموجود: $PY_FULL${RESET}"
    echo "   في Termux:   pkg upgrade python"
    echo "   في Andronix: apt install python3.10"
    exit 1
fi

echo -e "${GREEN}✅ Python $(python3 --version)${RESET}"

# ── عرض نسخة نيكولاس ───────────────────────────────────────
NIK_VER=$(grep -m1 'self.version' nikolas_mega.py 2>/dev/null | grep -o '"v[^"]*"' | tr -d '"' || echo "غير معروف")
echo -e "${CYAN}📌 نكولاس $NIK_VER${RESET}"
echo ""

# ── فحص port 8080 ──────────────────────────────────────────
check_port() {
    if command -v ss &>/dev/null; then
        ss -tlnp 2>/dev/null | grep -q ":8080" && return 0
    elif command -v lsof &>/dev/null; then
        lsof -i:8080 &>/dev/null && return 0
    elif command -v netstat &>/dev/null; then
        netstat -tlnp 2>/dev/null | grep -q ":8080" && return 0
    fi
    return 1
}

if check_port; then
    echo -e "${YELLOW}⚠️  Port 8080 مشغول بعملية أخرى!${RESET}"
    echo -e "   هل تريد الاستمرار على أي حال؟ [y/N]"
    read -r REPLY
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
        echo -e "${RED}تم الإلغاء.${RESET}"
        exit 1
    fi
fi

# ── تثبيت المكتبات ─────────────────────────────────────────
echo -e "${BOLD}📦 فحص المكتبات...${RESET}"

install_if_missing() {
    local module="$1"
    local package="${2:-$1}"
    if ! python3 -c "import $module" 2>/dev/null; then
        echo -e "  ${YELLOW}تثبيت $package...${RESET}"
        python3 -m pip install --break-system-packages -q "$package" 2>/dev/null || \
        python3 -m pip install -q "$package" 2>/dev/null || \
        echo -e "  ${RED}⚠️  فشل تثبيت $package (اختياري)${RESET}"
    else
        echo -e "  ${GREEN}✅ $module${RESET}"
    fi
}

# أساسية
install_if_missing fastapi fastapi
install_if_missing uvicorn "uvicorn[standard]"
install_if_missing aiohttp aiohttp
install_if_missing websockets websockets
install_if_missing requests requests

# مزودو AI
install_if_missing groq groq
install_if_missing anthropic anthropic
install_if_missing google.generativeai google-generativeai

# مساعدة
install_if_missing dotenv python-dotenv
install_if_missing rich rich
install_if_missing httpx httpx

echo ""
echo -e "${GREEN}✅ جميع المكتبات جاهزة${RESET}"
echo ""

# ── عرض معلومات الوصول ─────────────────────────────────────
echo -e "${BOLD}══════════════════════════════════════════${RESET}"
echo -e "  🌐 الواجهة:   ${CYAN}http://localhost:8080${RESET}"
echo -e "  📡 WebSocket:  ${CYAN}ws://localhost:8080/ws${RESET}"
echo -e "  📖 Swagger:    ${CYAN}http://localhost:8080/docs${RESET}"
echo -e "  📂 HTML مباشر: ${CYAN}omni_ultimate_v2_mega.html${RESET}"
echo -e "${BOLD}══════════════════════════════════════════${RESET}"
echo ""

# ── فتح المتصفح تلقائياً بعد 3 ثوانٍ ──────────────────────
open_browser_bg() {
    sleep 3
    local URL="http://localhost:8080"
    if command -v termux-open-url &>/dev/null; then
        termux-open-url "$URL" 2>/dev/null
    elif command -v xdg-open &>/dev/null; then
        xdg-open "$URL" 2>/dev/null
    elif command -v open &>/dev/null; then
        open "$URL" 2>/dev/null
    fi
}
open_browser_bg &

# ── تشغيل نيكولاس ──────────────────────────────────────────
echo -e "${BOLD}${GREEN}🚀 تشغيل نكولاس MEGA $NIK_VER...${RESET}"
echo -e "${YELLOW}   اضغط Ctrl+C للإيقاف${RESET}"
echo ""

exec python3 nikolas_mega.py 2>&1
