load("@rules_apple//apple:macos.bzl", "macos_application")

objc_library(
    name = "ChatGPTClassicLib",
    srcs = ["Sources/main.m"],
    sdk_frameworks = [
        "AppKit",
        "Foundation",
    ],
    deps = [
        "//Sources/App:App",
        "//Sources/MainWindow:MainWindow",
    ],
)

macos_application(
    name = "ChatGPTClassic",
    app_icons = [],
    bundle_id = "com.protospec.chatclassic",
    entitlements = "Resources/ChatGPTClassic.entitlements",
    infoplists = ["Resources/Info.plist"],
    minimum_os_version = "10.4",
    provisioning_profile = "Resources/Chat_Classic_Profile.provisionprofile",
    deps = [":ChatGPTClassicLib"],
)