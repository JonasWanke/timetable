{
  inputs = {
    nixpkgs.url =
      "github:nixos/nixpkgs?ref=a22a985f13d58b2bafb4964dd2bdf6376106a2d2";
    # https://github.com/NixOS/nixpkgs/pull/311815
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };

        flutter = pkgs.flutterPackages.v3_22;

        # Android
        androidSdkArgs = {
          buildToolsVersions = [ "30.0.3" ];
          platformVersions = [ "34" ];
        };
        androidComposition =
          pkgs.androidenv.composeAndroidPackages androidSdkArgs;
        androidSdk = androidComposition.androidsdk;
        androidEmulator = pkgs.androidenv.emulateApp {
          name = "Emulator";
          platformVersion = "34";
          systemImageType = "google_apis_playstore";
          abiVersion = "x86_64";
          configOptions = {
            # https://android.googlesource.com/platform/external/qemu/+/refs/heads/master/android/avd/hardware-properties.ini
            "hw.ramSize" = "4096";
            "hw.lcd.width" = "1170";
            "hw.lcd.height" = "2532";
            "hw.lcd.density" = "460";
            "hw.keyboard" = "yes";
          };
          sdkExtraArgs = androidSdkArgs;
        };
      in {
        devShell = with pkgs;
          mkShell {
            ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
            FLUTTER_ROOT = flutter;
            buildInputs = [ androidEmulator androidSdk flutter ];
          };
      });
}
