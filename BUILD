load("@rules_apple//apple:macos.bzl", "macos_application")

objc_library(
    name = "ChatGPTClassicLib",
    srcs = [
        "Sources/App.m",
        "Sources/AppDelegate.m",
        "Sources/ChatConversation.m",
        "Sources/ChatInput.m",
        "Sources/HistoryTable.m",
        "Sources/MainWindowController.m",
        "Sources/Networking.m",
        "Sources/main.m",
    ],
    hdrs = [
        "Sources/App.h",
        "Sources/AppDelegate.h",
        "Sources/ChatConversation.h",
        "Sources/ChatInput.h",
        "Sources/HistoryTable.h",
        "Sources/MainWindowController.h",
        "Sources/Networking.h",
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