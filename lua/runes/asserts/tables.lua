local tables = {}

tables.tbl_not_empty = function(tbl)
  if tbl ~= nil and #tbl > 0 then
    return true, nil
  end
  return false, 'Table is either null or empty'
end

tables.tbl_contains_value = function(tbl, value)
  if vim.tbl_filter(vim.tbl_flatten(tbl), value) then
    return true, nil
  end
  return false, "Table doesn't contain the value '" .. tostring(value)  .. "'"
end

return tables
