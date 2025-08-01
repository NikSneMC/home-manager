{
  config,
  pkgs,
  lib,
  ...
}:

{
  xdg.enable = lib.mkIf pkgs.stdenv.isDarwin false;

  programs.k9s = {
    enable = true;
    package = config.lib.test.mkStubPackage { };

    settings = {
      k9s = {
        refreshRate = 2;
        maxConnRetry = 5;
        enableMouse = true;
        headless = false;
        ui.skin = "default";
      };
    };
    hotKeys = {
      shift-0 = {
        shortCut = "Shift-0";
        description = "Viewing pods";
        command = "pods";
      };
    };
    skins = {
      "default" = {
        k9s = {
          body = {
            fgColor = "dodgerblue";
            bgColor = "#ffffff";
            logoColor = "#0000ff";
          };
          info = {
            fgColor = "lightskyblue";
            sectionColor = "steelblue";
          };
        };
      };
      "default2" = ./example-skin-expected.yaml;
      "alt-skin" = {
        k9s = {
          body = {
            fgColor = "orangered";
            bgColor = "#ffffff";
            logoColor = "#0000ff";
          };
          info = {
            fgColor = "red";
            sectionColor = "mediumvioletred";
          };
        };
      };
    };
    aliases = {
      pp = "v1/pods";
    };
    plugins = {
      fred = {
        shortCut = "Ctrl-L";
        description = "Pod logs";
        scopes = [ "po" ];
        command = "kubectl";
        background = false;
        args = [
          "logs"
          "-f"
          "$NAME"
          "-n"
          "$NAMESPACE"
          "--context"
          "$CLUSTER"
        ];
      };
    };
    views = {
      "v1/pods" = {
        columns = [
          "AGE"
          "NAMESPACE"
          "NAME"
          "IP"
          "NODE"
          "STATUS"
          "READY"
        ];
      };
    };
  };

  nmt.script =
    let
      configDir = if !pkgs.stdenv.isDarwin then ".config/k9s" else "Library/Application Support/k9s";
    in
    ''
      assertFileExists "home-files/${configDir}/config.yaml"
      assertFileContent \
        "home-files/${configDir}/config.yaml" \
        ${./example-config-expected.yaml}
      assertFileExists "home-files/${configDir}/skins/default.yaml"
      assertFileContent \
        "home-files/${configDir}/skins/default.yaml" \
        ${./example-skin-expected.yaml}
      assertFileExists "home-files/${configDir}/skins/default2.yaml"
      assertFileContent \
        "home-files/${configDir}/skins/default2.yaml" \
        ${./example-skin-expected.yaml}
      assertFileExists "home-files/${configDir}/skins/alt-skin.yaml"
      assertFileContent \
        "home-files/${configDir}/skins/alt-skin.yaml" \
        ${./example-skin-expected-alt.yaml}
      assertFileContent \
        "home-files/${configDir}/hotkeys.yaml" \
        ${./example-hotkeys-expected.yaml}
      assertFileExists "home-files/${configDir}/aliases.yaml"
      assertFileContent \
        "home-files/${configDir}/aliases.yaml" \
        ${./example-aliases-expected.yaml}
      assertFileContent \
        "home-files/${configDir}/plugins.yaml" \
        ${./example-plugins-expected.yaml}
      assertFileExists "home-files/${configDir}/views.yaml"
      assertFileContent \
        "home-files/${configDir}/views.yaml" \
        ${./example-views-expected.yaml}
    '';
}
