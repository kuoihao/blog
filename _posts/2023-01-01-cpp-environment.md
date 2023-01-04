---
layout: post
title:  "配置c/cpp环境"
date:   2023-01-02 23:00:00
desc: "配置c/cpp环境"
keywords: "c,cpp,environment"
categories: [Cpp]
tags: [c,cpp,environment]
icon: icon-html
---

##配置cpp

>首先,推荐大家使用Clion(jetbrain家族)  
>我自己的vscode环境配置如下，大家可以阅读
>或自行观看，网址：https://code.visualstudio.com/docs/languages/cpp



C/C++ support for Visual Studio Code is provided by a [Microsoft C/C++ extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools) to enable cross-platform C and C++ development on Windows, Linux, and macOS.

![cpp extension](https://code.visualstudio.com/assets/docs/languages/cpp/cpp-extension.png)

## [Install the extension](https://code.visualstudio.com/docs/languages/cpp#_install-the-extension)

1.  Open VS Code.
2.  Select the Extensions view icon on the Activity bar or use the keyboard shortcut (Ctrl+Shift+X).
3.  Search for `'C++'`.
4.  Select **Install**.

![Search for c++ in the Extensions view](https://code.visualstudio.com/assets/docs/languages/cpp/search-cpp-extension.png)

After you install the extension, when you open or create a `*.cpp` file, you will have syntax highlighting (colorization), smart completions and hovers (IntelliSense), and error checking.

![C++ language features]<img src="https://code.visualstudio.com/assets/docs/languages/cpp/msg-intellisense.png" style="zoom: 80%;" />

## [Install a compiler](https://code.visualstudio.com/docs/languages/cpp#_install-a-compiler)

C++ is a compiled language meaning your program's source code must be translated (compiled) before it can be run on your computer. VS Code is first and foremost an editor, and relies on command-line tools to do much of the development workflow. The C/C++ extension does not include a C++ compiler or debugger. You will need to install these tools or use those already installed on your computer.

There may already be a C++ compiler and debugger provided by your academic or work development environment. Check with your instructors or colleagues for guidance on installing the recommended C++ toolset (compiler, debugger, project system, linter).

Some platforms, such as Linux or macOS, have a C++ compiler already installed. Most Linux distributions have the [GNU Compiler Collection](https://wikipedia.org/wiki/GNU_Compiler_Collection) (GCC) installed and macOS users can get the [Clang](https://wikipedia.org/wiki/Clang) tools with [Xcode](https://developer.apple.com/xcode/).

### [Check if you have a compiler installed](https://code.visualstudio.com/docs/languages/cpp#_check-if-you-have-a-compiler-installed)

Make sure your compiler executable is in your platform path (`%PATH` on Windows, `$PATH` on Linux and macOS) so that the C/C++ extension can find it. You can check availability of your C++ tools by opening the Integrated Terminal (Ctrl+\`) in VS Code and trying to directly run the compiler.

Checking for the GCC compiler `g++`:

```
g++ --version
```

Checking for the Clang compiler `clang`:

```
clang --version
```

> **Note**: If you would prefer a full Integrated Development Environment (IDE), with built-in compilation, debugging, and project templates (File > New Project), there are many options available, such as the [Visual Studio Community](https://visualstudio.microsoft.com/vs/community) edition.

If you don't have a compiler installed, in the example below, we describe how to install the Minimalist GNU for Windows (MinGW) C++ tools (compiler and debugger). MinGW is a popular, free toolset for Windows. If you are running VS Code on another platform, you can read the [C++ tutorials](https://code.visualstudio.com/docs/languages/cpp#_tutorials), which cover C++ configurations for Linux and macOS.

## [Example: Install MinGW-x64](https://code.visualstudio.com/docs/languages/cpp#_example-install-mingwx64)

We will install Mingw-w64 via [MSYS2](https://www.msys2.org/), which provides up-to-date native builds of GCC, Mingw-w64, and other helpful C++ tools and libraries. You can download the latest installer from the MSYS2 page or use this [link to the installer](https://github.com/msys2/msys2-installer/releases/download/2022-06-03/msys2-x86_64-20220603.exe).

Follow the **Installation** instructions on the [MSYS2 website](https://www.msys2.org/) to install Mingw-w64. Take care to run each required Start menu and `pacman` command.

You will need to install the full Mingw-w64 toolchain (`pacman -S --needed base-devel mingw-w64-x86_64-toolchain`) to get the `gdb` debugger.

### [Add the MinGW compiler to your path](https://code.visualstudio.com/docs/languages/cpp#_add-the-mingw-compiler-to-your-path)

Add the path to your Mingw-w64 `bin` folder to the Windows `PATH` environment variable by using the following steps:

1.  In the Windows search bar, type 'settings' to open your Windows Settings.
2.  Search for **Edit environment variables for your account**.
3.  Choose the `Path` variable in your **User variables** and then select **Edit**.
4.  Select **New** and add the Mingw-w64 destination folder path, with `\mingw64\bin` appended, to the system path. The exact path depends on which version of Mingw-w64 you have installed and where you installed it. If you used the settings above to install Mingw-w64, then add this to the path: `C:\msys64\mingw64\bin`.
5.  Select **OK** to save the updated PATH. You will need to reopen any console windows for the new PATH location to be available.

### [Check your MinGW installation](https://code.visualstudio.com/docs/languages/cpp#_check-your-mingw-installation)

To check that your Mingw-w64 tools are correctly installed and available, open a **new** Command Prompt and type:

```
gcc --version
g++ --version
gdb --version
```

If you don't see the expected output or `g++` or `gdb` is not a recognized command, make sure your PATH entry matches the Mingw-w64 binary location where the compiler tools are located.

If the compilers do not exist at that PATH entry, make sure you followed the instructions on the [MSYS2 website](https://www.msys2.org/) to install Mingw-w64.

## [Hello World](https://code.visualstudio.com/docs/languages/cpp#_hello-world)

To make sure the compiler is installed and configured correctly, we'll create the simplest Hello World C++ program.

Create a folder called "HelloWorld" and open VS Code in that folder (`code .` opens VS Code in the current folder):

```
mkdir HelloWorld
cd HelloWorld
code .
```

The "code ." command opens VS Code in the current working folder, which becomes your "workspace". Accept the [Workspace Trust](https://code.visualstudio.com/docs/editor/workspace-trust) dialog by selecting **Yes, I trust the authors** since this is a folder you created.

Now create a new file called `helloworld.cpp` with the **New File** button in the File Explorer or **File** > **New File** command.

![File Explorer New File button]<img src=https://code.visualstudio.com/assets/docs/languages/cpp/new-file.png  style="zoom: 90%;" />

![helloworld.cpp file]<img src="https://code.visualstudio.com/assets/docs/languages/cpp/hello-world-cpp.png"  style="zoom: 33%;" />

### [Add Hello World source code](https://code.visualstudio.com/docs/languages/cpp#_add-hello-world-source-code)

Now paste in this source code:

```
#include <iostream>

int main()
{
    std::cout << "Hello World" << std::endl;
}
```

Now press Ctrl+S to save the file. You can also enable [Auto Save](https://code.visualstudio.com/docs/editor/codebasics#_save-auto-save) to automatically save your file changes, by checking **Auto Save** in the main **File** menu.

### [Build Hello World](https://code.visualstudio.com/docs/languages/cpp#_build-hello-world)

Now that we have a simple C++ program, let's build it. Select the **Terminal** > **Run Build Task** command (Ctrl+Shift+B) from the main menu.

![Run Build Task menu option](https://code.visualstudio.com/assets/docs/languages/cpp/run-build-task.png)

This will display a dropdown with various compiler task options. If you are using a GCC toolset like MinGW, you would choose **C/C++: g++.exe build active file**.

![Select g++.exe task](https://code.visualstudio.com/assets/docs/languages/cpp/gpp-build-task-msys64.png)

This will compile `helloworld.cpp` and create an executable file called `helloworld.exe`, which will appear in the File Explorer.

![helloworld.exe in the File Explorer](https://code.visualstudio.com/assets/docs/languages/cpp/hello-world-exe.png)

### [Run Hello World](https://code.visualstudio.com/docs/languages/cpp#_run-hello-world)

From a command prompt or a new VS Code Integrated Terminal, you can now run your program by typing ".\\helloworld".

![Run hello world in the VS Code Integrated Terminal](https://code.visualstudio.com/assets/docs/languages/cpp/run-hello-world.png)

If everything is set up correctly, you should see the output "Hello World".

This has been a very simple example to help you get started with C++ development in VS Code. The next step is to try one of the tutorials listed below on your platform (Windows, Linux, or macOS) with your preferred toolset (GCC, Clang, Microsoft C++) and learn more about the Microsoft C/C++ extension's language features such as IntelliSense, code navigation, build configuration, and debugging.

## [Tutorials](https://code.visualstudio.com/docs/languages/cpp#_tutorials)

Get started with C++ and VS Code with tutorials for your environment:

-   [GCC on Windows via MinGW](https://code.visualstudio.com/docs/cpp/config-mingw)
-   [Microsoft C++ on Windows](https://code.visualstudio.com/docs/cpp/config-msvc)
-   [GCC on Linux](https://code.visualstudio.com/docs/cpp/config-linux)
-   [GCC on Windows Subsystem For Linux](https://code.visualstudio.com/docs/cpp/config-wsl)
-   [Clang/LLVM on macOS](https://code.visualstudio.com/docs/cpp/config-clang-mac)
-   [CMake Tools on Linux](https://code.visualstudio.com/docs/cpp/cmake-linux)

## [Documentation](https://code.visualstudio.com/docs/languages/cpp#_documentation)

You can find more documentation on using the Microsoft C/C++ extension under the [C++ section](https://code.visualstudio.com/docs/cpp) of the VS Code website, where you'll find topics on:

-   [Debugging](https://code.visualstudio.com/docs/cpp/cpp-debug)
-   [Editing](https://code.visualstudio.com/docs/cpp/cpp-ide)
-   [Settings](https://code.visualstudio.com/docs/cpp/customize-default-settings-cpp)
-   [FAQ](https://code.visualstudio.com/docs/cpp/faq-cpp)


<img src=https://code.visualstudio.com/assets/docs/languages/cpp/cpp-toc.png  style="zoom: 33%;" />

## [Remote Development](https://code.visualstudio.com/docs/languages/cpp#_remote-development)

VS Code and the C++ extension support [Remote Development](https://code.visualstudio.com/docs/remote/remote-overview) allowing you to work over SSH on a remote machine or VM, inside a Docker container, or in the [Windows Subsystem for Linux](https://learn.microsoft.com/windows/wsl) (WSL).

To install support for Remote Development:

1.  Install the VS Code [Remote Development Extension Pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack).
2.  If the remote source files are hosted in WSL, use the **WSL** extension.
3.  If you are connecting to a remote machine with SSH, use the **Remote - SSH** extension.
4.  If the remote source files are hosted in a container (for example, Docker), use the **Dev Containers** extension.

## [Feedback](https://code.visualstudio.com/docs/languages/cpp#_feedback)

If you run into any issues or have suggestions for the Microsoft C/C++ extension, please file [issues and suggestions on GitHub](https://github.com/microsoft/vscode-cpptools/issues). If you haven't already provided feedback, please take this [quick survey](https://www.research.net/r/VBVV6C6) to help shape this extension for your needs.

1/21/2022