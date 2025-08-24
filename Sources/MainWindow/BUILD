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
    sdk_frameworks = [
        "AppKit",
        "Foundation",
    ],
    copts = [
        "-fno-objc-arc",
        "-mmacosx-version-min=10.4",
    ],
    deps = [
        "//Sources/App:App",
        "//Sources/ChatConversation:ChatConversation",
        "//Sources/ChatInput:ChatInput",
        "//Sources/HistoryTable:HistoryTable",
        "//Sources/Networking:Networking",
    ],
)