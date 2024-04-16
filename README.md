# Nix
My nix configs that I use for development.

Run:
```
nix run ~/P/nix#home-manager -- init --impure --switch ~/P/nix 
```
The `--impure` is necessary due to the use of nixGL's auto detection. This should be
fixed in the future by avoiding auto and directly specifying the host's drivers.

![it is 7:30 am](https://i.kym-cdn.com/photos/images/original/001/718/138/147.jpg)

## License
Licensed under [BSD 2-Clause Plus Patent](LICENSE-BSD)
