# MobileNotification_demo

[![GitHub Action Workflow Status](https://img.shields.io/github/actions/workflow/status/emericg/MobileNotification_demo/ci_builds.yml?style=flat-square)](https://github.com/emericg/MobileNotification_demo/actions/workflows/ci_builds.yml)

A Qt6 / QML demo application for the [MobileNotification](https://github.com/emericg/MobileNotification) module.  

You can report bugs or request features directly on the [MobileNotification issue page](https://github.com/emericg/MobileNotification/issues).  

## About

### Dependencies

You will need a C++17 compiler and Qt 6.8 LTS to run this demo.  
For macOS and iOS builds, you'll need Xcode (15+) installed.  
For Android builds, you'll need the appropriates JDK (17) SDK (28+) and NDK (26+). You can customize Android build environment using the `assets/android/gradle.properties` file.  

#### Building

```bash
$ git clone https://github.com/emericg/MobileNotification_demo.git --recursive
$ cd MobileNotification_demo/
$ cmake -B build/
$ cmake --build build/
```

## License

The MobileNotification_demo project, just like the MobileNotification module, is licensed under the [MIT license](LICENSE.md).

> Copyright (c) Emeric Grange <emeric.grange@gmail.com>
