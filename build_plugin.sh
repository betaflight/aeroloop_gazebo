#!/bin/bash
# Build script for BetaflightPlugin
# Compatible with Linux and macOS

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}BetaflightPlugin Build Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PLUGIN_DIR="$SCRIPT_DIR/plugins"
BUILD_DIR="$PLUGIN_DIR/build"

OS_NAME="$(uname -s)"

if [ "$OS_NAME" = "Darwin" ]; then
    PLATFORM="macos"
    JOBS="$(sysctl -n hw.ncpu)"
    LIB_EXT="dylib"
else
    PLATFORM="linux"
    JOBS="$(nproc)"
    LIB_EXT="so"
fi

echo -e "${YELLOW}[1/4] Checking prerequisites...${NC}"
echo "Platform: $PLATFORM"

if ! command -v gz &> /dev/null; then
    echo -e "${RED}Error: gz command not found${NC}"
    echo "Please install Gazebo Harmonic first."
    exit 1
fi

if ! command -v cmake &> /dev/null; then
    echo -e "${RED}Error: cmake command not found${NC}"
    exit 1
fi

if ! command -v pkg-config &> /dev/null; then
    echo -e "${YELLOW}Warning: pkg-config not found${NC}"
else
    if ! pkg-config --exists gz-sim8 2>/dev/null; then
        echo -e "${YELLOW}Warning: gz-sim8 pkg-config not found${NC}"
        echo "Build may still work if CMake can find gz-sim8."
    fi
fi

if [ "$PLATFORM" = "macos" ]; then
    if ! command -v brew &> /dev/null; then
        echo -e "${RED}Error: Homebrew not found on macOS${NC}"
        exit 1
    fi

    if ! brew --prefix qt@5 &> /dev/null; then
        echo -e "${RED}Error: qt@5 not found${NC}"
        echo "Install it with:"
        echo "  brew install qt@5"
        exit 1
    fi

    # also cmake to find qt5
    export CMAKE_PREFIX_PATH="$(brew --prefix qt@5):$(brew --prefix):${CMAKE_PREFIX_PATH}"
fi

if [ ! -f "$PLUGIN_DIR/CMakeLists.txt" ]; then
    echo -e "${RED}Error: CMakeLists.txt not found in $PLUGIN_DIR${NC}"
    exit 1
fi

echo -e "${YELLOW}[2/4] Setting up build directory...${NC}"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"
echo "Build directory: $BUILD_DIR"

echo -e "${YELLOW}[3/4] Configuring with CMake...${NC}"

CMAKE_ARGS=(..)

if [ "$PLATFORM" = "macos" ]; then
    CMAKE_ARGS+=(
        "-DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH"
        "-DQt5_DIR=$(brew --prefix qt@5)/lib/cmake/Qt5"
    )
fi

if cmake "${CMAKE_ARGS[@]}"; then
    echo -e "${GREEN} ${NC} CMake configuration successful"
else
    echo -e "${RED} ${NC} CMake configuration failed"
    exit 1
fi

echo -e "${YELLOW}[4/4] Building plugin...${NC}"
if cmake --build . --parallel "$JOBS"; then
    echo -e "${GREEN} ${NC} Build successful"
else
    echo -e "${RED} ${NC} Build failed"
    exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Build Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

PLUGIN_FILE="$(find "$BUILD_DIR" -maxdepth 2 -name "libBetaflightPlugin.${LIB_EXT}" | head -n 1)"

if [ -n "$PLUGIN_FILE" ] && [ -f "$PLUGIN_FILE" ]; then
    echo -e "${GREEN} ${NC} Plugin library created:"
    ls -lh "$PLUGIN_FILE"
    echo ""
    echo "Plugin location: $PLUGIN_FILE"
else
    echo -e "${RED} ${NC} Plugin library not found"
    echo "Searched for: libBetaflightPlugin.${LIB_EXT}"
    exit 1
fi

echo ""
echo "Next steps:"
echo "1. Test the plugin with Betaloop:"
echo "   cd ../betaloop"
echo "   python3 start.py"
echo ""

echo "2. Or test Gazebo manually:"
echo "   export GZ_SIM_SYSTEM_PLUGIN_PATH=$BUILD_DIR:\$GZ_SIM_SYSTEM_PLUGIN_PATH"

if [ "$PLATFORM" = "macos" ]; then
    echo "   gz sim -s -r -v 4 <world_file>"
    echo "   # In another terminal:"
    echo "   gz sim -g"
else
    echo "   gz sim -r -v 4 <world_file>"
fi

echo ""