local state = require("runes.state")
local identity = require("runes.compat").identity

local test = {}

test.init = function(case, initial_state)
  local success, data = pcall(case.setup, initial_state)
  if success then
     -- If setup doesn't return a state we reuse the initial state
    return state.statemaker(case, data or initial_state)
  else
    vim.api.nvim_err_writeln("Failed to run `init phase` for test case " .. case.description .. ": " .. data)
    case.result = state.error_run{
      error_message = data,
      phase = "init"
    }
    return case
  end
end

test.run_case = function(case)
  case.phase = "test"
  local env = { assert = case.assert, state = case.state }
  if type(case.state) == "table" then
    env = vim.tbl_extend("keep", env, case.state)
  end
  setfenv(case.test, vim.tbl_extend('force', getfenv(), env))
  local success, data = pcall(case.test, case.assert, case.state)

  if not success then
    vim.api.nvim_err_writeln("Failed to run `test phase` for test case " .. case.description .. ": " .. (data or ""))
    case.result = state.error_run{
      error_message = data or "",
      phase = "test"
    }
  end

  return success, run, err
end

test.teardown = function(case)
  case.phase = "teardown"
  local env = { assert = case.assert, state = case.state }
  if type(case.state) == "table" then
    env = vim.tbl_extend("keep", env, case.state)
  end
  setfenv(case.test, vim.tbl_extend('force', getfenv(), env))
  local success, err = pcall(case.teardown, case.state, case.assert)

  if not success then
    vim.api.nvim_err_writeln("Failed to run `teardown phase` for test case " .. case.description .. ": " .. data)
    case.result = state.error_run{
      error_message = data,
      phase = "teardown"
    }
  end

  return success, run, err
end

test.run = function(case, initial_state)
  local run = test.init(case, initial_state)

  if state.run_failed(run.result) then
    return run
  end

  -- TODO decide on what to if it fails (should we still run the teardown?)
  test.run_case(run)

  if state.run_failed(run.result) then
    return run
  end

  test.teardown(run)

  return run
end

test.new_case = function(tbl)
  return {
    description = tbl[1] or tbl.description or nil,
    labels = tbl.labels or {},
    setup = tbl.setup or identity,
    test = tbl.test or error("Missing test function", 0),
    teardown = tbl.teardown or identity,
  }
end

return test
