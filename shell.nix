{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  name = "handecs";

  buildInputs = with pkgs; [
    lua5_1
    lua-language-server
    lua51Packages.luarocks
    stylua
    pre-commit
  ];
}
