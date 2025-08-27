objc_library(
    name = "Settings",
    srcs = ["Settings.m"],
    hdrs = ["Settings.h"],
    visibility = ["//visibility:public"],
    includes = ["."],
    deps = [
        "//Sources/Services/KeychainService:Keychain",
    ],
    sdk_frameworks = [
        "AppKit",
        "Foundation",
    ],
)