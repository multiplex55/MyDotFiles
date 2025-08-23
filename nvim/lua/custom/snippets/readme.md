# 🧠 Custom LuaSnip Snippets

This folder contains filetype-specific LuaSnip snippet definitions for Neovim.

---

## 🔧 File Structure

Each file should be named after a filetype. For example:

- `lua.lua` → applies to Lua files
- `rust.lua` → applies to Rust files
- `markdown.lua` → applies to Markdown
- `nim.lua` → applies to Nim

---

## ✨ How to Define a Snippet

```lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("trig", {
    t("Hello, "), i(1, "World"), t("!"),
  }),
}

```

📌 Breakdown:

* s("trig", ...): "trig" is the trigger keyword (you type this to expand the snippet).
* t(...): Inserts plain text.
* i(n, default): Insert node where you can type. n is the order of focus when jumping with <Tab>.

🔁 Optional Nodes
🧱 c(n, choices)


```lua
c(1, {
  t("option1"),
  t("option2"),
})

```

🔄 d(n, dynamic_fn)

Dynamic nodes generate content based on earlier input.

➕ Adding More Snippets

You can return a list of multiple snippets:

```lua
return {
  s("fn", {
    t("function "), i(1, "name"), t("()"), t({ "", "  " }), i(2), t({ "", "end" }),
  }),

  s("req", {
    t("local "), i(1, "mod"), t(" = require('"), i(2, "mod"), t("')"),
  }),

```lua
