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

  oc-monitor = pkgs.python3Packages.buildPythonPackage {
    pname = "opencode-monitor";
    version = "1.0.3";
    src = pkgs.fetchFromGitHub {
      owner = "Shlomob";
      repo = "ocmonitor-share";
      rev = "e9c44ecd4b8f8a3627dd898e8f06f49c2944370d";
      hash = "sha256-mCwGAZm/ilOwQvm7+UD3e/XEbRYFhIO+LKDCyLVMFmk=";
    };
    format = "pyproject";
    buildInputs = [ pkgs.python3Packages.setuptools ];
    propagatedBuildInputs = with pkgs.python3Packages; [
      click
      rich
      pydantic
      toml
      pyyaml
      prometheus-client
    ];
    doCheck = false;
  };

in {
  environment.systemPackages = with pkgs; [
    #AI
    #rtk
    oc-monitor

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
