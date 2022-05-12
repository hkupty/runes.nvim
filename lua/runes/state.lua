local default_assert = require("runes.default_asserts")
local assert = require("runes.asserts")

local state = {}

state.with_new_context = function(tbl, k)
  local new = vim.deepcopy(tbl)
  new.context = k

  return new
end

state.statemaker = function(case, initial_state)
  local test_state = vim.tbl_extend("keep", case,
    {
    run = {},
    result = {success = true},
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
    local run = {
      success = result,
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
