# Neurorobot iOS application

Project contains iOS app, its dependencies and guide how to build dependency`s libraries.


## Brain-Framework
Used [opencv](https://opencv.org/) library, version `v4.1.1`.    
Used [matio](https://github.com/tbeu/matio) library.  
For building matio is used [autotool for iOS](https://github.com/szanni/ios-autotools) (with some modifications).    

### OpenCV

#### iOS

Download source from [this](https://opencv.org/releases/) link.    
Go to `/opencv-<version>/platforms/ios`  
Open terminal and run `./build_framework.py <outputdir>`, error may occurs because you don't have cmake.    
If you don't have cmake, run `brew install cmake`.  
run from build folder: `lipo -create -output ./libopencv_world.a ./build/build-arm64-iphoneos/install/lib/libopencv_world.a ./build/build-armv7-iphoneos/install/lib/libopencv_world.a ./build/build-armv7s-iphoneos/install/lib/libopencv_world.a ./build/build-i386-iphonesimulator/install/lib/libopencv_world.a ./build/build-x86_64-iphonesimulator/install/lib/libopencv_world.a`    
Header files are in `./build/build-arm64-iphoneos/install/include`

#### macOS

Download source from [this](https://opencv.org/releases/) link.    
Go to `/opencv-<version>/platforms/osx`  
Open terminal and run `./build_framework.py <outputdir>`, error may occurs because you don't have cmake.  
If you don't have cmake, run `brew install cmake`.  
change `"MACOSX_DEPLOYMENT_TARGET=10.9"` to `"MACOSX_DEPLOYMENT_TARGET=10.12"` in `./build_framework.py` [maybe]  
Lib files are in `./build/build-x86_64-macosx/install/lib`  
Header files are in `./build/build-x86_64-macosx/install/include`

### Matio

#### iOS

run `git clone git://git.code.sf.net/p/matio/matio`    
run `cd matio`  
run `brew install libtool` [maybe]  
run `brew install automake` [maybe]      
run `./autogen.sh`  
download `https://github.com/szanni/ios-autotools`  
make changes in `configure` [maybe not necessary]  
Edited code around line number 15542 in `configure` to pass tests if it's cross compiling. Edit is:    
```
if test ".$ac_cv_va_copy" = .; then
if test "$cross_compiling" = yes; then :
{ 
{
ac_cv_va_copy="C99" 
}
}
```
It was:
```
if test ".$ac_cv_va_copy" = .; then
if test "$cross_compiling" = yes; then :
{ { $as_echo "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
$as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
as_fn_error $? "cannot run test program while cross compiling
See \`config.log' for more details" "$LINENO" 5; }
```

paste `iconfigure` and `autoframework` from `ios-autotools` to matio root folder.  
In `iconfigure` change min iOS version (search for `-miphoneos-version-min`), e.g. `-miphoneos-version-min=10.3`.        
In `iconfigure` add `-fembed-bitcode` to the end of line where assigning `CFLAGS`.  
In `autoframework` add `lipo -create -output "$PREFIX/$LIBARCHIVE" $LIPOARCHS` line bellow another `lipo` command.  
run `PREFIX="--path--to--build--folder--" ARCHS="i386 x86_64 armv7 armv7s arm64" ./autoframework Matio libmatio.a`

#### macOS

run `git clone git://git.code.sf.net/p/matio/matio`    
run `cd matio`  
run `brew install libtool` [maybe]  
run `brew install automake` [maybe]      
run `./autogen.sh`  
run `./configure --prefix=<absolute path>`  
run `make`  
run `make install`  

## Neurorobot-Framework
Used [boost](https://www.boost.org) and [ffmpeg](https://www.ffmpeg.org) libraries.  

Followed [this repo](https://github.com/faithfracture/Apple-Boost-BuildScript) to build the `boost` library.  
Followed [this repo](https://github.com/kewlbear/FFmpeg-iOS-build-script) to build the `ffmpeg` library.  

### Boost
Guidelines for building boost library

#### Windows


#### macOS | iOS

Used [this repo](https://github.com/faithfracture/Apple-Boost-BuildScript) to build `boost` library.    
Clone `Apple-Boost-BuildScript` from repo.  
Commands need to run in terminal from `Apple-Boost-BuildScript` folder.    
`./boost.sh -ios -macos --ios-archs "armv7 armv7s arm64 arm64e" --min-ios-version 10.3 --universal`  

### FFmpeg
Guidelines for building ffmpeg library

#### Windows

run `git clone https://github.com/FFmpeg/FFmpeg.git`  
get msys2 - https://www.msys2.org/  

launch msvc "developer command prompt".  
run from msys64 directory `msys2_shell.cmd -mingw64 -use-full-path`  

run in mingw:  
run `pacman -S make pkg-config diffutils`  
run `pacman -S mingw-w64-x86_64-nasm mingw-w64-x86_64-gcc mingw-w64-x86_64-SDL2`    
run `pacman -S yasm`  
maybe run `pacman -S make gcc diffutils mingw-w64-{i686,x86_64}-pkg-config mingw-w64-i686-nasm mingw-w64-i686-yasm`    
maybe run `export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig`    
maybe run `export PATH="path_to_lib.exe_in_msvc":$PATH`    
navigate to ffmpeg folder  
run `./configure --toolchain=msvc --arch=x86_64 --enable-shared --disable-static --prefix=./install`    
run `make`  
run `make install`    


from guide:  
https://www.linkedin.com/pulse/building-ffmpeg-windows-without-fuss-moshe-david  


run `./configure --disable-static --enable-shared --disable-doc --arch=x86_64 --target-os=win64 --prefix=/c/ffmpeg`  





#### macOS

run `git clone https://github.com/FFmpeg/FFmpeg.git`  
Edit the file `libavformat/rtpdec.c`. Line number 323: `rtcp_bytes /= 50;`, it should be: `rtcp_bytes /= 5;`. This is because of sending receive report more frequent.    
Commands need to run in terminal from ffmpeg folder.  
If you don't set `--prefix`, library will be in `/usr/lib`  
`./configure --enable-shared --prefix=./install`
if the error occurs, maybe you have to install yasm, command: `brew install yasm`  
`make`  
`make install`    

notes:  
- Libraries (*.dylib) must be in /usr/lib. So copy *.dylib files from FFmpeg-macOS/dylib to /usr/lib. (doesn't work, cannot copy, should rebuild whole library without `--prefix`)  
- Followed https://trac.ffmpeg.org/wiki/CompilationGuide/macOS  

#### iOS 

run `git clone https://github.com/kewlbear/FFmpeg-iOS-build-script.git`
(alternative: `https://github.com/tanersener/mobile-ffmpeg`)  
run `cd FFmpeg-iOS-build-script`  
edit value of `CONFIGURE_FLAGS` in `build-ffmpeg.sh` to be:  
```
--enable-cross-compile --disable-debug --disable-programs \
--disable-doc --enable-pic \
--enable-static --enable-shared --disable-avfilter --disable-avdevice --enable-swresample \
--enable-zlib --enable-bzlib --enable-iconv
```

run `./build-ffmpeg.sh`  
Stop the script after download and edit the file `libavformat/rtpdec.c`. Line number 323: `rtcp_bytes /= 50;`, it should be: `rtcp_bytes /= 5;`. This is because of sending receive report more frequent. After rerun `./build-ffmpeg.sh`.     
Libs will be in `FFmpeg-iOS` folder.  
