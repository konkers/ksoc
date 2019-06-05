load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

all_content = """filegroup(name = "all", srcs = glob(["**"]), visibility = ["//visibility:public"])"""

def include_third_party_repositories():
    http_archive(
        name = "rules_foreign_cc",
        strip_prefix = "rules_foreign_cc-master",
        url = "https://github.com/bazelbuild/rules_foreign_cc/archive/master.zip",
    )

    http_archive(
        name = "verilator",
        build_file_content = all_content,
        sha256 = "edf517b1b3ae0df98bd8d8189d17142c181cd50948d54a6ecb082f38804a33eb",
        strip_prefix = "verilator-4.014",
        urls = [
            "https://www.veripool.org/ftp/verilator-4.014.tgz",
        ],
    )