local default_assert = require("runes.default_asserts")
local assert = require("runes.asserts")

local state = {}

state.status_codes = {
  -- skip = -1 -- TODO mark skip as a status code instead of removing from the list
  success = 0,
  fail = 1,
  error = 2,
}

state.with_new_context = function(tbl, k)
  local new = vim.deepcopy(tbl)
  new.context = k

  return new
end

-- Standardize message format
state.run_log = function(opt)
  return {
      status = opt.status,
      error_message = opt.error_message,
      context = opt.context,
      args = opt.args,
      assert = opt.assert,
      phase = opt.phase
    }
end

state.success_run = function(opt)
  return {
    status = state.status_codes.success,
    context = opt.context,
    args = opt.args,
    assert = opt.assert,
    phase = opt.phase
  }
end

state.failed_run = function(opt)
  return {
    status = state.status_codes.fail,
    error_message = opt.error_message,
    context = opt.context,
    args = opt.args,
    assert = opt.assert,
    phase = opt.phase
  }
end

state.error_run = function(opt)
  return {
    status = state.status_codes.error,
    error_message = opt.error_message,
    context = opt.context,
    args = opt.args,
    assert = opt.assert,
    phase = opt.phase
  }
end

state.run_failed = function(run)
  return run.status ~= nil and run.status > state.status_codes.success
end

state.statemaker = function(case, initial_state)

  local test_state = vim.tbl_extend("keep", case,
    {
    run = {},
    result = {},
    phase = "init",


    -- Supplied to the test
    assert = {},
    state = initial_state,
  })

  for key, fn in pairs(vim.tbl_extend("keep", default_assert, assert.custom_asserts)) do
    test_state.assert[key] = setmetatable({
        fn = key,
        context = nil
    },{
      __index = state.with_new_context,
      __call = function(tbl, ...)
    local result, errmsg = fn(...)
    local context = rawget(tbl, "context")
    if context == nil then
      context = key
    end
    local run = state.run_log{
      status = result and state.status_codes.success or state.status_codes.fail,
      error_message = errmsg,
      context = context,
      args = {...},
      assert = key,
      phase = test_state.phase
    }
    table.insert(test_state.run, run)

    if not result then
      -- Abort the execution from this point onwards
      test_state.result = run
      error(full_error_msg, 0)
    end
  end
    })
  end

  return test_state
end

return state
