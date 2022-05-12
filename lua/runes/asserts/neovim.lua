local neovim = {}

neovim.buffer_exists = function(buffer)
  if vim.api.nvim_buf_is_valid(buffer) and vim.api.nvim_buf_is_loaded(buffer) then
    return true, nil
  end
  return false, 'Supplied buffer is not valid or is not loaded'
end

return neovim
