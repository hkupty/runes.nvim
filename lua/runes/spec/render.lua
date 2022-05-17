local status_codes = require("runes.state").status_codes
local run_failed = require("runes.state").run_failed
local render = {}

render.status_codes = {
  [status_codes.success] = "✓",
  [status_codes.fail] = "✗",
  [status_codes.error] = "⚠"
}

render.to_messages = function(spec, results)
  print("● " .. spec.meta.description)

  for _, line in ipairs(results) do
    local result = line.result
    print(" ↳ " .. line.description)
    if run_failed(result) then
      print("  ↳ " .. result.error_message)
      print()
    end
    for _, run in ipairs(line.run) do
      print("  ↳ " .. render.status_codes[run.status] .. " "  .. run.context)
      if run_failed(run) then
        print("    ↳ " .. run.error_message)
      end
    end
  end
  print()
end


return render
