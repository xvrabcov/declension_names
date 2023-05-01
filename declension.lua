local function compute_similarity(a, b)
    if a == b then
        return 1
    else
        sim = 0
        weight = 1 / 2
        ar = string.lower(string.reverse(a))
        br = string.lower(string.reverse(b))
        for i = 1,math.min(string.len(a), string.len(b)),1 
        do 
            if string.sub(ar, i, i) == string.sub(br, i, i) then
                sim = sim + weight
            end
            weight = weight / 2
        end
        return sim
    end
end

local function add_name(name_list, name, group)
    group = group
    if next(name_list) == nil or #name_list < group then
        name_list[group] = {}
    end
    table.insert(name_list[group], name)
    return name_list
end

local function add_rule(rule_list, rule)
    table.insert(rule_list, rule)
    return rule_list
end

local function find_rule(rule_list, name_list, name)
    group = 1
    index = 1
    similarity = 0
    for k, v in pairs(name_list)
    do
        for i=1,#v,1
        do
            cur_sim = compute_similarity(name, v[i])
            if cur_sim > similarity then
                group = k
                index = i
                similarity = cur_sim
            end
        end
    end
    return rule_list[group]
end

local function decline(rule, name, case, number)
    suffix = case
    if number == "p" then suffix = suffix + 7 end
    local suf = {}
    for x in rule:gmatch("([^,]+)")
	do
        if x == "_" then x = "" end
	    suf[#suf + 1] = x
    end
    local base = name

    if #suf == 14 then
        if #suf ~= 0 and name:sub(-#suf[1]) == suf[1] then
            base = name:sub(1, #name-#suf[1])
        end
        return base .. suf[suffix]
    end
    return name
end

--- model functions

local DeclensionModel = {}

function DeclensionModel.new()
    local model = {}
    model.name_list = {}
    model.rule_list = {}
    local mt = {
    __index = DeclensionModel }
    setmetatable(model, mt)
    return model
end

function DeclensionModel.add_name(model, name, group)
    add_name(model.name_list, name, group)
end

function DeclensionModel.add_rule(model, rule)
    add_rule(model.rule_list, rule)
end

function DeclensionModel.load_data(model, rule_filename, name_filename)
    local rule_file = io.open(rule_filename, "r")
    assert(rule_file)
    for r in rule_file:lines() do
        if #r:match("^%s*(.-)%s*$") == 0 then goto continue end
        model:add_rule(r)
	  ::continue::
    end
    local name_file = io.open(name_filename, "r")
    assert(name_file)
    for n in name_file:lines() do
        if #n:match("^%s*(.-)%s*$") == 0 then goto continue end
	    local vals = {}
        for x in n:gmatch("([^,]+)")
	    do
	      vals[#vals + 1] = x
        end
        if #vals >= 2 then
            model:add_name(vals[1], tonumber(vals[2]))
        end
        ::continue::
    end
end

function DeclensionModel.find_rule(model, name)
    return find_rule(model.rule_list, model.name_list, name)
end

function DeclensionModel.decline(model, name, case, number)
    return decline(model:find_rule(name), name, case, number)
end

--- facade

local declnames = {}
local models = {}

function declnames.new_model(name)
  assert(models[name] == nil, [[Model named "]] .. name .. [[" already exists]])
  local model = DeclensionModel.new()
  models[name] = model
end

local function get_model(model_name)
  local model
  model = models[model_name]
  assert(model ~= nil, [[Model named "]] .. model_name .. [[" does not exist]])
  return model
end

function declnames.load_data(model_name, rule_filename, name_filename)
  local model = get_model(model_name)
  model:load_data(rule_filename, name_filename)
end

function declnames.decline(model_name, name, case, number)
  local model = get_model(model_name)
  local result = model:decline(name, case, number)
  return result
end

return declnames