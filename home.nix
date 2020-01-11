{ pkgs, ... }:

{
  home.packages = with pkgs; [
    jetbrains.idea-community
  ];

  programs.git = {
    enable = true;
    userName  = "Jeremie Huchet";
    userEmail = "jeremiehuchet@users.noreply.github.com";
    package = pkgs.gitAndTools.gitFull;
  };
}
