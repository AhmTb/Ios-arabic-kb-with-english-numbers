"""Validate actual arm64 app + keyboard binaries, then package an unsigned IPA."""
import pathlib
import plistlib
import shutil
import subprocess
import zipfile

root = pathlib.Path(__file__).resolve().parents[1]
app = root / "build/Build/Products/Release-iphoneos/Arabic123.app"
extension = app / "PlugIns/Arabic123Keyboard.appex"

def validate(bundle):
    with (bundle / "Info.plist").open("rb") as handle:
        info = plistlib.load(handle)
    binary = bundle / info["CFBundleExecutable"]
    subprocess.run(["xcrun", "lipo", "-verify_arch", "arm64", str(binary)], check=True)
    return info

main_info = validate(app)
ext_info = validate(extension)
assert ext_info["CFBundleIdentifier"].startswith(main_info["CFBundleIdentifier"] + ".")
assert ext_info["NSExtension"]["NSExtensionPointIdentifier"] == "com.apple.keyboard-service"
assert ext_info["NSExtension"]["NSExtensionAttributes"]["RequestsOpenAccess"] is False
dist = root / "dist"
dist.mkdir(exist_ok=True)
payload = dist / "Payload"
if payload.exists():
    shutil.rmtree(payload)
payload.mkdir()
shutil.copytree(app, payload / app.name, symlinks=True)
ipa = dist / "Arabic123-unsigned.ipa"
subprocess.run(["/usr/bin/ditto", "-c", "-k", "--keepParent", str(payload), str(ipa)], check=True)
with zipfile.ZipFile(ipa) as archive:
    assert archive.testzip() is None
    assert "Payload/Arabic123.app/Arabic123" in archive.namelist()
    assert "Payload/Arabic123.app/PlugIns/Arabic123Keyboard.appex/Arabic123Keyboard" in archive.namelist()
print(f"Created {ipa.name}: {ipa.stat().st_size:,} bytes (unsigned)")
