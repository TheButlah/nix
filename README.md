# Nix
My nix configs that I use for development.

## Secrets

Some machines require secrets to be set up. For `ryan-worldcoin-hil`, you must
set up a github runner token. See the configuration.nix for the file path that
is expected.

## Installation
The `--impure` is necessary due to the use of nixGL's auto detection. This should be
fixed in the future by avoiding auto and directly specifying the host's drivers.

### For standalone home-manager:
```
nix run ~/P/nix#home-manager -- init --impure --switch ~/P/nix
```
### For nix-darwin
```
nix run ~/P/nix#darwin-rebuild -- switch --flake ~/P/nix
```
### For NixOS
```
sudo nixos-rebuild switch --flake ~/P/nix --impure
```

## License
Licensed under [BSD 2-Clause Plus Patent](LICENSE-BSD)

![it is 7:30 am](https://i.kym-cdn.com/photos/images/original/001/718/138/147.jpg)
