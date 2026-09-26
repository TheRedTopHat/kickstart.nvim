-- lua/snippets/toml_nl2sql.lua
-- Authoring snippets for the NL2SQL eval dataset TOML.
local ls = require 'luasnip'
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local k = require('luasnip.nodes.key_indexer').new_key

-- Adjust to your exact level taxonomy; keys must match the choice strings.
local level_prefix = {
  single_table = 'l1_',
  multi_hop = 'l2_',
  aggregation = 'l3_',
  cv_lookup = 'l4_',
  derived_temporal = 'l5_',
  ambiguous = 'l6_',
}

local level_choices = {
  t 'single_table',
  t 'multi_hop',
  t 'aggregation',
  t 'cv_lookup',
  t 'derived_temporal',
  t 'ambiguous',
  i(nil, ''), -- free entry; id prefix will be empty
}

-- data_values: lookup/descendants suffix combinations (function: fresh nodes)
local function combo()
  return {
    t '',
    t ', lookup = true',
    t ', descendants = true',
    t ', lookup = true, descendants = true',
  }
end

-- Generic count-driven list. Each item sits in a restoreNode keyed per item,
-- so typed text and chosen choices survive every re-render. n comes from the
-- external count field; each item line ends with a TOML-legal trailing comma.
local function list_of(key_base, item, default_n)
  return function(args)
    local n = tonumber(args and args[1] and args[1][1]) or default_n
    if n < 0 then
      n = 0
    end
    local nodes = {}
    for j = 1, n do
      nodes[#nodes + 1] = t { '', '  ' }
      nodes[#nodes + 1] = r(j, key_base .. j, item(j))
      nodes[#nodes + 1] = t ','
    end
    return sn(nil, nodes)
  end
end

local variants_item = function()
  return { t '"', i(1), t '"' }
end
local columns_item = function()
  return { t '"', i(1), t '"' }
end
local joins_item = function()
  return { t '["', i(1), t '", "', i(2), t '"]' }
end
local data_value_item = function()
  return {
    t '{ phrase = "',
    i(1),
    t '", stored = "',
    i(2),
    t '"',
    c(3, combo()),
    t ' }',
  }
end

local queries = {
  s({ trig = 'tq', dscr = 'NL2SQL eval: full [[queries]] record' }, {
    t { '[[queries]]', 'id = "' },
    f(function(args) -- id prefix follows the level choice (read-only)
      local lv = args[1] and args[1][1] or ''
      return level_prefix[lv] or ''
    end, { k 'lvl' }),
    i(2), -- numeric part of the id
    t { '",', 'level = "' },
    c(1, level_choices, { key = 'lvl' }),
    t { '",', 'usage = "' },
    c(3, { t 'test', t 'dev' }),
    t { '",', 'question = "' },
    i(4),
    t { '",', 'variants = [' },
    d(5, list_of('var', variants_item, 2), { k 'cnt_var' }),
    t { '', '] # n=' },
    i(6, '2', { key = 'cnt_var' }),
    t { '', 'name_match = "' },
    c(7, { t 'some', t 'all', t 'none' }),
    t { '",', 'data_values = [' },
    d(8, list_of('dv', data_value_item, 1), { k 'cnt_dv' }),
    t { '', '] # n=' },
    i(9, '1', { key = 'cnt_dv' }),
    t { '', '' },
    c(10, { t '', t { 'anti_join = true', '' } }),
    c(11, { t '', t { 'fanout_hazard = true', '' } }),
    c(12, { t '', t { 'distractor = true', '' } }),
    t 'gold_columns = [',
    d(13, list_of('col', columns_item, 3), { k 'cnt_col' }),
    t { '', '] # n=' },
    i(14, '3', { key = 'cnt_col' }),
    t { '', 'gold_joins = [' },
    d(15, list_of('join', joins_item, 1), { k 'cnt_join' }),
    t { '', '] # n=' },
    i(16, '1', { key = 'cnt_join' }),
    t { '', 'gold_sql = """' },
    i(17, { 'SELECT', 'FROM' }),
    t { '', '"""', 'expected_result = { row_count = ' },
    i(18, '0'),
    t ' }',
    t { '', 'provenance = "' },
    c(19, { i(nil, 'authored'), i(nil, 'generated') }),
    t { '",', 'status = "' },
    c(20, { t 'draft', t 'reviewed' }),
    t { '",', 'notes = "' },
    i(21),
    t { '",', '' },
  }),
}

-- Patch snippets: append one line to an already-finalized record.
-- Expand at the end of the previous line inside the array.
local lines = {
  s({ trig = 'var', dscr = 'variants entry line' }, { t { '', '  "' }, i(1), t '",' }),
  s({ trig = 'dv', dscr = 'data_values entry line' }, { t { '', '  { phrase = "' }, i(1), t '", stored = "', i(2), t '"', c(3, combo()), t ' },' }),
  s({ trig = 'gcol', dscr = 'gold_columns entry line' }, { t { '', '  "' }, i(1), t '",' }),
  s({ trig = 'gjoin', dscr = 'gold_joins entry line' }, { t { '', '  ["' }, i(1), t '", "', i(2), t '"],' }),
}

return vim.list_extend(queries, lines)
