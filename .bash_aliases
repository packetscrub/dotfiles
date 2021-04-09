# https://superuser.com/questions/603909/how-to-change-terminal-colors-when-connecting-to-ssh-hosts
function ssh_alias() {
    FG=$(xtermcontrol --get-fg)
    BG=$(xtermcontrol --get-bg)
    $(which ssh) "$@"
    xtermcontrol --fg="$FG"
    xtermcontrol --bg="$BG"
}
alias ssh=ssh_alias

alias ghidra='$HOME/ghidra/ghidraRun'
alias hxd='wine ~/.wine/drive_c/Program\ Files/HxD/HxD.exe &'
