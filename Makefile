default:
	cmake -P CMakeLists.txt
debug:
	cmake -DBUILD_TYPE=Debug -P CMakeLists.txt
release:
	cmake -DBUILD_TYPE=RelWithDebInfo -P CMakeLists.txt

x64-linux-debug:
	cmake -DTARGET=x64-linux -DBUILD_TYPE=Debug -P CMakeLists.txt
x64-linux-release:
	cmake -DTARGET=x64-linux -DBUILD_TYPE=RelWithDebInfo -P CMakeLists.txt
x64-linux-clean:
	cmake -DTARGET=x64-linux -DBUILD_TYPE=Debug -DCLEAN=ON -P CMakeLists.txt
	cmake -DTARGET=x64-linux -DBUILD_TYPE=RelWithDebInfo -DCLEAN=ON -P CMakeLists.txt
x64-linux-distclean:
	cmake -DTARGET=x64-linux -DBUILD_TYPE=Debug -DDISTCLEAN=ON -P CMakeLists.txt
	cmake -DTARGET=x64-linux -DBUILD_TYPE=RelWithDebInfo -DDISTCLEAN=ON -P CMakeLists.txt
x64-linux: x64-linux-debug x64-linux-release

x64-macos-debug:
	cmake -DTARGET=x64-macos -DBUILD_TYPE=Debug -P CMakeLists.txt
x64-macos-release:
	cmake -DTARGET=x64-macos -DBUILD_TYPE=RelWithDebInfo -P CMakeLists.txt
x64-macos-clean:
	cmake -DTARGET=x64-macos -DBUILD_TYPE=Debug -DCLEAN=ON -P CMakeLists.txt
	cmake -DTARGET=x64-macos -DBUILD_TYPE=RelWithDebInfo -DCLEAN=ON -P CMakeLists.txt
x64-macos-distclean:
	cmake -DTARGET=x64-macos -DBUILD_TYPE=Debug -DDISTCLEAN=ON -P CMakeLists.txt
	cmake -DTARGET=x64-macos -DBUILD_TYPE=RelWithDebInfo -DDISTCLEAN=ON -P CMakeLists.txt
x64-macos: x64-macos-debug x64-macos-release

arm-android-debug:
	cmake -DTARGET=arm-android -DBUILD_TYPE=Debug -P CMakeLists.txt
arm-android-release:
	cmake -DTARGET=arm-android -DBUILD_TYPE=RelWithDebInfo -P CMakeLists.txt
arm-android-clean:
	cmake -DTARGET=arm-android -DBUILD_TYPE=Debug -DCLEAN=ON -P CMakeLists.txt
	cmake -DTARGET=arm-android -DBUILD_TYPE=RelWithDebInfo -DCLEAN=ON -P CMakeLists.txt
arm-android-distclean:
	cmake -DTARGET=arm-android -DBUILD_TYPE=Debug -DDISTCLEAN=ON -P CMakeLists.txt
	cmake -DTARGET=arm-android -DBUILD_TYPE=RelWithDebInfo -DDISTCLEAN=ON -P CMakeLists.txt
arm-android: arm-android-debug arm-android-release

a64-android-debug:
	cmake -DTARGET=a64-android -DBUILD_TYPE=Debug -P CMakeLists.txt
a64-android-release:
	cmake -DTARGET=a64-android -DBUILD_TYPE=RelWithDebInfo -P CMakeLists.txt
a64-android-clean:
	cmake -DTARGET=a64-android -DBUILD_TYPE=Debug -DCLEAN=ON -P CMakeLists.txt
	cmake -DTARGET=a64-android -DBUILD_TYPE=RelWithDebInfo -DCLEAN=ON -P CMakeLists.txt
a64-android-distclean:
	cmake -DTARGET=a64-android -DBUILD_TYPE=Debug -DDISTCLEAN=ON -P CMakeLists.txt
	cmake -DTARGET=a64-android -DBUILD_TYPE=RelWithDebInfo -DDISTCLEAN=ON -P CMakeLists.txt
a64-android: a64-android-debug a64-android-release

x86-android-debug:
	cmake -DTARGET=x86-android -DBUILD_TYPE=Debug -P CMakeLists.txt
x86-android-release:
	cmake -DTARGET=x86-android -DBUILD_TYPE=RelWithDebInfo -P CMakeLists.txt
x86-android-clean:
	cmake -DTARGET=x86-android -DBUILD_TYPE=Debug -DCLEAN=ON -P CMakeLists.txt
	cmake -DTARGET=x86-android -DBUILD_TYPE=RelWithDebInfo -DCLEAN=ON -P CMakeLists.txt
x86-android-distclean:
	cmake -DTARGET=x86-android -DBUILD_TYPE=Debug -DDISTCLEAN=ON -P CMakeLists.txt
	cmake -DTARGET=x86-android -DBUILD_TYPE=RelWithDebInfo -DDISTCLEAN=ON -P CMakeLists.txt
x86-android: x86-android-debug x86-android-release

x64-android-debug:
	cmake -DTARGET=x64-android -DBUILD_TYPE=Debug -P CMakeLists.txt
x64-android-release:
	cmake -DTARGET=x64-android -DBUILD_TYPE=RelWithDebInfo -P CMakeLists.txt
x64-android-clean:
	cmake -DTARGET=x64-android -DBUILD_TYPE=Debug -DCLEAN=ON -P CMakeLists.txt
	cmake -DTARGET=x64-android -DBUILD_TYPE=RelWithDebInfo -DCLEAN=ON -P CMakeLists.txt
x64-android-distclean:
	cmake -DTARGET=x64-android -DBUILD_TYPE=Debug -DDISTCLEAN=ON -P CMakeLists.txt
	cmake -DTARGET=x64-android -DBUILD_TYPE=RelWithDebInfo -DDISTCLEAN=ON -P CMakeLists.txt
x64-android: x64-android-debug x64-android-release

arm-ios-debug:
	cmake -DTARGET=arm-ios -DBUILD_TYPE=Debug -P CMakeLists.txt
arm-ios-release:
	cmake -DTARGET=arm-ios -DBUILD_TYPE=RelWithDebInfo -P CMakeLists.txt
arm-ios-clean:
	cmake -DTARGET=arm-ios -DBUILD_TYPE=Debug -DCLEAN=ON -P CMakeLists.txt
	cmake -DTARGET=arm-ios -DBUILD_TYPE=RelWithDebInfo -DCLEAN=ON -P CMakeLists.txt
arm-ios-distclean:
	cmake -DTARGET=arm-ios -DBUILD_TYPE=Debug -DDISTCLEAN=ON -P CMakeLists.txt
	cmake -DTARGET=arm-ios -DBUILD_TYPE=RelWithDebInfo -DDISTCLEAN=ON -P CMakeLists.txt
arm-ios: arm-ios-debug arm-ios-release

a64-ios-debug:
	cmake -DTARGET=a64-ios -DBUILD_TYPE=Debug -P CMakeLists.txt
a64-ios-release:
	cmake -DTARGET=a64-ios -DBUILD_TYPE=RelWithDebInfo -P CMakeLists.txt
a64-ios-clean:
	cmake -DTARGET=a64-ios -DBUILD_TYPE=Debug -DCLEAN=ON -P CMakeLists.txt
	cmake -DTARGET=a64-ios -DBUILD_TYPE=RelWithDebInfo -DCLEAN=ON -P CMakeLists.txt
a64-ios-distclean:
	cmake -DTARGET=a64-ios -DBUILD_TYPE=Debug -DDISTCLEAN=ON -P CMakeLists.txt
	cmake -DTARGET=a64-ios -DBUILD_TYPE=RelWithDebInfo -DDISTCLEAN=ON -P CMakeLists.txt
a64-ios: a64-ios-debug a64-ios-release

x64-ios-debug:
	cmake -DTARGET=x64-ios -DBUILD_TYPE=Debug -P CMakeLists.txt
x64-ios-release:
	cmake -DTARGET=x64-ios -DBUILD_TYPE=RelWithDebInfo -P CMakeLists.txt
x64-ios-clean:
	cmake -DTARGET=x64-ios -DBUILD_TYPE=Debug -DCLEAN=ON -P CMakeLists.txt
	cmake -DTARGET=x64-ios -DBUILD_TYPE=RelWithDebInfo -DCLEAN=ON -P CMakeLists.txt
x64-ios-distclean:
	cmake -DTARGET=x64-ios -DBUILD_TYPE=Debug -DDISTCLEAN=ON -P CMakeLists.txt
	cmake -DTARGET=x64-ios -DBUILD_TYPE=RelWithDebInfo -DDISTCLEAN=ON -P CMakeLists.txt
x64-ios: x64-ios-debug x64-ios-release

linux: x64-linux-debug
linux-debug: x64-linux-debug
linux-release: x64-linux-release
linux-all: linux-debug linux-release
linux-clean: x64-linux-clean
linux-distclean: x64-linux-distclean

macos: x64-macos-debug
macos-debug: x64-macos-debug
macos-release: x64-macos-release
macos-all: macos-debug macos-release
macos-clean: x64-macos-clean
macos-distclean: x64-macos-distclean

android: arm-android-debug
android-debug: arm-android-debug x86-android-debug a64-android-debug x64-android-debug
android-release: arm-android-release x86-android-release a64-android-release x64-android-release
android-all: android-debug android-release
android-clean: arm-android-clean x86-android-clean a64-android-clean x64-android-clean
android-distclean: arm-android-distclean x86-android-distclean a64-android-distclean x64-android-distclean

ios: a64-ios-debug
ios-debug: arm-ios-debug a64-ios-debug x64-ios-debug
ios-release: arm-ios-release a64-ios-release x64-ios-release
ios-all: ios-debug ios-release
ios-clean: arm-ios-clean a64-ios-clean x64-ios-clean
ios-distclean: arm-ios-distclean a64-ios-distclean x64-ios-distclean

all: linux-all macos-all android-all ios-all
clean: linux-clean macos-clean android-clean ios-clean
distclean: linux-distclean macos-distclean android-distclean ios-distclean
