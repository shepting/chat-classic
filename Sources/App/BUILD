objc_library(
    name = "App",
    srcs = ["App.m"],
    hdrs = ["App.h"],
    visibility = ["//visibility:public"],
    includes = ["."],
    sdk_frameworks = [
        "AppKit",
        "Foundation",
    ],
    copts = [
        "-fno-objc-arc",
        "-mmacosx-version-min=10.4",
    ],
)