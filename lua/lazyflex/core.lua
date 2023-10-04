local M = {}

M.match = function(name, keywords, enable_on_match)
  name = string.lower(name)
  for _, keyword in ipairs(keywords) do
    if name:find(keyword, 1, true) then
      return enable_on_match
    end
  end
  return not enable_on_match
end

return M
