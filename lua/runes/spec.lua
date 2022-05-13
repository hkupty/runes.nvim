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

spec.run_spec = function(test_spec)
  local config = vim.tbl_deep_extend("keep", test_spec.meta.config or {}, default_config)
  local spec_setup = test_spec.meta.spec_setup or function() return {} end
  local test_setup = test_spec.meta.test_setup or identity
  local test_teardown = test_spec.meta.test_teardown or identity
  local spec_teardown = test_spec.meta.spec_setup or identity

  -- If state is immutable, initial state is copied to all the tests
  -- However, if the state needs to be mutated, is is passed through
  local state_pass_fn = config.immutable_state and vim.deepcopy or identity

  local spec_data = spec_setup()

  local run_test = function(case)
    local state = test.run(case, test_setup(state_pass_fn(spec_data)))
    return test_teardown(state) or state -- ensure we always return the state, even if the teardown messes up
  end

  -- TODO allow configuring filter
  local results = vim.tbl_map(run_test, vim.tbl_filter(config.skip_tests, test_spec.cases))

  spec_teardown(spec_data)

  -- TODO move outside, this should just return
  config.collect(results, test_spec)
end

spec.assoc_case = function(tbl, data, descr)
    local data_type = type(data)
    if data_type == "function" then
      data = test.new_case{description = descr, test = data}
    elseif data_type == "table" then
      -- ensure all test cases have a description
      data.description = data.description or descr or ("test-case-" .. tostring(math.random(200)))
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
        spec.assoc_case(tbl, data, descr)
      end
    end
  end

  for _, case in ipairs(spec_as_table) do
    spec.assoc_case(tbl, case)
  end

  return tbl
end

return spec
