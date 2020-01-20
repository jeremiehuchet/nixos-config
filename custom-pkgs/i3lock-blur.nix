{ fetchFromGitHub, stdenv, pkgconfig, autoreconfHook, which, libxcb
, xcbutilkeysyms, xcbutilimage, pam, libX11, libev, cairo, libxkbcommon
, libxkbfile, libGL }:

stdenv.mkDerivation rec {
  pname = "i3lock-blur";
  version = "2.10";

  src = fetchFromGitHub {
    owner = "karulont";
    repo = pname;
    rev = version;
    sha256 = "1bd5nrlga5g1sz1f64gnc3dqy8yfrr4q1ss59krymbpxa1hhf55c";
  };

  nativeBuildInputs = [ pkgconfig autoreconfHook ];
  buildInputs = [
    which
    libxcb
    xcbutilkeysyms
    xcbutilimage
    pam
    libX11
    libev
    cairo
    libxkbcommon
    libxkbfile
    libGL
  ];

  makeFlags = [ "all" ];
  installFlags = [ "PREFIX=\${out}" "SYSCONFDIR=\${out}/etc" ];
  postInstall = ''
    mkdir -p $out/share/man/man1
    cp *.1 $out/share/man/man1
  '';

  meta = with stdenv.lib; {
    description = "i3lock with transparent blurring background";
    longDescription = ''
      Simple screen locker. After locking, a desktop screenshot is shown, and a
      ring-shaped unlock-indicator gives feedback for every keystroke. After entering
      your password, the screen is unlocked again.
    '';
    homepage = "https://github.com/karulont/i3lock-blur/";
    maintainers = [ ];
    license = licenses.bsd3;
    platforms = platforms.all;
  };

}
