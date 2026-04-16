self: super: {
  direnv = super.direnv.overrideAttrs (_old: {
    doCheck = false;
  });
}
