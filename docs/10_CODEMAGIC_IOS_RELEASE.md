# Codemagic iOS Release

This project uses `codemagic.yaml` for signed iOS builds and TestFlight upload.

## Required Apple setup

1. Join the Apple Developer Program.
2. Create the app in App Store Connect.
3. Use this bundle identifier:

```txt
com.hanjasoook.app
```

4. Create an App Store Connect API key with App Manager access.
5. Add the key in Codemagic Team settings > Team integrations > Developer Portal.
6. Name the Codemagic integration:

```txt
codemagic
```

## Required Codemagic environment group

Create an environment variable group named:

```txt
hanja_soook_env
```

Add these variables:

```txt
SUPABASE_URL
SUPABASE_ANON_KEY
APP_ENV
APP_STORE_APPLE_ID
```

Keep `SUPABASE_ANON_KEY` secret. `APP_STORE_APPLE_ID` is the numeric Apple ID for
the App Store Connect app record.

## Signing setup

In Codemagic, configure iOS code signing identities for App Store distribution.
The workflow fetches signing files by:

```txt
distribution_type: app_store
bundle_identifier: com.hanjasoook.app
```

The build will fail early if the Supabase values or Apple app ID are missing.

## Workflow behavior

The `ios-testflight` workflow:

1. Creates a temporary `.env` file from Codemagic environment variables.
2. Applies iOS provisioning profiles to the Xcode project.
3. Runs `flutter pub get`.
4. Runs CocoaPods install.
5. Runs `flutter analyze`.
6. Runs `flutter test`.
7. Builds a signed release IPA with `--dart-define-from-file=.env`.
8. Uploads the IPA to App Store Connect.

`submit_to_testflight` and `submit_to_app_store` are intentionally false. After
the first upload is visible in App Store Connect, distribute it to TestFlight or
submit it for review manually.
