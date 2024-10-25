
def initialize_util(rctx):
    if rctx.os.name.startswith("mac"):
        if rctx.os.arch == "x86_64":
            rctx.download(
                url = "https://github.com/aspect-build/zstd-prebuilt/releases/download/v1.5.6/zstd_darwin_amd64",
                output = "util/zstd", 
                sha256 = "e4d517212005cf26f8b8d657455d1380318b071cb52a3ffd9dfbdf4c2ba71a13",
                executable = True,
            )
            rctx.download(
                url = "https://github.com/gleyba/BLAKE3/releases/download/1.5.4-bazel/b3sum_darwin_amd64",
                output = "util/b3sum", 
                sha256 = "6cd07ea48634fc142e0d214195978cb796a77451c6ba85aa78e6ac27c87fd60a",
                executable = True,
            )
        elif rctx.os.arch == "aarch64":
            rctx.download(
                url = "https://github.com/aspect-build/zstd-prebuilt/releases/download/v1.5.6/zstd_darwin_arm64",
                output = "util/zstd", 
                sha256 = "6e210eeae08fb6ba38c3ac2d1857075c28113aef68296f7e396f1180f7e894b9",
                executable = True,
            )
            rctx.download(
                url = "https://github.com/gleyba/BLAKE3/releases/download/1.5.4-bazel/b3sum_darwin_arm64",
                output = "util/b3sum", 
                sha256 = "8082034bb2cb46cc4222509715de56d938d6b2805c418fcd7bbd00f880c65d65",
                executable = True,
            )
        else:
            fail("Unsupported arch: %s" % rctx.os.arch)
    elif rctx.os.name.startswith("linux"):
        if rctx.os.arch == "x86_64":
            rctx.download(
                url = "https://github.com/aspect-build/zstd-prebuilt/releases/download/v1.5.6/zstd_linux_amd64",
                output = "util/zstd", 
                sha256 = "82aacf8f1c67ff3c94e04afb0721a848bbba70fbf8249ee4bc4c9085afb84548",
                executable = True,
            )
            rctx.download(
                url = "https://github.com/gleyba/BLAKE3/releases/download/1.5.4-bazel/b3sum_linux_amd64",
                output = "util/b3sum", 
                sha256 = "82aacf8f1c67ff3c94e04afb0721a848bbba70fbf8249ee4bc4c9085afb84548",
                executable = True,
            )
        elif True or rctx.os.arch == "aarch64":
            rctx.download(
                url = "https://github.com/aspect-build/zstd-prebuilt/releases/download/v1.5.6/zstd_linux_arm64",
                output = "util/zstd", 
                sha256 = "82aacf8f1c67ff3c94e04afb0721a848bbba70fbf8249ee4bc4c9085afb84548",
                executable = True,
            )
            rctx.download(
                url = "https://github.com/gleyba/BLAKE3/releases/download/1.5.4-bazel/b3sum_linux_arm64",
                output = "util/b3sum", 
                sha256 = "6b6937a0c2716fe9c50153e6abd44cc527a7570384b1941099d7901236902cd5",
                executable = True,
            )
        else:
            fail("Unsupported arch: %s" % rctx.os.arch)
    else:
        fail("Unsupported os: %s" % rctx.os.name)

    def _exec(mnemo, args):
        exec_res = rctx.execute(args)
        if exec_res.return_code != 0:
            fail("%s failed: %s\nstdout:%s\nstderr:%s" % (
                mnemo,
                exec_res.return_code,
                exec_res.stdout,
                exec_res.stderr,
            ))
        return exec_res

    def _blake3_hash(file):
        return _exec("blake3 hash calc", [
            "util/b3sum", 
            "--no-names", 
            file
        ]).stdout.strip()

    def _extract_zstd(file):
        _exec("extract zstd", ["util/zstd", "-d", file])

    return struct(
        exec = _exec,
        blake3_hash = _blake3_hash,
        extract_zstd = _extract_zstd,
    )