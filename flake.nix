{
  description = "Food Truck Recommender with Elixir 1.17.x and OTP 25";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";

      overlays = [
        (final: prev: {
          erlang = prev.erlang_25;
          elixir = prev.elixir_1_17;
          nodejs = prev.nodejs;
        })
      ];

      pkgs = import nixpkgs {
        inherit system;
        overlays = overlays;
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.elixir
          pkgs.erlang
          pkgs.nodejs
        ];
      };
    };
}