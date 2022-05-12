return vim.tbl_extend("keep",
  require("runes.asserts.arithmetic"),
  require("runes.asserts.logical"),
  require("runes.asserts.types"),
  require("runes.asserts.neovim")
)
