# Runes.nvim

Lua test framework for neovim plugins

[![Sponsor me](https://img.shields.io/github/sponsors/hkupty?style=flat-square)](https://github.com/sponsors/hkupty)

---

`runes.nvim` is a test framework for neovim, in lua. It is designed to test lua plugins.

## How to use it

On a lua file, write your tests like this:

```lua
local runes = require("runes")
local my_plugin = require("my.plugin")

runes.run_spec(runes.spec{
  -- [[ Test configuration ]] --
  -- Specs have descriptions to better inform the results
  -- It is not a "fluent", descriptive DSL,
  -- but it emulated on top of this dsl.
  description = "Ensure my plugin does the right thing",

  -- `spec_setup` runs once before any test and sets up the initial state for the tests
  spec_setup = function() return { my_base_number = 1337, my_base_string = "str" },

  -- Config is a special key that can tweak the behavior of the tests
  -- Below are the default values:
  config = {
    -- By default, the state set in `spec_setup` is immutable and every test case
    -- will get a copy of it.
    -- If one requires a shared state that is mutated across every test,
    -- then set this value to false.
    immutable_state = true,

    -- Collect is the function that works on the test results.
    -- By default, it renders the result as text to neovim's `messages`
    collect = require("runes.spec.render").to_messages,

    -- Skip rules. The current rules are:
    -- - tests with a description that starts with `_`
    -- - tests that have a `skip` label
    -- If, for any reason, one wants to change (or extend) that,
    -- it can be tweaked here.
    skip_tests = require("runes.spec.skip").apply_all_rules
  }

  -- [[ Test cases ]] --
  -- A test can be defined by a single function
  function()
    -- assert is automatically added to the function's environment
    assert.eq(1, 1)

    -- When state is a table, they key-value pairs are
    -- added to the function environment as well
    assert.eq(my_base_number, 1337)

    -- finally, the `state` table is also added
    -- to the function environment
    assert.eq(state.my_base_string, "str")
  end,

  runes.test{"my test",
  test = function()
    -- Adding contexts allow you to have a better understanding on which assertion failed
    assert.eq["checking that my_base_string is correctly set "]("str", state.my_base_string)
  end},

  runes.test{"`my.plugin.add` adds correctly",
    -- assert and state are also supplied as function arguments
    -- this can be useful if you have an `assert` or `state` object outside
    -- your function and you want to refer to it.
    -- The test environment never overrides what is already defined in
    -- global environment.
    test = function(check, state)
      check.eq['Adding one should work correctly'](my_plugin.add(state.my_base_number, 1), 1338)
    end},

  runes.test{"`my.plugin.mod` returns the right remaining/modulo",
    -- Labels allow special behavior to happen to tests
    -- Currently, the only label being intercepted is the `skip` label
    -- In the future, more labels can added
    -- Other use might be to group tests based on the label for displaying
    labels = {"skip"},
    test = function(assert, state)
      assert.odd['Modulo should be 1'](my_plugin.mod(state.my_base_number, 2))
    end},

  runes.test{"`my.plugin.awesome` does some great computation correctly",
    labels = {"skip"},
    -- Tests can have their own setup function as well
    -- This is just to better separate preparing and checking
    -- If this step errors, the test won't be executed
    setup = function(state)
      state.base_for_computation = math.random(state.my_base_number)
      return state
    end,
    test = function(assert, state)
      local result = my_plugin.awesome(state.base_for_computation)
      assert.not_nil['awesome should return a non-nil value'](result)
      assert.is_table['awesome should return a valid table'](result)
    end},

  -- A quick way to skip tests is also to prefix the test description with
  -- an underscore. It might be helpful during debugging
  runes.test{"_ this test is skipped as well because it starts with an `_`",
    test = function(assert)
      if (math.random(100) % 31 == 0) then
        assert.fail['this is a flay test']()
      end
    end}
})
```

This file then can be either called with `luafile %`/`luafile path/to/file.lua` or required by another lua file.


## Roadmap

The list below is not complete, but just a rough idea. For a comprehensive list, refer to [the Alpha to 1.0 project](https://github.com/hkupty/runes.nvim/projects/1).
The features below might be discarded/added based on [discussions](https://github.com/hkupty/runes.nvim/discussions).

- [ ] Reports
  - [ ] Reporting to file
  - [ ] Reporting to buffer
- [ ] Running
  - [ ] Running multiple specs in a single run
  - [ ] Running from a command (maybe not needed?)
  - [ ] Closing neovim at the end of a run
    - [ ] `:q` for success
    - [ ] `:cq` for failure
- [ ] Debug
  - [ ] Storing `file` and `line` information about failed tests
  - [ ] capturing more data (like test env?) for better debug
- [ ] Asserts
  - [ ] Table membership asserts
    - [ ] `has_key(key)`
    - [ ] `has_item(value)`
    - [ ] `has_size(size)`
    - [ ] `is_subset_of/has_items_in_any_order(smaller, bigger)`
    - [ ] `has_items_in_order(smaller, bigger)`
    - [ ] more?
  - [ ] Neovim asserts
    - [ ] `window_exists(window_id)`
    - [ ] `buffer_exists(buffer_id)`
    - [ ] `buffer_has_lines(buffer_id, lines)`
    - [ ] more?
- [ ] Spies/Mocks
- [ ] Randomized order
- [ ] Parallel tests

## Why?

I created this plugin to be able to properly test [iron.nvim](https://github.com/hkupty/iron.nvim).
Using [busted](http://olivinelabs.com/busted/) is good but I felt I wasn't really testing it because I was mocking away `vim.*`.
Instead of bringing `vim.*` to busted, I decided to write a test framework that embraces it.

## Thanks

Runes is inspired by [vader.vim](https://github.com/junegunn/vader.vim/), which does a great job at testing viml.
