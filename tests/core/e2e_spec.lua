local assert = require("luassert")

describe("my first test", function()
  local tests = {
    { name = "test" },
    { name = "test" },
  }
  for _, test in ipairs(tests) do
    it("does something", function()
      assert.equal(test.name, "test")
    end)
  end
end)
