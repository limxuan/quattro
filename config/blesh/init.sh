# ble.sh initialization and keybindings

ble-bind -m emacs -x 'C-g' '__edit_command_line'
ble-bind -m vi_imap -x 'C-g' '__edit_command_line'
ble-bind -m emacs -x 'C-n' 'open_nvim'
ble-bind -m vi_imap -x 'C-n' 'open_nvim'
ble-bind -m emacs -x 'C-s' '__check_tmux'
ble-bind -m vi_imap -x 'C-s' '__check_tmux'
