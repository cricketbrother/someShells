#!/bin/bash

set -e

# 配置
REPO_URL="https://github.com/ddlsmurf/libfprint-CS9711.git"
PROJECT_DIR="libfprint-CS9711"
BUILD_DIR="$HOME/Drivers/$PROJECT_DIR"

echo "🚀 开始自动安装 CS9711 指纹驱动..."

# 1. 安装 Git（确保可用）
if ! command -v git &> /dev/null; then
    echo "📦 安装 Git..."
    sudo apt update
    sudo apt install -y git
fi

# 2. 创建目标目录
mkdir -p "$HOME/Drivers"

# 3. 克隆或更新源码
if [[ -d "$BUILD_DIR" ]]; then
    echo "🔄 更新现有源码..."
    cd "$BUILD_DIR"
    git pull origin main || git pull origin master
else
    echo "📥 正在克隆源码仓库..."
    git clone "$REPO_URL" "$BUILD_DIR"
    cd "$BUILD_DIR"
fi

# 4. 安装构建依赖
echo "📦 安装系统依赖..."
sudo apt update
sudo apt install -y \
    meson \
    ninja-build \
    libglib2.0-dev \
    libgusb-dev \
    libgirepository1.0-dev \
    libpixman-1-dev \
    libnss3-dev \
    libopencv-dev \
    doctest-dev

# 5. 备份并禁用非必要模块
MESON_FILE="meson.build"
if [[ ! -f "${MESON_FILE}.bak" ]]; then
    cp "$MESON_FILE" "${MESON_FILE}.bak"
    echo "💾 已备份 $MESON_FILE"
fi

# 6. 清理并配置构建
echo "🧹 清理旧构建..."
rm -rf build/

echo "⚙️ 配置 Meson（仅启用 cs9711 驱动）..."
meson setup build -Ddrivers=cs9711

# 7. 编译
echo "🔨 正在编译..."
ninja -C build

# 8. 安装
echo "📥 安装到系统..."
sudo ninja -C build install

# 9. 刷新库缓存
sudo ldconfig

# 10. 完成提示
echo ""
echo "✅ CS9711 驱动安装成功！"
echo ""
echo "🔍 查看设备是否识别："
echo "   lsusb | grep -i '9711\|chunsheng'"
echo ""
echo "🧪 测试指纹（首次使用需安装 fprintd）："
echo "   sudo apt install -y fprintd libpam-fprintd"
echo "   fprintd-enroll"
echo ""
echo "📁 源码位置：$BUILD_DIR"
echo "ℹ️ 如需恢复原始 meson.build："
echo "   cp ${MESON_FILE}.bak $MESON_FILE"
