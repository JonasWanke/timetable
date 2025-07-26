{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };

        flutter = pkgs.flutterPackages.v3_32;

        # Android
        androidSdkArgs = {
          buildToolsVersions = [ "30.0.3" ];
          platformVersions = [ "34" ];
        };
        androidComposition = pkgs.androidenv.composeAndroidPackages androidSdkArgs;
        androidSdk = androidComposition.androidsdk;
      in
      {
        devShell =
          with pkgs;
          mkShell {
            ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
            FLUTTER_ROOT = flutter;
            buildInputs = [
              androidSdk
              flutter
            ];
          };
      }
    );
}
