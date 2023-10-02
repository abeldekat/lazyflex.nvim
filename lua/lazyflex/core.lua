local M = {}

M.cond = function(name, opts)
  name = string.lower(name)
  for _, keyword in ipairs(opts.keywords) do
    if name:find(keyword, 1, true) then
      return opts.enable_on_match
    end
  end
  return not opts.enable_on_match
end

return M
