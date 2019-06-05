# Rule for building verilator simulations.
#
# Copyright 2019 Erik Gilling
#
# Heavily informed from the rules_foreign_cc package at:
#   https://github.com/bazelbuild/rules_foreign_cc/

# Since verilator uses make to build its output it shares some actions with
# @rules_foreign_cc.
load("@rules_foreign_cc//tools/build_defs:cc_toolchain_util.bzl", "get_env_vars")
load("@rules_foreign_cc//tools/build_defs:shell_script_helper.bzl", "os_name")

def _verilator_sim_impl(ctx):
    # Get the root the the "copy_verilator".  This is a copy of the whole
    # verilator install directory.  This process would be smoother if we
    # wrote our own BUILD file for verilator.
    v_files = ctx.attr._verilator_toolchain.files.to_list() 
    verilator_dir = [f for f in v_files if f.path.endswith("copy_verilator/verilator")][0]
    verilator_path = verilator_dir.path + "/bin/verilator"

    # Under OSX, we need to pass cc_env here so that wrapped_cc_pp does not
    # complain that DEVELOPER_DIR is not defined.
    cc_env = get_env_vars(ctx)
    execution_os_name = os_name(ctx)

    out_file = ctx.actions.declare_file(ctx.attr.name)

    script = [
        # Use verilator to generate C++ simulation.
        "%s -o sim -cc -exe %s" %(verilator_path, " ".join([f.path for f in ctx.files.srcs])), 

        # Build the simulation.
        "make -j -C obj_dir -f V%s.mk sim" % ctx.attr.toplevel,

        # Copy the simuation to our output path.
        "cp obj_dir/sim %s" % out_file.path
    ]
    
    # Wrap out commands in a shell script.
    wrapper_script_file = ctx.actions.declare_file("build.sh")
    ctx.actions.write(
        output = wrapper_script_file,
        content = "\n".join(script),
    )

    # Run the build script.
    ctx.actions.run_shell(
        inputs = depset(ctx.files.srcs, transitive = [ctx.attr._cc_toolchain.files]),
        outputs = [ out_file ],
        tools = v_files + [ wrapper_script_file ],
        use_default_shell_env = execution_os_name != "osx",
        command = wrapper_script_file.path,
        env = cc_env,
    )
    return [DefaultInfo(files = depset([out_file]))]

verilator_sim = rule(
    implementation = _verilator_sim_impl,
    attrs = {
        "toplevel": attr.string(mandatory = True),
        "srcs": attr.label_list(allow_files = True),
         # we need to declare this attribute to access cc_toolchain
        "_cc_toolchain": attr.label(default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")),
        "_verilator_toolchain": attr.label(default = Label("//third_party/verilator:verilator")),
    },
    fragments = ["cpp"],
    toolchains = [
        "@rules_foreign_cc//tools/build_defs/shell_toolchain/toolchains:shell_commands",
        "@bazel_tools//tools/cpp:toolchain_type",
    ],
)