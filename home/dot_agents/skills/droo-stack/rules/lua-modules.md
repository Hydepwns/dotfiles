---
title: Lua Module and Metatable Patterns
impact: HIGH
impactDescription: clean modules, proper OOP, type safety via annotations
tags: lua, modules, metatables, luals, annotations
---

# Lua Module and Metatable Patterns

## Module Pattern

Always use `local M = {}` with an explicit `return M`. Never assign to globals or return inline tables with functions defined elsewhere.

### Incorrect

```lua
-- Pollutes global namespace, no clear module boundary
Logger = {}

function Logger.info(msg)
    print("[INFO] " .. msg)
end

function Logger.error(msg)
    print("[ERROR] " .. msg)
end

-- No return -- consumers rely on the global
```

### Correct

```lua
local M = {}

---@param msg string
function M.info(msg)
    print("[INFO] " .. msg)
end

---@param msg string
function M.error(msg)
    print("[ERROR] " .. msg)
end

return M
```

## Metatable Inheritance

Use `__index` on the metatable for OOP. Always store the metatable reference so subclasses can extend it.

### Incorrect

```lua
-- Copies methods onto every instance -- wasteful and breaks polymorphism
function new_animal(name, sound)
    local self = {}
    self.name = name
    self.sound = sound
    self.speak = function()
        return self.name .. " says " .. self.sound
    end
    -- No way to extend, no shared method table
    return self
end

function new_dog(name)
    local self = new_animal(name, "woof")
    self.fetch = function(item)
        return self.name .. " fetches " .. item
    end
    -- speak() is a closure copy, not inherited
    return self
end
```

### Correct

```lua
---@class Animal
---@field name string
---@field sound string
local Animal = {}
Animal.__index = Animal

---@param name string
---@param sound string
---@return Animal
function Animal.new(name, sound)
    local self = setmetatable({}, Animal)
    self.name = name
    self.sound = sound
    return self
end

---@return string
function Animal:speak()
    return self.name .. " says " .. self.sound
end

---@class Dog : Animal
local Dog = setmetatable({}, { __index = Animal })
Dog.__index = Dog

---@param name string
---@return Dog
function Dog.new(name)
    local self = Animal.new(name, "woof")
    return setmetatable(self, Dog)
end

---@param item string
---@return string
function Dog:fetch(item)
    return self.name .. " fetches " .. item
end

return { Animal = Animal, Dog = Dog }
```

## LuaLS Annotations

Annotate all public APIs with `---@param`, `---@return`, and `---@class`. This enables IDE completion and catches type errors.

### Incorrect

```lua
local M = {}

-- No annotations -- IDE has no idea what types are expected
function M.connect(host, port, opts)
    opts = opts or {}
    local timeout = opts.timeout or 5000
    local retries = opts.retries or 3
    -- ...
    return { socket = sock, host = host, port = port }
end

function M.send(conn, data)
    -- What is conn? What is data? What does this return?
    return conn.socket:send(data)
end
```

### Correct

```lua
local M = {}

---@class ConnectOpts
---@field timeout? integer Timeout in milliseconds (default 5000)
---@field retries? integer Number of retry attempts (default 3)

---@class Connection
---@field socket userdata
---@field host string
---@field port integer

---@param host string
---@param port integer
---@param opts? ConnectOpts
---@return Connection
function M.connect(host, port, opts)
    opts = opts or {}
    local timeout = opts.timeout or 5000
    local retries = opts.retries or 3
    -- ...
    return { socket = sock, host = host, port = port }
end

---@param conn Connection
---@param data string
---@return integer bytes_sent
function M.send(conn, data)
    return conn.socket:send(data)
end

return M
```

## Colon Syntax for Method Calls

Use `:` for methods that operate on `self`. Use `.` for static/module-level functions. Mixing them up is a common source of nil-self bugs.

### Incorrect

```lua
---@class Buffer
local Buffer = {}
Buffer.__index = Buffer

function Buffer.new()
    return setmetatable({ lines = {} }, Buffer)
end

-- Defined with dot but uses self -- self will be nil when called with ':'
function Buffer.append(self, line)
    table.insert(self.lines, line)
end

-- Called with colon, which implicitly passes self
-- but another place calls it with dot and forgets self:
--   buf.append("hello")  --> self = "hello", line = nil
```

### Correct

```lua
---@class Buffer
---@field lines string[]
local Buffer = {}
Buffer.__index = Buffer

---@return Buffer
function Buffer.new()
    return setmetatable({ lines = {} }, Buffer)
end

-- Colon syntax: self is implicit, consistent with call site
---@param line string
function Buffer:append(line)
    table.insert(self.lines, line)
end

---@return string
function Buffer:to_string()
    return table.concat(self.lines, "\n")
end

return Buffer
```
