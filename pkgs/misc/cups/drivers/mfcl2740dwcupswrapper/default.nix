{ stdenv, fetchurl, dpkg, makeWrapper, coreutils, gnugrep, gnused, perl, mfcl2740dwlpr }:

stdenv.mkDerivation rec {
  name = "mfcl2740dwcupswrapper-${version}";
  version = "3.2.0-1";

  src = fetchurl {
    url = "https://download.brother.com/welcome/dlf101726/${name}.i386.deb";
    sha256 = "078453e19f20ab6c7fc4d63c3e09f162f3d1410c04c23a294b6ffbd720b35ffb";
  };

  nativeBuildInputs = [ dpkg makeWrapper ];

  unpackPhase = "dpkg-deb -x $src $out";

  installPhase = ''
    basedir=${mfcl2740dwlpr}/opt/brother/Printers/MFCL2740DW
    dir=$out/opt/brother/Printers/MFCL2740DW

    substituteInPlace $dir/cupswrapper/brother_lpdwrapper_MFCL2740DW \
      --replace /usr/bin/perl ${perl}/bin/perl \
      --replace "basedir =~" "basedir = \"$basedir\"; #" \
      --replace "PRINTER =~" "PRINTER = \"MFCL2740DW\"; #"

    substituteInPlace $dir/cupswrapper/paperconfigml1 \
      --replace /usr/bin/perl ${perl}/bin/perl

    wrapProgram $dir/cupswrapper/brother_lpdwrapper_MFCL2740DW \
      --prefix PATH : ${stdenv.lib.makeBinPath [ coreutils gnugrep gnused ]}

    mkdir -p $out/lib/cups/filter
    mkdir -p $out/share/cups/model

    ln $dir/cupswrapper/brother_lpdwrapper_MFCL2740DW $out/lib/cups/filter
    ln $dir/cupswrapper/brother-MFCL2740DW-cups-en.ppd $out/share/cups/model
  '';

  meta = {
    description = "Brother MFC-L2740DW CUPS wrapper driver";
    homepage = http://www.brother.com/;
    license = stdenv.lib.licenses.gpl2;
    platforms = [ "x86_64-linux" "i686-linux" ];
    maintainers = [ stdenv.lib.maintainers.enzime ];
  };
}
