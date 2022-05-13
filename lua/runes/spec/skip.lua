local skip = {}

skip.prefixed_with_underscore = function(case)
  return not vim.startswith(case.description, "_")
end

skip.has_skip_label = function(case)
  return not vim.tbl_contains(case.labels, "skip")
end

skip.apply_all_rules = function(case)
  for rule_name, rule in pairs(skip) do

    -- ignore itself to avoid recursion
    if rule_name ~= "apply_all_rules" then
      if not rule(case) then
        return false
      end
    end
  end
  return true
end

return skip
