local types = {}

types.is_table = function(a)
  if type(a) == "table" then
    return true, nil
  else
    return false, "supplied value is not a table"
  end
end

types.is_function = function(a)
  if type(a) == "function" then
    return true, nil
  else
    return false, "supplied value is not a function"
  end
end

return types
