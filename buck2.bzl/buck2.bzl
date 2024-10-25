load("@aspect_bazel_lib//lib:base64.bzl", "base64")
load("//buck2.bzl/private:util.bzl", "initialize_util")

def _buck2_impl(rctx):
    if rctx.os.name.startswith("mac"):
        platform_key = "macos-%s" % rctx.os.arch
    elif rctx.os.name.startswith("linux"):
        platform_key = "linux-%s" % rctx.os.arch
    else:
        fail("Unsupported os: %s" % rctx.os.name)
    
    url = rctx.attr.binaries.get("%s_url" % platform_key)
    integrity = rctx.attr.binaries.get("%s_integrity" % platform_key)

    if not url:
        fail("Can't find buck2 release for %s" % platform_key)

    util = initialize_util(rctx)

    if integrity.startswith("blake3-"):
        rctx.download(
            url = url, 
            output = "buck2.zst",
        )
        blake3_hash = base64.decode(integrity[7:])
        blake3_hash_cacl = util.blake3_hash("buck2.zst")
        if blake3_hash != blake3_hash_cacl:
            fail("buck2.zst hash was %s, but wanted %s" % (
                blake3_hash_cacl,
                blake3_hash,
            ))
    else:
        rctx.download(
            url = url, 
            output = "buck2.zst",
            integrity = integrity,
        )

    util.extract_zstd("buck2.zst")
    rctx.delete("buck2.zst")
    util.exec("chmod buck2", ["chmod", "+x", "buck2"])
    rctx.file("BUILD.bazel")



_buck2 = repository_rule(
    implementation = _buck2_impl,
    attrs = {
        "binaries": attr.string_dict(),
    }
)


def _load_dotslash(mctx, dotslash):
    content = mctx.read(dotslash).split("\n")[1:]
    return json.decode("".join([ x.strip() for x in content ]))


def _buck2_module_impl(mctx):
    for mod in mctx.modules:
        for release in mod.tags.release:
            output = "%s_%s" % (
                release.name,
                release.version,
            )
            mctx.download(
                "https://github.com/facebook/buck2/releases/download/%s/buck2" % release.version,
                output = output, 
            )
            release_info = _load_dotslash(mctx, output)
            binaries = {}

            for platform, info in release_info["platforms"].items():
                binaries["%s_url" % platform] = info["providers"][0]["url"]
                binaries["%s_integrity" % platform] = "%s-%s" % (
                    info["hash"], 
                    base64.encode(info["digest"]),
                )

            _buck2(
                name = release.name,
                binaries = binaries,
            )


_release = tag_class(attrs = {
    "version": attr.string(),
    "name": attr.string(default = "buck2"),  
})

buck2 = module_extension(
    implementation = _buck2_module_impl,
    tag_classes = {"release": _release},
)
