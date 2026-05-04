-- vim-slime: send text from vim to a tmux pane.
-- Default mappings: C-c C-c (send paragraph / visual selection),
-- C-c v (re-prompt for target pane).

vim.g.slime_target = "tmux"
vim.g.slime_default_config = {
  socket_name = "default",
  target_pane = "{last}", -- last active tmux pane
}
-- Don't prompt on first send; just use the default config above.
-- To override the target later, hit C-c v.
vim.g.slime_dont_ask_default = 1
