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
  description = "Ensure my plugin does the right thing",

  -- `spec_setup` runs once before any test and sets up the initial state for the tests
  spec_setup = function() return { my_base_number = 1337 },

  runes.test{"`my.plugin.add` adds correctly",
  test = function(assert, state)
    assert.eq['Adding one should work correctly'](my_plugin.add(state.my_base_number, 1), 1338)
  end},

  runes.test{"`my.plugin.mod` returns the right remaining/modulo",
  labels = {"skip"}, -- This test is wrong, so I want to skip it for now and fix later
  test = function(assert, state)
    assert.odd['Modulo should be 1'](my_plugin.mod(state.my_base_number, 2))
  end},

  runes.test{"`my.plugin.awsome` does some great computation correctly",
  labels = {"skip"}, -- This test is flaky, so I want to skip it for now
  setup = function(state)
    state.base_for_computation = math.random(state.my_base_number)
    return state
  end,
  test = function(assert, state)
    local result = my_plugin.awesome(state.base_for_computation)
    assert.not_nil['awesome should return a non-nil value'](result)
    assert.is_table['awesome should return a valid table'](result)
  end},


  runes.test{"_ this test is skipped as well because it starts with an `_`",
    test = function(assert)
      if (math.random(100) % 31 == 0) then
        assert.fail['this is a flay test']()
      end
    end}
})
```

## Why?

I create this plugin to be able to properly test [iron.nvim](https://github.com/hkupty/iron.nvim).
Using [busted](http://olivinelabs.com/busted/) is good but I felt I wasn't really testing it because I was mocking away `vim.*`.
Instead of bringing `vim.*` to busted, I decided to write a test framework that embraces it.

## Thanks

Runes is inspired by [vader.vim](https://github.com/junegunn/vader.vim/), which does a great job at testing viml.
