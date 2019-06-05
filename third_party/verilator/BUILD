load("@rules_foreign_cc//tools/build_defs:configure.bzl", "configure_make")
load(":verilator.bzl", "verilator_sim")

configure_make(
    name = "verilator",
    binaries = [
        "verilator",
    ],
    make_commands = [
        "make -j",
        "make install",
    ],

    lib_source = "@verilator//:all",
)

# A simple rule to see if verilator's example compiles.
verilator_sim(
    name = "sim",
    toplevel = "our",
    srcs = [
        "our.v",
        "sim_main.cpp",
    ],
)
