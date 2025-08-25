objc_library(
    name = "MainWindow",
    srcs = [
        "AppDelegate.m",
        "MainWindowController.m",
    ],
    hdrs = [
        "AppDelegate.h",
        "MainWindowController.h",
    ],
    visibility = ["//visibility:public"],
    includes = ["."],
    sdk_frameworks = [
        "AppKit",
        "Foundation",
    ],
    deps = [
        "//Sources/App:App",
        "//Sources/ChatConversation:ChatConversation",
        "//Sources/ChatInput:ChatInput",
        "//Sources/HistoryTable:HistoryTable",
        "//Sources/Networking:Networking",
        "//Sources/Settings:Settings",
    ],
)