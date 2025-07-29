# Building Friday Night Funkin': Kade Engine Reboot
**Oh God, this took me so much time to make work**

## Dependencies
 1. Install [Haxe](https://haxe.org/download/version/4.1.5/).
 2. Install [HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/).
 3. Install [Git](https://git-scm.com/downloads)
 4. Install and set up the necessary libraries:
	 - `haxelib install lime`
	 - `haxelib install openfl`
	 - `haxelib install flixel`
	 - `haxelib install flixel-tools`
	 - `haxelib install flixel-ui`
	 - `haxelib install hscript`
	 - `haxelib install flixel-addons`
	 - `haxelib install actuate`
	 - `haxelib run lime setup`
	 - `haxelib run lime setup flixel`
	 - `haxelib run flixel-tools setup`
	 - `haxelib git linc_luajit https://github.com/superpowers04/linc_luajit.git`
	 - `haxelib install hxvm-luajit`
	 - `haxelib git faxe https://github.com/uhrobots/faxe`
	 - `haxelib install polymod`
	 - `haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc`
	 - `haxelib git extension-webm https://github.com/KadeDev/extension-webm`
	 - `lime rebuild extension-webm <ie. windows, macos, linux>`
	      - Note: for Linux, you need to install the `g++-multilib` and `gcc-multilib` packages respectively. (use apt to install them.)
	 - `haxelib git jsonpatch https://github.com/EliteMasterEric/jsonpatch`
	 - `haxelib git jsonpath https://github.com/EliteMasterEric/jsonpath`
	 - `haxelib git thx.core https://github.com/fponticelli/thx.core`
	 - `haxelib install newgrounds`

### Windows-only dependencies (only for building *to* Windows. Building html5 on Windows does not require this)
If you are planning to build for Windows, you also need to install **Visual Studio 2019**. While installing it, *don't click on any of the options to install workloads*. Instead, go to the **individual components** tab and choose the following:

-   MSVC v142 - VS 2019 C++ x64/x86 build tools
-   Windows SDK (10.0.17763.0)

This will install about 4 GB of crap, but is necessary to build for Windows.

### macOS-only dependencies (these are required for building on macOS at all, including html5.)
If you are running macOS, you'll need to install Xcode. You can download it from the macOS App Store or from the [Xcode website](https://developer.apple.com/xcode/).

If you get an error telling you that you need a newer macOS version, you need to download an older version of Xcode from the [More Software Downloads](https://developer.apple.com/download/more/) section of the Apple Developer website. (You can check which version of Xcode you need for your macOS version on [Wikipedia's comparison table (in the `min macOS to run` column)](https://en.wikipedia.org/wiki/Xcode#Version_comparison_table).)

## Cloning the repository
Since you already installed `git` in a previous step, we'll use it to clone the repository.
1. `cd` to where you want to store the source code (i.e. `C:\Users\username\Desktop` or `~/Desktop`)
2. `git clone https://github.com/Bloctey64/Kade-Engine-Reboot`
3. `cd` into the source code: `cd Kade-Engine-Reboot`

## Building
Finally, we are ready to build.

- Run `lime build <target>`, replacing `<target>` with the platform you want to build to (`windows`, `mac`, `linux`, `html5`) (i.e. `lime build windows`)
- The build will be in `Kade-Engine/export/release/<target>/bin`, with `<target>` being the target you built to in the previous step. (i.e. `Kade-Engine/export/release/windows/bin`)
- Incase you added the -debug flag the files will be inside `Kade-Engine/export/debug/<target>/bin`
- Only the `bin` folder is necessary to run the game. The other ones in `export/release/<target>` are not.

## Troubleshooting
Check the **Troubleshooting documentation** if you have problems with these instructions.
