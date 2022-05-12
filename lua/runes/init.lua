local spec = require("runes.spec")
local test = require("runes.test")
local asserts = require("runes.asserts")
local runes = {}

-- [[ public api ]] --

runes.spec = spec.new_spec
runes.test = test.new_case
runes.run_spec = spec.run_spec
runes.register_assert = asserts.register_assert
runes.deregister_assert = asserts.deregister_assert
runes.deregister_asserts = asserts.deregister_asserts

return runes
