{
  lib,
  fetchFromGitHub,
  python3,
  stdenv,
  nixosTests,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "prelockd";
  version = "0.9";

  src = fetchFromGitHub {
    owner = "hakavlad";
    repo = "prelockd";
    rev = "v${finalAttrs.version}";
    hash = "sha256-OhKejs/G+c2c+aVuJ5yqHrPy5H9LxBERP3A7KBRkOg8=";
  };

  outputs = [ "out" "man" ];

  buildInputs = [ python3 ];

  patchPhase = ''
    patchShebangs .

    substituteInPlace prelockd.service.in \
      --replace-fail ":TARGET_SBINDIR:" $out/bin \
      --replace-fail ":TARGET_SYSCONFDIR:" /etc

    substituteInPlace prelockd.8 \
      --replace-fail ":DATADIR:" "/share" \
      --replace-fail ":SYSCONFDIR:" "/etc"
  '';

  installPhase = ''
    mkdir -p $out/{sbin,etc,share/{,doc/}prelockd,lib/systemd/system} $man/share/man/man8

    install -m0755 prelockd $out/sbin/prelockd
  	install -m0644 prelockd.conf $out/etc/prelockd.conf
  	install -m0644 prelockd.conf $out/share/prelockd/prelockd.conf
  	install -m0644 README.md $out/share/doc/prelockd/README.md
  	install -m0644 MANPAGE.md $out/share/doc/prelockd/MANPAGE.md

  	install -m0644 prelockd.service.in $out/lib/systemd/system/prelock.service
  	chcon -t systemd_unit_file_t $out/lib/systemd/system/prelock.service || :

  	gzip -9cn prelockd.8 > $man/share/man/man8/prelockd.8.gz
  '';

  # makeFlags = [
  #   "PREFIX=${placeholder "out"}"
  #   "SYSCONFDIR=${placeholder "out"}/etc"
  #   "SYSTEMDUNITDIR=${placeholder "out"}/lib/systemd/system"
  # ] ++ lib.optionals withManpage [ "MANDIR=${placeholder "man"}/share/man" ];

  # TODO: tests
  # passthru.tests = {
  #   inherit (nixosTests) prelockd;
  # };

  meta = {
    homepage = "https://github.com/hakavlad/prelockd";
    description = "Lock executables and shared libraries in memory to improve system responsiveness under low-memory conditions";
    longDescription = ''
      prelockd is a daemon that locks memory mapped executables and
      shared libraries in memory to improve system responsiveness under
      low-memory conditions.
    '';
    licence = lib.licences.mit;
    mainProgram = "prelockd";
    maintainers = with lib.maintainers; [
      
    ];
    platforms = lib.platforms.linux;
  };  
})
