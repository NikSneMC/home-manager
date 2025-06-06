{ lib, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: rec {
      emacs = pkgs.writeShellScriptBin "dummy-emacs-27.2" "" // {
        outPath = "@emacs@";
      };
      emacsPackagesFor =
        _:
        lib.makeScope super.newScope (_: {
          emacsWithPackages = _: emacs;
        });
    })
  ];

  programs.emacs.enable = true;
  services.emacs.enable = true;
  services.emacs.client.enable = true;
  services.emacs.extraOptions = [
    "-f"
    "exwm-enable"
  ];

  nmt.script = ''
    assertPathNotExists home-files/.config/systemd/user/emacs.socket
    assertFileExists home-files/.config/systemd/user/emacs.service
    assertFileExists home-path/share/applications/emacsclient.desktop

    assertFileContent \
      home-files/.config/systemd/user/emacs.service \
      ${pkgs.substitute {
        src = ./emacs-service-emacs.service;
        substitutions = [
          "--replace"
          "@runtimeShell@"
          pkgs.runtimeShell
        ];
      }}

    assertFileContent \
      home-path/share/applications/emacsclient.desktop \
      ${./emacs-27-emacsclient.desktop}
  '';
}
