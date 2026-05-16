# Nix
My nix configs that I use for development.

## Installation
The `--impure` is necessary due to the use of nixGL's auto detection. This should be
fixed in the future by avoiding auto and directly specifying the host's drivers.

### For standalone home-manager on a devcontainer:
```
mkdir -p ~/.config/nix/nix.conf && echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --no-daemon
nix run ~/P/nix#home-manager -- init --switch
```

### For standalone home-manager on regular OS:
```
mkdir -p ~/.config/nix/nix.conf && echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
nix run ~/P/nix#home-manager -- init --switch
```

## Rebuilding

### For standalone home-manager:
```
nix run ~/P/nix#home-manager -- switch --impure --flake ~/P/nix
```
### For nix-darwin
```
sudo nix run ~/P/nix#darwin-rebuild -- switch --flake ~/P/nix
```
### For NixOS
```
sudo nixos-rebuild switch --flake ~/P/nix --impure
```

## License
Licensed under the [MIT-0 License](LICENSE-MIT-0).

![it is 7:30 am](https://i.kym-cdn.com/photos/images/original/001/718/138/147.jpg)
