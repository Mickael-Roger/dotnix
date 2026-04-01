{ config, pkgs, lib, ... }:

let

  #rtk = pkgs.rustPlatform.buildRustPackage rec {
  #  pname = "rtk";
  #  version = "0.34.2";
  #  src = pkgs.fetchFromGitHub {
  #    owner = "rtk-ai";
  #    repo = "rtk";
  #    rev = "v${version}";
  #    hash = "sha256-oBaF3BdF4h7meP7+8gtqBSgOFn0wQq08bOkygpn/ukg=";
  #  };
  #  cargoHash = "sha256-o12ZlfUEzo/h1HuoqOY3BcpdLL+M8hJW7sJL+3dkflU=";
  #  nativeBuildInputs = [ pkgs.pkg-config ];
  #  buildInputs = [ pkgs.openssl ];
  #  meta = with lib; {
  #    description = "High-performance CLI proxy that reduces LLM token consumption by 60-90%";
  #    homepage = "https://www.rtk-ai.app";
  #    license = licenses.mit;
  #    maintainers = [ ];
  #    mainProgram = "rtk";
  #  };
  #};

in {
  environment.systemPackages = with pkgs; [
    #AI
    #rtk

    nodejs_22
    clang-tools
    docker
    go
    gopls
    delve
    gomodifytags
    impl
    gotests
    iferr
    borg-sans-mono
    claude-code
    #ansible-language-server
    gdb
    gef
    gcc
    lazygit
    llvm
    ccls
    bear
    python3
    python311Packages.pip
    python313Packages.numpy
    uv
    pyright
    cmake
    gnumake
    protobuf
    protobufc
    python3Packages.protobuf
    tinygo
    wazero
    nixd
    #wasmer
    wabt
    cloc
    android-studio
  ];
}
