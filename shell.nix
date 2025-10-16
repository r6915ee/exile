{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  name = "exile";

  buildInputs = with pkgs; [
    lua5_1
    lua-language-server
    lua51Packages.luarocks
    stylua
    pre-commit
  ];
}
