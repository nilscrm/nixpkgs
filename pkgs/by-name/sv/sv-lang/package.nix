{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  catch2_3,
  cmake,
  ninja,
  fmt_11,
  mimalloc,
  python3,
  llvmPackages_19,
}:

stdenv.mkDerivation rec {
  pname = "sv-lang";
  version = "8.1";

  src = fetchFromGitHub {
    owner = "MikePopoloski";
    repo = "slang";
    rev = "v${version}";
    sha256 = "sha256-bAYrpNIGKO1ms5ULwbizcMja8M5bIAcjfLoMcpB8iig=";
  };

  postPatch = ''
    substituteInPlace external/CMakeLists.txt \
      --replace-fail 'set(mimalloc_min_version "2.1")' 'set(mimalloc_min_version "${lib.versions.majorMinor mimalloc.version}")'
  '';

  cmakeFlags = [
    # fix for https://github.com/NixOS/nixpkgs/issues/144170
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DCMAKE_INSTALL_LIBDIR=lib"

    "-DSLANG_INCLUDE_TESTS=${if doCheck then "ON" else "OFF"}"
    "-DSLANG_USE_BUNDLED_FMT=OFF"
  ];

  nativeBuildInputs = [
    cmake
    python3
    ninja
    llvmPackages_19.clang-tools
  ];

  buildInputs = [
    boost
    fmt_11
    mimalloc
    # though only used in tests, cmake will complain its absence when configuring
    catch2_3
  ];

  doCheck = true;

  meta = with lib; {
    description = "SystemVerilog compiler and language services";
    homepage = "https://github.com/MikePopoloski/slang";
    license = licenses.mit;
    maintainers = with maintainers; [ sharzy ];
    mainProgram = "slang";
    platforms = platforms.all;
  };
}
