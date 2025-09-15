if status is-interactive
    set -g fish_greeting
    fzf_configure_bindings --directory=\e\ct
    set -gx EDITOR nvim
    set -gx RIPGREP_CONFIG_PATH "$HOME"/.config/ripgreprc
end

if string match -q Darwin $(uname)
    set -x HOMEBREW_NO_ENV_HINTS 1
    set -x HOMEBREW_NO_ANALYTICS 1
    fish_add_path --path /opt/homebrew/bin/
    fish_add_path --path /opt/homebrew/opt/gnu-sed/libexec/gnubin
else
    fish_add_path --path "$HOME"/.local/bin
end

if type -q fzf
    fzf --fish | source
end

if type -q zoxide
    zoxide init --cmd cd fish | source
end
