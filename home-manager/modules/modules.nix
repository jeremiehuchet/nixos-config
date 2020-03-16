{ pkgs

  # Note, this should be "the standard library" + HM extensions.
, lib

  # Whether to enable module type checking.
, check ? true

# If disabled, the pkgs attribute passed to this function is used instead.
, useNixpkgsModule ? true
}:

with lib;

let

  hostPlatform = pkgs.stdenv.hostPlatform;

  loadModule = file: { condition ? true }: {
    inherit file condition;
  };

  allModules = [
    (loadModule ./accounts/email.nix { })
    (loadModule ./files.nix { })
    (loadModule ./home-environment.nix { })
    (loadModule ./manual.nix { })
    (loadModule ./misc/dconf.nix { })
    (loadModule ./misc/debug.nix { })
    (loadModule ./misc/fontconfig.nix { })
    (loadModule ./misc/gtk.nix { })
    (loadModule ./misc/lib.nix { })
    (loadModule ./misc/news.nix { })
    (loadModule ./misc/nixpkgs.nix { condition = useNixpkgsModule; })
    (loadModule ./misc/numlock.nix { condition = hostPlatform.isLinux; })
    (loadModule ./misc/pam.nix { })
    (loadModule ./misc/qt.nix { })
    (loadModule ./misc/submodule-support.nix { })
    (loadModule ./misc/version.nix { })
    (loadModule ./misc/xdg-mime.nix { condition = hostPlatform.isLinux; })
    (loadModule ./misc/xdg-mime-apps.nix { condition = hostPlatform.isLinux; })
    (loadModule ./misc/xdg-user-dirs.nix { condition = hostPlatform.isLinux; })
    (loadModule ./misc/xdg.nix { })
    (loadModule ./programs/abook.nix { condition = hostPlatform.isLinux; })
    (loadModule ./programs/afew.nix { })
    (loadModule ./programs/alacritty.nix { })
    (loadModule ./programs/alot.nix { })
    (loadModule ./programs/astroid.nix { })
    (loadModule ./programs/autorandr.nix { })
    (loadModule ./programs/bash.nix { })
    (loadModule ./programs/bat.nix { })
    (loadModule ./programs/beets.nix { })
    (loadModule ./programs/broot.nix { })
    (loadModule ./programs/browserpass.nix { })
    (loadModule ./programs/chromium.nix { condition = hostPlatform.isLinux; })
    (loadModule ./programs/command-not-found/command-not-found.nix { })
    (loadModule ./programs/direnv.nix { })
    (loadModule ./programs/eclipse.nix { })
    (loadModule ./programs/emacs.nix { })
    (loadModule ./programs/feh.nix { })
    (loadModule ./programs/firefox.nix { })
    (loadModule ./programs/fish.nix { })
    (loadModule ./programs/fzf.nix { })
    (loadModule ./programs/getmail.nix { condition = hostPlatform.isLinux; })
    (loadModule ./programs/git.nix { })
    (loadModule ./programs/gnome-terminal.nix { })
    (loadModule ./programs/go.nix { })
    (loadModule ./programs/gpg.nix { })
    (loadModule ./programs/home-manager.nix { })
    (loadModule ./programs/htop.nix { })
    (loadModule ./programs/info.nix { })
    (loadModule ./programs/irssi.nix { })
    (loadModule ./programs/lieer.nix { })
    (loadModule ./programs/jq.nix { })
    (loadModule ./programs/kakoune.nix { })
    (loadModule ./programs/keychain.nix { })
    (loadModule ./programs/kitty.nix { })
    (loadModule ./programs/lesspipe.nix { })
    (loadModule ./programs/lsd.nix { })
    (loadModule ./programs/man.nix { })
    (loadModule ./programs/matplotlib.nix { })
    (loadModule ./programs/mbsync.nix { })
    (loadModule ./programs/mercurial.nix { })
    (loadModule ./programs/mpv.nix { })
    (loadModule ./programs/msmtp.nix { })
    (loadModule ./programs/neomutt.nix { })
    (loadModule ./programs/neovim.nix { })
    (loadModule ./programs/newsboat.nix { })
    (loadModule ./programs/noti.nix { })
    (loadModule ./programs/notmuch.nix { })
    (loadModule ./programs/obs-studio.nix { })
    (loadModule ./programs/offlineimap.nix { })
    (loadModule ./programs/opam.nix { })
    (loadModule ./programs/password-store.nix { })
    (loadModule ./programs/pazi.nix { })
    (loadModule ./programs/pidgin.nix { })
    (loadModule ./programs/readline.nix { })
    (loadModule ./programs/rofi.nix { })
    (loadModule ./programs/rtorrent.nix { })
    (loadModule ./programs/skim.nix { })
    (loadModule ./programs/starship.nix { })
    (loadModule ./programs/ssh.nix { })
    (loadModule ./programs/taskwarrior.nix { })
    (loadModule ./programs/termite.nix { })
    (loadModule ./programs/texlive.nix { })
    (loadModule ./programs/tmux.nix { })
    (loadModule ./programs/urxvt.nix { })
    (loadModule ./programs/vim.nix { })
    (loadModule ./programs/vscode.nix { })
    (loadModule ./programs/vscode/haskell.nix { })
    (loadModule ./programs/z-lua.nix { })
    (loadModule ./programs/zathura.nix { })
    (loadModule ./programs/zsh.nix { })
    (loadModule ./services/blueman-applet.nix { })
    (loadModule ./services/cbatticon.nix { condition = hostPlatform.isLinux; })
    (loadModule ./services/compton.nix { })
    (loadModule ./services/dunst.nix { })
    (loadModule ./services/dwm-status.nix { condition = hostPlatform.isLinux; })
    (loadModule ./services/emacs.nix { condition = hostPlatform.isLinux; })
    (loadModule ./services/flameshot.nix { })
    (loadModule ./services/getmail.nix { condition = hostPlatform.isLinux; })
    (loadModule ./services/gnome-keyring.nix { })
    (loadModule ./services/gpg-agent.nix { })
    (loadModule ./services/grobi.nix { condition = hostPlatform.isLinux; })
    (loadModule ./services/hound.nix { condition = hostPlatform.isLinux; })
    (loadModule ./services/imapnotify.nix { condition = hostPlatform.isLinux; })
    (loadModule ./services/kbfs.nix { })
    (loadModule ./services/kdeconnect.nix { })
    (loadModule ./services/keepassx.nix { })
    (loadModule ./services/keybase.nix { })
    (loadModule ./services/lieer.nix { condition = hostPlatform.isLinux; })
    (loadModule ./services/lorri.nix { condition = hostPlatform.isLinux; })
    (loadModule ./services/mbsync.nix { })
    (loadModule ./services/mpd.nix { })
    (loadModule ./services/mpdris2.nix { condition = hostPlatform.isLinux; })
    (loadModule ./services/muchsync.nix { condition = hostPlatform.isLinux; })
    (loadModule ./services/network-manager-applet.nix { })
    (loadModule ./services/nextcloud-client.nix { })
    (loadModule ./services/owncloud-client.nix { })
    (loadModule ./services/parcellite.nix { })
    (loadModule ./services/password-store-sync.nix { condition = hostPlatform.isLinux; })
    (loadModule ./services/pasystray.nix { })
    (loadModule ./services/polybar.nix { })
    (loadModule ./services/random-background.nix { })
    (loadModule ./services/redshift.nix { })
    (loadModule ./services/rsibreak.nix { condition = hostPlatform.isLinux; })
    (loadModule ./services/screen-locker.nix { })
    (loadModule ./services/stalonetray.nix { })
    (loadModule ./services/status-notifier-watcher.nix { })
    (loadModule ./services/spotifyd.nix { condition = hostPlatform.isLinux; })
    (loadModule ./services/sxhkd.nix { condition = hostPlatform.isLinux; })
    (loadModule ./services/syncthing.nix { })
    (loadModule ./services/taffybar.nix { })
    (loadModule ./services/tahoe-lafs.nix { })
    (loadModule ./services/taskwarrior-sync.nix { condition = hostPlatform.isLinux; })
    (loadModule ./services/udiskie.nix { })
    (loadModule ./services/unclutter.nix { })
    (loadModule ./services/unison.nix { condition = hostPlatform.isLinux; })
    (loadModule ./services/window-managers/awesome.nix { })
    (loadModule ./services/window-managers/bspwm/default.nix { condition = hostPlatform.isLinux; })
    (loadModule ./services/window-managers/i3-sway/i3.nix { })
    (loadModule ./services/window-managers/i3-sway/sway.nix { condition = hostPlatform.isLinux; })
    (loadModule ./services/window-managers/xmonad.nix { })
    (loadModule ./services/xcape.nix { condition = hostPlatform.isLinux; })
    (loadModule ./services/xembed-sni-proxy.nix { condition = hostPlatform.isLinux; })
    (loadModule ./services/xscreensaver.nix { })
    (loadModule ./services/xsuspender.nix { condition = hostPlatform.isLinux; })
    (loadModule ./systemd.nix { })
    (loadModule ./xcursor.nix { })
    (loadModule ./xresources.nix { })
    (loadModule ./xsession.nix { })
    (loadModule (pkgs.path + "/nixos/modules/misc/assertions.nix") { })
    (loadModule (pkgs.path + "/nixos/modules/misc/meta.nix") { })
  ];

  modules = map (getAttr "file") (filter (getAttr "condition") allModules);

  pkgsModule = {
    config = {
      _module.args.baseModules = modules;
      _module.args.pkgs = lib.mkDefault pkgs;
      _module.check = check;
      lib = lib.hm;
    } // optionalAttrs useNixpkgsModule {
      nixpkgs.system = mkDefault pkgs.system;
    };
  };

in

  modules ++ [ pkgsModule ]
