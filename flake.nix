{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
      };

      # Keep this in sync with pyproject.toml
      pythonInterpreter = pkgs.python311Packages.python;
    in {
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          pythonInterpreter
        ];

        shellHook = ''
            ROOT="$(git rev-parse --show-toplevel)"
            VENV_DIR="$ROOT/.venv"

            # Initialize venv only if it doesn't already exist
            if [ ! -d "$VENV_DIR" ]; then
              echo "Virtual environment not found. Creating..."
              python -m venv "$VENV_DIR"
            else
              echo "Activating existing virtual environment..."
            fi

            # Activate the venv
            source "$VENV_DIR/bin/activate"
            pip install -r requirements.txt
          '';
      };
    }
  );
}
