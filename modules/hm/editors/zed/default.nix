# ═══════════════════════════════════════════════════════════════
# ⚙️  ZED EDITOR - WITH LSP WRAPPER
# ═══════════════════════════════════════════════════════════════
# ──── Wraps zed-editor so all LSPs are available in PATH ─────
# ──── Settings written via xdg.configFile (mutable=true)  ────
{
  pkgs,
  lib,
  ...
}: let
  # ──── LSP and tool packages ───────────────────────────────
  lspPackages = [
    pkgs.astro-language-server
    pkgs.biome
    pkgs.marksman
    pkgs.nil
    pkgs.nodejs
    pkgs.oxfmt
    pkgs.shfmt
    pkgs.tailwindcss-language-server
    pkgs.vue-language-server
  ];

  # ──── Wrap zed-editor with LSPs in PATH ───────────────────
  zedWithLSP = pkgs.symlinkJoin {
    name = "zed-with-lsp";
    paths = [pkgs.zed-editor];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/zed \
        --prefix PATH : ${lib.makeBinPath lspPackages}
    '';
  };

  # ──── Language/LSP config from _settings.nix ──────────────
  languageConfig = import ./_settings.nix {inherit pkgs;};

  # ──── Base editor settings ─────────────────────────────────
  baseSettings = {
    base_keymap = "None";
    vim_mode = false;
    helix_mode = true;
    ui_font_size = 16;
    buffer_font_size = 14;
    buffer_font_family = "GT Pressura Mono Trial";
    theme = {
      mode = "system";
      light = "Catppuccin Latte";
      dark = "Catppuccin Macchiato";
    };
    tab_size = 2;
    soft_wrap = "editor_width";
    show_whitespaces = "boundary";
    inline_completions = {disabled_in_languages = ["Nix"];};
    terminal = {
      font_family = "GT Pressura Mono Trial";
      font_size = 14;
    };
    assistant = {
      version = "2";
      enabled = true;
      default_model = {
        provider = "openrouter";
        model = "mistralai/devstral-2512:free";
      };
    };
    features = {
      edit_prediction_provider = "copilot";
    };
    telemetry = {
      metrics = false;
      diagnostics = false;
    };
  };

  # ──── Merged settings JSON ─────────────────────────────────
  settingsJSON = builtins.toJSON (baseSettings // languageConfig);
in {
  home.packages = [zedWithLSP];

  xdg.configFile."zed/settings.json" = {
    text = settingsJSON;
  };
}
