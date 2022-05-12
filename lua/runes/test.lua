local statemaker = require("runes.state").statemaker
local identity = require("runes.compat").identity

local test = {}

test.init = function(case, initial_state)
  local success, setup = pcall(case.setup, initial_state)
  if success then
    return statemaker(case, setup)
  else
    error("Could not initialize the test case [" .. case.description .. "]",0)
  end
end

test.run_case = function(state)
  state.phase = "case"
  local env = { assert = state.assert, state = state.state }
  if type(state.state) == "table" then
    env = vim.tbl_extend("keep", env, state.state)
  end
  setfenv(state.test, vim.tbl_extend('force', getfenv(), env))
  local success, err = pcall(state.test, state.assert, state.state)

  return success, state, err
end

test.teardown = function(state)
  state.phase = "teardown"
  local env = { assert = state.assert, state = state.state }
  if type(state.state) == "table" then
    env = vim.tbl_extend("keep", env, state.state)
  end
  setfenv(state.test, vim.tbl_extend('force', getfenv(), env))
  local success, err = pcall(state.teardown, state.state, state.assert)

  return success, state, err
end

test.run = function(case, initial_state)
  local state = test.init(case, initial_state)

  -- TODO decide on what to if it fails (should we still run the teardown?)
  test.run_case(state)

  test.teardown(state)

  return state
end

test.new_case = function(tbl)
  return {
    description = tbl[1] or tbl.description or nil,
    labels = tbl.labels or {},
    setup = tbl.setup or (identity),
    test = tbl.test or error("Missing test function", 0),
    teardown = tbl.teardown or (identity),
  }
end

return test
