# Claude API -- Lua

> **Note:** There is no official Anthropic SDK for Lua. These patterns use `lua-cjson` for JSON and either `lua-resty-http` (OpenResty/nginx) or `socket.http` + `ssl.https` (LuaSocket) for HTTP. For tool-use concepts and prompt caching design, see `shared/tool-use-concepts.md` and `shared/prompt-caching.md`.

## Dependencies

**OpenResty (recommended for production):**
```
lua-resty-http    -- HTTP client
lua-cjson         -- JSON (bundled with OpenResty)
```

**Standard Lua (LuaSocket):**
```
luarocks install luasocket
luarocks install luasec        -- TLS support
luarocks install lua-cjson
```

---

## Client Module

```lua
---@class Claude
---@field api_key string
local Claude = {}
Claude.__index = Claude

local cjson = require("cjson")
local http = require("resty.http") -- or socket.http for LuaSocket

local API_URL = "https://api.anthropic.com/v1/messages"

---@param opts? { api_key?: string }
---@return Claude
function Claude.new(opts)
  opts = opts or {}
  local self = setmetatable({}, Claude)
  self.api_key = opts.api_key or os.getenv("ANTHROPIC_API_KEY")
  assert(self.api_key, "ANTHROPIC_API_KEY not set")
  return self
end

---@param body table
---@return table? response
---@return string? error
function Claude:request(body)
  local httpc = http.new()
  local res, err = httpc:request_uri(API_URL, {
    method = "POST",
    headers = {
      ["Content-Type"] = "application/json",
      ["x-api-key"] = self.api_key,
      ["anthropic-version"] = "2023-06-01",
    },
    body = cjson.encode(body),
  })

  if not res then
    return nil, "request failed: " .. tostring(err)
  end

  local decoded = cjson.decode(res.body)
  if res.status ~= 200 then
    return nil, string.format("API error %d: %s", res.status,
      decoded.error and decoded.error.message or res.body)
  end

  return decoded, nil
end

--- Extract text from a response.
---@param resp table
---@return string
function Claude.text(resp)
  local parts = {}
  for _, block in ipairs(resp.content) do
    if block.type == "text" then
      parts[#parts + 1] = block.text
    end
  end
  return table.concat(parts, "\n")
end

return Claude
```

---

## Basic Message Request

```lua
local Claude = require("claude")

local client = Claude.new()

local resp, err = client:request({
  model = "claude-opus-4-6",
  max_tokens = 16000,
  messages = {
    { role = "user", content = "What is the capital of France?" },
  },
})

if not resp then
  error(err)
end

print(Claude.text(resp))
```

---

## LuaSocket Alternative

For standard Lua without OpenResty, use `socket.http`:

```lua
local https = require("ssl.https")
local cjson = require("cjson")
local ltn12 = require("ltn12")

---@param body table
---@return table? response
---@return string? error
function Claude:request_socket(body)
  local json_body = cjson.encode(body)
  local response_chunks = {}

  local _, status = https.request({
    url = API_URL,
    method = "POST",
    headers = {
      ["Content-Type"] = "application/json",
      ["Content-Length"] = #json_body,
      ["x-api-key"] = self.api_key,
      ["anthropic-version"] = "2023-06-01",
    },
    source = ltn12.source.string(json_body),
    sink = ltn12.sink.table(response_chunks),
  })

  local response_body = table.concat(response_chunks)
  local decoded = cjson.decode(response_body)

  if status ~= 200 then
    return nil, string.format("API error %d: %s", status,
      decoded.error and decoded.error.message or response_body)
  end

  return decoded, nil
end
```

---

## Tool Use (Manual Agentic Loop)

Define tools as tables matching the JSON schema. Loop until `stop_reason ~= "tool_use"`.

```lua
local tools = {
  {
    name = "get_weather",
    description = "Get current weather for a city",
    input_schema = {
      type = "object",
      properties = {
        city = { type = "string", description = "City name" },
      },
      required = { "city" },
    },
  },
}

---@param name string
---@param input table
---@return string
local function execute_tool(name, input)
  if name == "get_weather" then
    return string.format("The weather in %s is sunny, 72F", input.city)
  end
  return "Unknown tool: " .. name
end

local function tool_loop(client, prompt)
  local messages = {
    { role = "user", content = prompt },
  }

  while true do
    local resp, err = client:request({
      model = "claude-opus-4-6",
      max_tokens = 16000,
      tools = tools,
      messages = messages,
    })

    if not resp then error(err) end

    -- Append assistant response preserving full content
    messages[#messages + 1] = {
      role = "assistant",
      content = resp.content,
    }

    if resp.stop_reason ~= "tool_use" then
      return resp
    end

    -- Execute tool calls
    local tool_results = {}
    for _, block in ipairs(resp.content) do
      if block.type == "tool_use" then
        local result = execute_tool(block.name, block.input)
        tool_results[#tool_results + 1] = {
          type = "tool_result",
          tool_use_id = block.id,
          content = result,
        }
      end
    end

    messages[#messages + 1] = {
      role = "user",
      content = tool_results,
    }
  end
end

-- Usage
local resp = tool_loop(client, "What's the weather in Paris?")
print(Claude.text(resp))
```

---

## Thinking (Adaptive)

```lua
local resp, err = client:request({
  model = "claude-opus-4-6",
  max_tokens = 16000,
  thinking = { type = "adaptive" },
  messages = {
    { role = "user", content = "How many r's in strawberry?" },
  },
})

if not resp then error(err) end

for _, block in ipairs(resp.content) do
  if block.type == "thinking" then
    print("[thinking] " .. block.thinking)
  elseif block.type == "text" then
    print(block.text)
  end
end
```

Combine with effort:

```lua
local resp, err = client:request({
  model = "claude-opus-4-6",
  max_tokens = 16000,
  thinking = { type = "adaptive" },
  output_config = { effort = "max" },
  messages = {
    { role = "user", content = "Complex reasoning task..." },
  },
})
```

---

## Prompt Caching

Place `cache_control` on the last block of your stable prefix. See `shared/prompt-caching.md` for placement patterns.

```lua
local resp, err = client:request({
  model = "claude-opus-4-6",
  max_tokens = 16000,
  system = {
    {
      type = "text",
      text = large_system_prompt,
      cache_control = { type = "ephemeral" },
    },
  },
  messages = {
    { role = "user", content = "Summarize the key points" },
  },
})

-- Verify cache hits
if resp then
  print("cache hits: " .. tostring(resp.usage.cache_read_input_tokens))
end
```

---

## Multi-turn Conversation

```lua
---@class Conversation
---@field messages table[]
---@field client Claude
---@field system? table
local Conversation = {}
Conversation.__index = Conversation

---@param client Claude
---@param system? string
---@return Conversation
function Conversation.new(client, system)
  local self = setmetatable({}, Conversation)
  self.client = client
  self.messages = {}
  self.system = system and {
    { type = "text", text = system },
  } or nil
  return self
end

---@param user_text string
---@return string text
function Conversation:say(user_text)
  self.messages[#self.messages + 1] = {
    role = "user",
    content = user_text,
  }

  local body = {
    model = "claude-opus-4-6",
    max_tokens = 16000,
    messages = self.messages,
  }
  if self.system then
    body.system = self.system
  end

  local resp, err = self.client:request(body)
  if not resp then error(err) end

  -- Preserve full content array for compaction compatibility
  self.messages[#self.messages + 1] = {
    role = "assistant",
    content = resp.content,
  }

  return Claude.text(resp)
end
```

---

## Error Handling

Check status codes and implement retries for transient errors. See `shared/error-codes.md` for the full list.

```lua
---@param body table
---@param max_retries? number
---@return table? response
---@return string? error
function Claude:request_with_retry(body, max_retries)
  max_retries = max_retries or 3

  for attempt = 1, max_retries do
    local resp, err = self:request(body)

    if resp then
      return resp, nil
    end

    -- Parse status from error string for retry logic
    local status = err and tonumber(err:match("API error (%d+)"))

    if status == 429 or status == 529 then
      -- Rate limited or overloaded: exponential backoff
      local delay = math.pow(2, attempt - 1)
      ngx.sleep(delay) -- or os.execute("sleep " .. delay) for LuaSocket
    else
      return nil, err
    end
  end

  return nil, "max retries exceeded"
end
```
