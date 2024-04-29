self: super: {
  mods = super.mods.overrideAttrs (oldAttrs: rec {
    version = "1.2.2";
    src = super.fetchFromGitHub {
      owner = "charmbracelet";
      repo = "mods";
      rev = "v${version}";
      hash = "sha256-ecmfWnrd9gwIEGAOIcOeUnfmkKmq9dLxpKqAHJemhvU="; # Replace with the actual hash
    };
    vendorHash = "sha256-pJ31Lsa5VVix3BM4RrllQA3MJ/JeNIKfQ8RClyFfXCI=";
  });
}
