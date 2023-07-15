{ fetchFromGitHub
, lib
, python3
}:

with python3.pkgs;

buildPythonApplication rec {
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

  checkPhase = ''
    python -m pytest -k 'not request'
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
    maintainers = with maintainers; [ isaacshaha ];
  };
}
