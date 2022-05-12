local logical = {}

logical.is_nil = function(a)
  if a == nil then
    return true, nil
  else
    return false, "supplied value is not nil"
  end
end

logical.is_not_nil = function(a)
  if a ~= nil then
    return true, nil
  else
    return false, "supplied value is nil"
  end
end

logical.is_true = function(a)
  if a == true then
    return true, nil
  else
    return false, "supplied value is not true (booelan)"
  end
end

logical.is_false = function(a)
  if a == false then
    return true, nil
  else
    return false, "supplied value is not false (booelan)"
  end
end

logical.is_truthy = function(a)
  if a then
    return true, nil
  else
    return false, "supplied value is not true-like"
  end
end

logical.is_falsey = function(a)
  if not a then
    return true, nil
  else
    return false, "supplied value is not false-like"
  end
end

logical.fail = function(message)
  return false, message or "Test aborted due to explicit failure"
end

return logical
