#!/bin/bash
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
cyan='\033[0;36m'
reset='\033[0m'

log() {
  printf "%b%s%b\n" "$1" "$2" "$reset"
}

trap 'log "$red" "Script interrupted by user."; exit 1' INT

if [ "$(id -u)" -eq 0 ]; then
  log "$red" "Do not run this script as sudo."
  log "$yellow" "It will ask for password when necessary."
  exit 1
fi

skip_pkg_install=false
debug_mode=false

for arg in "$@"; do
  case $arg in
    --skip-pkg-install)
      skip_pkg_install=true
      ;;
    --linux-debug)
      debug_mode=true
      ;;
  esac
done

if [ "$skip_pkg_install" = true ]; then
  log "$yellow" "Skipping installation of packages. Build might fail."
  log "$yellow" "If it does, remove the '--skip-pkg-install' argument."
  sleep 2
else
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
      ubuntu | debian | linuxmint | pop)
        log "$cyan" "Detected ${ID}"
        sleep 2

        sudo apt update && sudo apt upgrade -y
      
        sudo apt install build-essential cmake ninja-build gcc g++ \
          libcurl4-openssl-dev libftxui-dev -y
        ;;
      fedora | rhel | centos)
        log "$cyan" "Detected ${ID}"
        sleep 2
      
        sudo dnf upgrade --refresh -y
        sudo dnf install make cmake ninja-build gcc g++ \
          libcurl-devel ftxui-devel -y
        ;;
      arch | manjaro | endeavouros)
        log "$cyan" "Detected ${ID}"
        sleep 2

        sudo pacman -Syu --noconfirm
        sudo pacman -S --needed --noconfirm base-devel cmake ninja curl

        local WORK_DIR
        WORK_DIR=$(mktemp -d)
        
        git clone --depth 1 https://github.com/ArthurSonzogni/FTXUI.git "$WORK_DIR/FTXUI"

        log "$cyan" "Building FTXUI"

        cmake -S "$WORK_DIR/FTXUI" -B "$WORK_DIR/FTXUI/build" \
          -DCMAKE_BUILD_TYPE=Release \
          -DFTXUI_BUILD_EXAMPLES=OFF \
          -DFTXUI_BUILD_DOCS=OFF \
          -DCMAKE_INSTALL_PREFIX=/usr/local
        
        sudo cmake --build "$WORK_DIR/FTXUI/build" --target install

        log "$green" "FTXUI installed successfully"

        rm -rf $WORK_DIR
        ;;
      *)
        log "$red" "Unknown or unsupported distribution: ${ID}"
        log "$red" "Couldn't build target."
        exit 1
        ;;
    esac
  else
    log "$red" "'/etc/os-release' not found. Cannot detect OS."
    exit 1
  fi
fi

if [ "$debug_mode" = true ]; then
  touch "build.linux-debug"
fi

if [ -f "build.linux-debug" ]; then
  log  "$yellow" "'build.linux-debug' file found in the current directory. The executable will be built in debug mode."
  log "$yellow" "Delete the file if you want to build in release mode ('rm build.linux-debug')"
  target_preset="linux-debug"
else
  log  "$yellow" "'build.linux-debug' file not found in the current directory. The executable will be built in release mode."
  log "$yellow" "Create the file if you want to build in debug mode ('touch build.linux-debug')."
  log "$yellow" "Alternatively, pass '--linux-debug' while executing this script."
  target_preset="linux-release"
fi

sleep 2

# if [ -d "build" ]; then
#   sudo chown -R "$USER":"$USER" .
# fi

if ! cmake --preset "$target_preset"; then
  log "$red" "CMake failed"
  exit 1
fi

if ! cmake --build --preset "$target_preset"; then
  log "$red" "Build failed"
  exit 1
fi

log "$green" "Build complete!"
log "$cyan" "Installing..."

BUILD_DIR="build/linux/${target_preset}"

if [ ! -d "$BUILD_DIR" ]; then
  log "$red" "Error: Build directory '${BUILD_DIR}' not found."
  exit 1
fi

if ! sudo cmake --install "$BUILD_DIR"; then
  log "$red" "Installation failed"
  exit 1
fi

log "$green" "Installation complete!"
exit 0
