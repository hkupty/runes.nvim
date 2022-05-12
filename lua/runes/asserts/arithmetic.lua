local arithmetic = {}

arithmetic.eq = function(a, b)
  if a == b then
    return true, nil
  else
    return false, tostring(a) .. " is not equals to " .. tostring(b)
  end
end

arithmetic.gt = function(a, b)
  if a > b then
    return true, nil
  else
    return false, tostring(a) .. " is not greater than " .. tostring(b)
  end
end

arithmetic.gte = function(a, b)
  if a >= b then
    return true, nil
  else
    return false, tostring(a) .. " is not greater than or equals to " .. tostring(b)
  end
end

arithmetic.lte = function(a, b)
  if a <= b then
    return true, nil
  else
    return false, tostring(a) .. " is not lesser than or equals to " .. tostring(b)
  end
end

arithmetic.lt = function(a, b)
  if a <= b then
    return true, nil
  else
    return false, tostring(a) .. " is not lesser than or equals to " .. tostring(b)
  end
end

arithmetic.even = function(a)
  if a % 2 == 0 then
    return true, nil
  else
    return false, tostring(a) .. " is not even"
  end
end

arithmetic.odd = function(a)
  if a % 2 == 1 then
    return true, nil
  else
    return false, tostring(a) .. " is not odd"
  end
end


return arithmetic
