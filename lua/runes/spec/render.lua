local render = {}

render.to_messages = function(results, spec)
  print(spec.meta.description)

    for _, line in ipairs(results) do
      local result = line.result
      print(line.description .. " → " .. (result.success and "Pass" or "*" .. result.context .. "* failed with *" .. result.error_message .. "*"))
    end
  print()
end


return render
