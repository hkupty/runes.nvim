local identity = require("runes.compat").identity
local render = require("runes.spec.render")
local skip = require("runes.spec.skip")
local test = require("runes.test")
local spec = {}

local special_keys = {
  -- Test configuration
  config = true,
  labels = true,
  description = true,

  -- Spec-related
  spec_setup = true,
  spec_teardown = true,
  last = true,

  -- Test-related
  test_setup = true,
  test_teardown = true
}

local default_config = {
  immutable_state = true,
  collect = render.to_messages,
  skip_tests = skip.apply_all_rules
}

spec.spec_state = function(meta)
  local spec_setup = meta.spec_setup or function() return {} end
  local test_setup
  local test_teardown
  local spec_teardown

  if meta.test_setup ~= nil then
    if meta.config.immutable_state then
      test_setup = function(base_state)
        return meta.test_setup(vim.deepcopy(base_state))
      end
    else
      test_setup = meta.test_setup
    end
  else
    test_setup = identity
  end

  if meta.test_teardown ~= nil then
    test_teardown = function(test_state)
      return meta.test_teardown(test_state) or test_state
    end
  else
    test_teardown = identity
  end

  if meta.spec_teardown ~= nil then
    spec_teardown = function(base_state)
      return meta.spec_teardown(base_state) or base_state
    end
  else
    spec_teardown = identity
  end

  return {
    base_state = spec_setup(),
    test_setup = test_setup,
    test_teardown = test_teardown,
    spec_teardown = spec_setup
  }

end

spec.run_spec = function(test_spec)
  test_spec.meta.config = vim.tbl_deep_extend("keep", test_spec.meta.config or {}, default_config)
  local config = test_spec.meta.config -- aliasing
  local spec_state = spec.spec_state(test_spec.meta)

  local run_test = function(case)
    local state = test.run(case, spec_state.test_setup(spec_state.base_state))
    -- TODO Use same logic as in the teardown stage in `runes.test`
    spec_state.test_teardown(state.state)

    return state
  end

  local results = vim.tbl_map(run_test, vim.tbl_filter(config.skip_tests, test_spec.cases))

  spec_state.spec_teardown(spec_state.base_state)

  -- TODO move outside, this should just return
  config.collect(test_spec, results)
end

spec.assoc_case = function(tbl, data)
    local data_type = type(data)
    if data_type == "function" then
      data = test.new_case{description = ("test-case-" .. #tbl.cases), test = data}
    elseif data_type == "table" then
      data.description = data.description or ("test-case-" .. #tbl.cases)
    else
      error("A test case has to be either a table or a function. Using `runes.test.new_case` is recommendded.", 2)
    end

    table.insert(tbl.cases, data)
  end

spec.new_spec = function(spec_as_table)
  local tbl = {
    meta = {},
    cases = {},
  }

  for descr, data in pairs(spec_as_table) do
    if type(descr) == "string" then
      if special_keys[descr] then
        tbl.meta[descr] = data
      else
        error("'" .. descr .. "' is not a configuration key", 2)
      end
    end
  end

  for _, case in ipairs(spec_as_table) do
    spec.assoc_case(tbl, case)
  end

  return tbl
end

return spec
