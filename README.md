Touch Home
=====
Another iOS little tweak, allow using TouchID sensor as Home button, one tap to simulate Home, two taps to open app switcher. Support iOS 10

1) Install

Use (/packages/com.martinpham.touchhome_0.0.1-25+debug_iphoneos-arm.deb) to install.

2) Build

``make package``

3) Build & Run

Change IP & Port of your device's SSH in ``Makefile`` file
``THEOS_DEVICE_IP = 127.0.0.1``
``THEOS_DEVICE_PORT = 2222``

``make package install``