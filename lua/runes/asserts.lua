local pack = require("runes.compat").pack
local asserts = {}

asserts.custom_asserts = {}

asserts.register_assert = function(name, assert_fn)
  if (asserts.custom_asserts[name] == nil) then
    asserts.custom_asserts[name] = assert_fn
  else
    error("Assertion function with name " .. name .. " is already registered", 2)
  end
end

asserts.deregister_assert = function(name)
  asserts.custom_asserts[name] = nil
end

asserts.deregister_asserts = function(...)
  local args = pack(...)
  local i
  for i=1, args.n do
    asserts.custom_asserts[args[i]] = nil
  end
end

return asserts
