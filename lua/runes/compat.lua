local compat = {}
compat.unpack = unpack or table.unpack
compat.identity = function(data) return data end
compat.pack = table.pack or function(...)
  return { n = select("#", ...), ... }
end

return compat
