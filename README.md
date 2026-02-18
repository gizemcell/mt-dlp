# mt-dlp

`mt-dlp` (Multi-Threaded Downloader Program) is a high-performance, open-source download manager for the terminal, engineered to maximize throughput on high-bandwidth connections. Unlike standard single-threaded downloaders (like `wget` or browser defaults) which are often bottlenecked by server-side per-connection speed limits, `mt-dlp` leverages concurrency to saturate available bandwidth.

Built with C++20, it orchestrates multiple worker threads to download distinct file chunks in parallel, reassembling them on-the-fly with strict synchronization safety. It features a rich Text User Interface (TUI) that provides real-time telemetry on individual worker status, buffer usage, and aggregate speed.

## Key Features

  * **Parallel Execution**: Dynamically spawns worker threads based on hardware concurrency and file size to download multiple chunks simultaneously.
  * **Rich TUI**: Powered by `FTXUI`, providing granular visualization of per-thread progress, speed, and status.
  * **Resource Efficiency**: Implements a custom producer-consumer buffering strategy (4 MiB chunks) to minimize disk I/O contention and prevent mutex locking bottlenecks.
  * **Resiliency**: Features intelligent error handling that detects server throttling (HTTP 429/503), automatically strictly reducing concurrency and applying backoff strategies to salvage downloads.
  * **System Integration**: Directly interfaces with `libcurl` for robust protocol handling while managing raw system resources via RAII and manual memory safeguards.

## Building

### Prerequisites

  * **C++ Compiler**: Must support **C++20**.
  * **CMake**: Version 3.16 or higher.
  * **Dependencies**: `libcurl` and `ftxui`.

### Building the Project

1.  **Clone the repository:**
  ```bash
  git clone https://github.com/Omega493/mt-dlp.git
  cd mt-dlp
  ```

2. **Building it on your System**
    * **Windows:**
    It is recommended to use [Visual Studio](https://visualstudio.microsoft.com) for all building workloads. Please make sure `vcpkg` is on your system, and `libcurl` and `ftxui` are available via `vcpkg`. Target the `x64-windows` triplet.

    * **Linux:**
    The project defines a `build.sh` at the root directory. Invoke it using `sh build.sh` - it shall automatically install all dependencies and build the executable. Or, do the manual way:
      ```bash
      # For Debian-based OSes
      sudo apt update
      sudo apt install build-essential cmake ninja-build gcc g++ \
        libcurl4-openssl-dev libftxui-dev -y

      # For Fedora / RHEL / centOS
      sudo dnf upgrade --refresh -y
      sudo dnf install make cmake ninja-build gcc g++ \
        libcurl-devel ftxui-devel -y

      # For Arch Linux
      sudo pacman -Syu --noconfirm
      sudo pacman -S --needed --noconfirm base-devel cmake ninja curl

      WORK_DIR=$(mktemp -d)
      
      git clone --depth 1 https://github.com/ArthurSonzogni/FTXUI.git "$WORK_DIR/FTXUI"

      cmake -S "$WORK_DIR/FTXUI" -B "$WORK_DIR/FTXUI/build" \
        -DCMAKE_BUILD_TYPE=Release \
        -DFTXUI_BUILD_EXAMPLES=OFF \
        -DFTXUI_BUILD_DOCS=OFF \
        -DCMAKE_INSTALL_PREFIX=/usr/local
        
      sudo cmake --build "$WORK_DIR/FTXUI/build" --target install

      rm -rf $WORK_DIR

      # Common for all
      cmake --preset="linux-debug" # If on debug mode
      cmake --preset="linux-release" # If on release mode

      cmake --build --preset=<preset_name> # Replace with whatever preset you started with
      ```
      
3. **Installing it on your System:**
    * **Windows:**
    After the build process is over, simply place the executable's path to your system's environment variable. Or, you can manually copy paste `mt-dlp.exe`, `libcurl.dll` and `zlib1.dll` to some different folder and add them to your system's path. Obviously, build in release mode (debug mode should work fine, but release mode has specific optimizations).
  
    * **Linux:**
    The project defines a `install.sh` at the root directory. It is recommended to run it (`sh install.sh`) to install the program on your system.

## Contributing

Please head over to `CONTRIBUTING.md` for steps on how to contribute to this project.
