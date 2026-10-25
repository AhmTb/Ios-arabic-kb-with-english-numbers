# Arabic 123 for iPhone

A minimal Arabic keyboard with a permanent **0123456789** number row. No subscriptions, analytics, network code, or Full Access requirement.

Features: Arabic letters, ASCII digits, punctuation/symbols, diacritics, alternate alef/waw/ya forms, space, return, repeat backspace, system keyboard switcher, and automatic light/dark colors. This first version has no autocorrect, predictive text, swipe typing, or emoji panel. Letter placement is a custom compact layout, not an exact copy of Apple's keyboard.

## Build on GitHub

The repository root must contain `project.yml`, `App`, `Keyboard`, `scripts`, and `.github/workflows/build-ipa.yml`.

1. Push the files to the `main` or `master` branch. The build starts automatically. You can also use **Actions → Build unsigned IPA → Run workflow**.
2. Open the workflow run and wait for it to finish successfully.
3. Under **Artifacts**, download **Arabic123-unsigned-IPA**. Unzip that download to obtain `Arabic123-unsigned.ipa`.

The workflow uses Xcode on a GitHub macOS runner. No Apple ID, certificate, signing secret, or xtool is needed for this unsigned build. It checks that both the app and embedded keyboard contain arm64 binaries before packaging. GitHub Actions usage is subject to your account's runner quota/billing settings; private-repository macOS jobs may consume included minutes or incur charges.

## Install and enable

The IPA is unsigned. Use your own signing/install method and ensure it signs **both the containing app and embedded .appex**. Installation and keyboard behavior must be tested on an iPhone; this source has not yet been compiled or device-tested.

After installation: Settings → General → Keyboard → Keyboards → Add New Keyboard → Arabic 123. Hold the globe key and choose Arabic 123. Leave Full Access disabled. Password fields and apps that disallow third-party keyboards may show Apple's keyboard instead.

## Build locally on a Mac

Install Xcode and XcodeGen, then run:

```sh
xcodegen generate
xcodebuild build -project Arabic123.xcodeproj -scheme Arabic123 -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' -derivedDataPath build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=''
python3 scripts/package_ipa.py
```
