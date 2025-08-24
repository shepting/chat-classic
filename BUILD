load("@rules_apple//apple:macos.bzl", "macos_application")

objc_library(
    name = "ChatGPTClassicLib",
    srcs = [
        "Sources/AppDelegate.m",
        "Sources/MainWindowController.m",
        "Sources/main.m",
    ],
    hdrs = [
        "Sources/AppDelegate.h",
        "Sources/MainWindowController.h",
    ],
    sdk_frameworks = [
        "AppKit",
        "Foundation",
    ],
    copts = [
        "-fno-objc-arc",  # Disable ARC for legacy compatibility
        "-mmacosx-version-min=10.4",  # Target macOS 10.4
    ],
)

macos_application(
    name = "ChatGPTClassic",
    app_icons = [],
    bundle_id = "com.example.chatgptclassic",
    infoplists = ["Resources/Info.plist"],
    minimum_os_version = "10.4",
    deps = [":ChatGPTClassicLib"],
)