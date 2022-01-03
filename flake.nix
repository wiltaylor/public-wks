{
  description = "A list of my public workspaces";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    wks.url = "github:wiltaylor/nixwks";
  };

  outputs = { self, nixpkgs, wks}: let
    lib = import ./lib;
    allPkgs = lib.mkPkgs { inherit nixpkgs; cfg = { allowUnfree = true;};};

  in {
    packages = lib.withDefaultSystems (sys: let 
      pkgs = allPkgs."${sys}";
      mkWks = wks.functions."${sys}".mkWks;

    in {
      games = mkWks {
        name = "games";
        system = sys;
        homeIsolation = true;
        packages = with pkgs; [ 
          steam 
          steam-run 
          lutris

          # full wine
          wineWowPackages.stagingFull
          winetricks

          # Linux games
          xonotic 
          minecraft 
          quakespasm 
          superTuxKart 
        ];

        startHook = ''
          ln -sf "$REALHOME/.pki" "$HOME/.pki"
          ln -sf "$REALHOME/.config/cef_user_data" "$HOME/.config/cef_user_data"
          ln -sf "$REALHOME/.config/pulse" "$HOME/.config/pulse"
        '';

        guiScript = ''
          OPT=$(echo -e "Steam\nLutris\nXonotic\Minecraft\nQuake\nSuper Tux Kart" | rofi -dmenu)
          case $OPT in
          "Steam")
            exec steam
          ;;
          "Lutris")
            exec lutris
          ;;
          "Xonotic")
            exec xonotic
          ;;
          "Minecraft")
            exec minecraft-launcher
          ;;
          "Quake")
            exec quake
          ;;
          "Super Tux Kart")
            exec supertuxkart
          ;;
          *)
          ;;
          esac
        '';
      };

      office = mkWks {
        name = "office";
        system = sys;
        homeIsolation = true;
        packages = with pkgs; [ wpsoffice foxitreader onlyoffice-bin ];
        guiScript = ''
          OPT=$(echo -e "WPS Office\nOnly Office\nFoxitReader" | rofi -dmenu)
          case $OPT in
          "WPS Office")
            exec wps
          ;;
          "Only Office")
            exec onlyoffice-desktopeditors
          ;;
          "FoxitReader")
            exec FoxitReader
          ;;
          *)
          ;;
          esac
        '';
      };

      orgSys = mkWks {
        name = "orgSys";
        system = sys;
        startHook = ''
          ln -sf "$REALHOME/vaults" "$HOME/vaults"
        '';
        homeIsolation = true;
        packages = with pkgs; [ obsidian foxitreader xmind zotero rofi];
        guiScript = ''
          OPT=$(echo -e "Obsidian\nZotero\nXMind\nFoxitReader" | rofi -dmenu)
          case $OPT in
          "Obsidian")
            exec obsidian
          ;;
          "Zotero")
            exec zotero
          ;;
          "FoxitReader")
            exec FoxitReader
          ;;
          "XMind")
            exec XMind
          ;;
          *)
          ;;
          esac
        '';
      };
    });
  };
}
