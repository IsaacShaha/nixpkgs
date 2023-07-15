{ fetchFromGitHub
, lib
, makeWrapper
, python3
}: with python3.pkgs;
let
  awscurl = buildPythonApplication {
    pname = "awscurl";
    # The latest stable version of awscurl (0.29) requires urllib3[secure],
    # which is deprecated and requires a package that is not in nixpkgs
    # (urllib3-secure-extra).
    version = "unstable-2023-07-10";
    format = "setuptools";

    src = fetchFromGitHub {
      owner = "okigan";
      repo = "awscurl";
      rev = "e47119b384edb33ca734f8b930e8ffde33882f3e";
      hash = "sha256-NVGPB29kgLYpJnAiSUYoC9M11G9J1shbe1ZXbywRyUU=";
    };

    doCheck = true;

    checkInputs = [
      mock
      pytest
    ];

    # Remove tests that require access to the internet or home directory.
    checkPhase = ''
      python -m pytest -k 'not integration_test'
    '';

    buildInputs = [
      cryptography
      pyopenssl
    ];

    propagatedBuildInputs = [
      botocore
      configargparse
      configparser
      requests
      urllib3
    ];

    meta = with lib; {
      description = "curl-like tool with AWS Signature Version 4 request signing.";
      homepage = "https://github.com/okigan/awscurl";
      license = licenses.mit;
      maintainers = [ maintainers.isaacshaha ];
    };
  };
in
stdenv.mkDerivation rec {
  inherit (awscurl) pname version meta;

  nativeBuildInputs = [
    makeWrapper
  ];

  # Wrap awscurl so that Python is not in the system path.
  buildCommand = ''
    makeWrapper ${awscurl}/bin/awscurl $out/bin/awscurl \
      --set PYTHONHOME "${python3}"
  '';
}
