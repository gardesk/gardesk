# ============ GARDESK SUITE ============
# Modular X11 desktop environment
# https://gar.musicsian.com
#
# NOTE: garlaunch and garclip use path dependencies to gartk,
# so they need the full monorepo source.

# Shared source for the entire gardesk monorepo (with submodules)
gardesk-src = pkgs.fetchgit {
  url = "https://github.com/gardesk/gardesk";
  rev = "trunk";  # TODO: pin to specific commit for reproducibility
  hash = "";  # TODO: compute with `nix-prefetch-git --fetch-submodules https://github.com/gardesk/gardesk trunk`
  fetchSubmodules = true;
};

# Shared buildInputs for X11/Cairo/Pango components
gardesk-x11-deps = with pkgs; [
  xorg.libxcb
  xorg.libX11
  xorg.libXrandr
  xorg.libXfixes
];

gardesk-cairo-deps = with pkgs; [
  cairo
  pango
  glib
  harfbuzz
  freetype
  fontconfig
];

# ---- gar: Tiling window manager ----
gar = pkgs.rustPlatform.buildRustPackage {
  pname = "gar";
  version = "0.1.0";
  src = gardesk-src;
  sourceRoot = "source/gar";
  cargoHash = "";  # TODO: build to get hash

  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = gardesk-x11-deps;

  # Build both gar and garctl from workspace
  cargoBuildFlags = [ "-p" "gar" "-p" "garctl" ];

  postInstall = ''
    # Install XSession desktop entry for display managers
    mkdir -p $out/share/xsessions
    cat > $out/share/xsessions/gar.desktop << EOF
    [Desktop Entry]
    Name=gar
    Comment=gar tiling window manager
    Exec=$out/bin/gar
    Type=XSession
    DesktopNames=gar
    EOF

    # Install session script
    mkdir -p $out/share/gar
    install -Dm755 gar-session.sh $out/share/gar/gar-session.sh
    substituteInPlace $out/share/gar/gar-session.sh \
      --replace 'exec gar' "exec $out/bin/gar"
  '';

  meta = {
    description = "Tiling window manager with Lua configuration and smart splits";
    homepage = "https://github.com/gardesk/gar";
    license = pkgs.lib.licenses.mit;
  };
};

# ---- garbar: Status bar ----
garbar = pkgs.rustPlatform.buildRustPackage {
  pname = "garbar";
  version = "0.1.0";
  src = gardesk-src;
  sourceRoot = "source/garbar";
  cargoHash = "";  # TODO

  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = gardesk-x11-deps ++ gardesk-cairo-deps;

  cargoBuildFlags = [ "-p" "garbar" "-p" "garbarctl" ];

  postInstall = ''
    mkdir -p $out/share/applications
    cat > $out/share/applications/garbar.desktop << EOF
    [Desktop Entry]
    Name=Garbar
    Comment=Status bar for gar desktop suite
    Exec=$out/bin/garbar daemon
    Terminal=false
    Type=Application
    Categories=System;
    EOF
  '';

  meta = {
    description = "Status bar with Cairo/Pango rendering for the gar desktop suite";
    homepage = "https://github.com/gardesk/garbar";
    license = pkgs.lib.licenses.mit;
  };
};

# ---- garbg: Wallpaper daemon ----
garbg = pkgs.rustPlatform.buildRustPackage {
  pname = "garbg";
  version = "0.1.0";
  src = gardesk-src;
  sourceRoot = "source/garbg";
  cargoHash = "";  # TODO

  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = gardesk-x11-deps ++ [ pkgs.openssl ];

  postInstall = ''
    mkdir -p $out/share/applications
    cat > $out/share/applications/garbg.desktop << EOF
    [Desktop Entry]
    Name=Garbg
    Comment=Wallpaper daemon with animation support
    Exec=$out/bin/garbg daemon
    Terminal=false
    Type=Application
    Categories=System;
    NoDisplay=true
    EOF
  '';

  meta = {
    description = "Wallpaper daemon with animation and slideshow support";
    homepage = "https://github.com/gardesk/garbg";
    license = pkgs.lib.licenses.mit;
  };
};

# ---- garshot: Screenshot utility ----
garshot = pkgs.rustPlatform.buildRustPackage {
  pname = "garshot";
  version = "0.1.0";
  src = gardesk-src;
  sourceRoot = "source/garshot";
  cargoHash = "";  # TODO

  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = gardesk-x11-deps ++ gardesk-cairo-deps;

  cargoBuildFlags = [ "-p" "garshot" "-p" "garshotctl" ];

  postInstall = ''
    mkdir -p $out/share/applications
    cat > $out/share/applications/garshot.desktop << EOF
    [Desktop Entry]
    Name=Garshot
    Comment=Screenshot utility with blur selection overlay
    Exec=$out/bin/garshot select
    Terminal=false
    Type=Application
    Categories=Utility;Graphics;
    EOF
  '';

  meta = {
    description = "Screenshot utility with interactive blur selection overlay";
    homepage = "https://github.com/gardesk/garshot";
    license = pkgs.lib.licenses.mit;
  };
};

# ---- garlock: Screen locker ----
garlock = pkgs.rustPlatform.buildRustPackage {
  pname = "garlock";
  version = "0.1.0";
  src = gardesk-src;
  sourceRoot = "source/garlock";
  cargoHash = "";  # TODO

  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = gardesk-x11-deps ++ gardesk-cairo-deps ++ [ pkgs.pam ];

  postInstall = ''
    mkdir -p $out/share/applications
    cat > $out/share/applications/garlock.desktop << EOF
    [Desktop Entry]
    Name=Garlock
    Comment=Screen locker with PAM authentication
    Exec=$out/bin/garlock
    Terminal=false
    Type=Application
    Categories=System;Security;
    NoDisplay=true
    EOF
  '';

  meta = {
    description = "Screen locker with PAM authentication for the gar desktop suite";
    homepage = "https://github.com/gardesk/garlock";
    license = pkgs.lib.licenses.mit;
  };
};

# ---- garlaunch: Application launcher (needs full tree for gartk) ----
garlaunch = pkgs.rustPlatform.buildRustPackage {
  pname = "garlaunch";
  version = "0.2.0";
  src = gardesk-src;
  # NOTE: Don't set sourceRoot - we need full tree for gartk path deps
  cargoRoot = "garlaunch";
  cargoHash = "";  # TODO

  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = gardesk-x11-deps ++ gardesk-cairo-deps;

  cargoBuildFlags = [ "-p" "garlaunch" "-p" "garlaunchctl" ];

  postInstall = ''
    mkdir -p $out/share/applications
    cat > $out/share/applications/garlaunch.desktop << EOF
    [Desktop Entry]
    Name=Garlaunch
    Comment=Application launcher with fuzzy search
    Exec=$out/bin/garlaunch
    Terminal=false
    Type=Application
    Categories=Utility;
    EOF
  '';

  meta = {
    description = "Application launcher with fuzzy search for the gar desktop suite";
    homepage = "https://github.com/gardesk/garlaunch";
    license = pkgs.lib.licenses.mit;
  };
};

# ---- garclip: Clipboard manager (needs full tree for gartk) ----
garclip = pkgs.rustPlatform.buildRustPackage {
  pname = "garclip";
  version = "0.1.0";
  src = gardesk-src;
  # NOTE: Don't set sourceRoot - garclip-picker needs gartk path deps
  cargoRoot = "garclip";
  cargoHash = "";  # TODO

  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = gardesk-x11-deps ++ gardesk-cairo-deps;

  cargoBuildFlags = [ "-p" "garclip" "-p" "garclipctl" "-p" "garclip-picker" ];

  postInstall = ''
    mkdir -p $out/share/applications
    cat > $out/share/applications/garclip.desktop << EOF
    [Desktop Entry]
    Name=Garclip
    Comment=Clipboard manager with history
    Exec=$out/bin/garclip-picker
    Terminal=false
    Type=Application
    Categories=Utility;
    EOF
  '';

  meta = {
    description = "Clipboard manager with history for the gar desktop suite";
    homepage = "https://github.com/gardesk/garclip";
    license = pkgs.lib.licenses.mit;
  };
};

# ---- gardm: Display manager (needs PAM config and systemd) ----
# This is more complex - needs a NixOS module for proper integration
gardm = pkgs.rustPlatform.buildRustPackage {
  pname = "gardm";
  version = "0.1.0";
  src = gardesk-src;
  sourceRoot = "source/gardm";
  cargoHash = "";  # TODO

  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = gardesk-x11-deps ++ gardesk-cairo-deps ++ [ pkgs.pam ];

  cargoBuildFlags = [ "-p" "gardmd" "-p" "gardm-greeter" ];

  postInstall = ''
    # Install config template
    mkdir -p $out/share/gardm
    if [ -f etc/config.toml ]; then
      install -Dm644 etc/config.toml $out/share/gardm/config.toml.example
    fi

    # Install PAM config template (actual install handled by NixOS module)
    mkdir -p $out/share/gardm/pam.d
    cat > $out/share/gardm/pam.d/gardm << EOF
    #%PAM-1.0
    auth       include      login
    account    include      login
    password   include      login
    session    include      login
    EOF
  '';

  passthru.providedSessions = [ "gar" ];

  meta = {
    description = "Display manager with graphical greeter for the gar desktop suite";
    homepage = "https://github.com/gardesk/gardm";
    license = pkgs.lib.licenses.mit;
  };
};

# ============ END GARDESK SUITE ============
