{
  home.file."probe.lua".text = ''
    local home_value = 1
  '';

  xdg = {
    configFile."nested.lua" = {
      text = ''
        local nested_value = 2
      '';
    };
  };

  programs.zsh.initContent = ''
    echo hmts_shell
  '';

  programs.firefox.profiles.${profile}.userContent = ''
    body { color: red; }
  '';

  # The SSH parser rejects trailing indentation at the end of an injection.
  programs.ssh.extraConfig = ''
    Host hmts-test
      User test
'';

  programs.nixvim.plugins.example.luaConfig.pre = ''
    local nixvim_value = 3
  '';

  annotated = /* lua */ ''
    local annotated_value = 4
  '';

  home.file."${name}.lua".text = ''
    dynamic_filename_content
  '';

  ordinary = "ordinary_string";
}
