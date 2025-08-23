
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("test", {
    t("function "), i(1, "name"), t("()"),
    t({ "", "  " }), i(2),
    t({ "", "end" }),
  }),
}

