{ fetchFromGitHub
, lib
, makeWrapper
, python3
}: with python3.pkgs;
let
  awscurl = buildPythonApplication rec {
    pname = "awscurl";
    version = "0.29";
    format = "setuptools";

    src = fetchFromGitHub {
      owner = "okigan";
      repo = "awscurl";
      rev = "e47119b";
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

    meta = {
      description = "curl-like tool with AWS Signature Version 4 request signing.";
      homepage = "https://github.com/okigan/awscurl";
      license = lib.licenses.mit;
      maintainers = with maintainers; [ isaacshaha ];
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
