# Claude API -- Rust

> **Note:** There is no official Anthropic SDK for Rust. These patterns use `reqwest` + `serde` against the REST API directly. For tool-use concepts and prompt caching design, see `shared/tool-use-concepts.md` and `shared/prompt-caching.md`.

## Setup

```toml
# Cargo.toml
[dependencies]
reqwest = { version = "0.12", features = ["json", "stream"] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"
tokio = { version = "1", features = ["full"] }
anyhow = "1"
futures-util = "0.3"   # for streaming
```

---

## Types

Define request/response types with serde. Skip fields you don't need with `#[serde(skip_serializing_if)]`.

```rust
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize)]
struct MessageRequest {
    model: String,
    max_tokens: u32,
    messages: Vec<Message>,
    #[serde(skip_serializing_if = "Option::is_none")]
    system: Option<serde_json::Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    tools: Option<Vec<Tool>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    stream: Option<bool>,
    #[serde(skip_serializing_if = "Option::is_none")]
    thinking: Option<ThinkingConfig>,
    #[serde(skip_serializing_if = "Option::is_none")]
    output_config: Option<OutputConfig>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct Message {
    role: String,
    content: serde_json::Value, // string or array of content blocks
}

#[derive(Debug, Deserialize)]
struct MessageResponse {
    content: Vec<ContentBlock>,
    stop_reason: Option<String>,
    usage: Usage,
}

#[derive(Debug, Deserialize)]
#[serde(tag = "type")]
enum ContentBlock {
    #[serde(rename = "text")]
    Text { text: String },
    #[serde(rename = "thinking")]
    Thinking { thinking: String },
    #[serde(rename = "tool_use")]
    ToolUse {
        id: String,
        name: String,
        input: serde_json::Value,
    },
}

#[derive(Debug, Deserialize)]
struct Usage {
    input_tokens: u32,
    output_tokens: u32,
    #[serde(default)]
    cache_read_input_tokens: u32,
    #[serde(default)]
    cache_creation_input_tokens: u32,
}

#[derive(Debug, Serialize)]
struct Tool {
    name: String,
    description: String,
    input_schema: serde_json::Value,
}

#[derive(Debug, Serialize)]
struct ThinkingConfig {
    r#type: String,
}

#[derive(Debug, Serialize)]
struct OutputConfig {
    #[serde(skip_serializing_if = "Option::is_none")]
    effort: Option<String>,
}
```

---

## Client

```rust
use anyhow::{Context, Result};
use reqwest::header::{HeaderMap, HeaderValue};

struct Claude {
    client: reqwest::Client,
}

impl Claude {
    fn new() -> Result<Self> {
        let api_key = std::env::var("ANTHROPIC_API_KEY")
            .context("ANTHROPIC_API_KEY not set")?;

        let mut headers = HeaderMap::new();
        headers.insert("x-api-key", HeaderValue::from_str(&api_key)?);
        headers.insert("anthropic-version", HeaderValue::from_static("2023-06-01"));

        let client = reqwest::Client::builder()
            .default_headers(headers)
            .build()?;

        Ok(Self { client })
    }

    async fn message(&self, request: &MessageRequest) -> Result<MessageResponse> {
        let resp = self
            .client
            .post("https://api.anthropic.com/v1/messages")
            .json(request)
            .send()
            .await?;

        let status = resp.status();
        if !status.is_success() {
            let body = resp.text().await?;
            anyhow::bail!("API error {status}: {body}");
        }

        resp.json().await.context("failed to parse response")
    }
}
```

---

## Basic Message Request

```rust
#[tokio::main]
async fn main() -> Result<()> {
    let claude = Claude::new()?;

    let request = MessageRequest {
        model: "claude-opus-4-6".into(),
        max_tokens: 16_000,
        messages: vec![Message {
            role: "user".into(),
            content: serde_json::json!("What is the capital of France?"),
        }],
        system: None,
        tools: None,
        stream: None,
        thinking: None,
        output_config: None,
    };

    let resp = claude.message(&request).await?;

    for block in &resp.content {
        if let ContentBlock::Text { text } = block {
            println!("{text}");
        }
    }

    Ok(())
}
```

---

## Streaming (SSE)

The API returns Server-Sent Events when `stream: true`. Parse the event stream with `reqwest`'s byte stream.

```rust
use futures_util::StreamExt;

impl Claude {
    async fn stream(&self, request: &MessageRequest) -> Result<()> {
        let resp = self
            .client
            .post("https://api.anthropic.com/v1/messages")
            .json(request)
            .send()
            .await?;

        let status = resp.status();
        if !status.is_success() {
            let body = resp.text().await?;
            anyhow::bail!("API error {status}: {body}");
        }

        let mut stream = resp.bytes_stream();
        let mut buffer = String::new();

        while let Some(chunk) = stream.next().await {
            let chunk = chunk?;
            buffer.push_str(&String::from_utf8_lossy(&chunk));

            // Process complete SSE events (double newline delimited)
            while let Some(pos) = buffer.find("\n\n") {
                let event = buffer[..pos].to_string();
                buffer = buffer[pos + 2..].to_string();

                if let Some(data) = event.strip_prefix("data: ") {
                    if let Ok(parsed) = serde_json::from_str::<serde_json::Value>(data) {
                        if parsed["type"] == "content_block_delta" {
                            if let Some(text) = parsed["delta"]["text"].as_str() {
                                print!("{text}");
                            }
                        }
                    }
                }
            }
        }
        println!();

        Ok(())
    }
}
```

Usage:

```rust
let mut request = MessageRequest {
    model: "claude-opus-4-6".into(),
    max_tokens: 64_000,
    stream: Some(true),
    messages: vec![Message {
        role: "user".into(),
        content: serde_json::json!("Write a haiku"),
    }],
    ..Default::default() // if you derive Default
};

claude.stream(&request).await?;
```

---

## Tool Use (Manual Agentic Loop)

Define tools as JSON schemas, loop until `stop_reason != "tool_use"`.

```rust
async fn tool_loop(claude: &Claude) -> Result<()> {
    let tools = vec![Tool {
        name: "get_weather".into(),
        description: "Get current weather for a city".into(),
        input_schema: serde_json::json!({
            "type": "object",
            "properties": {
                "city": {"type": "string", "description": "City name"}
            },
            "required": ["city"]
        }),
    }];

    let mut messages = vec![Message {
        role: "user".into(),
        content: serde_json::json!("What's the weather in Paris?"),
    }];

    loop {
        let request = MessageRequest {
            model: "claude-opus-4-6".into(),
            max_tokens: 16_000,
            messages: messages.clone(),
            tools: Some(tools.clone()),
            system: None,
            stream: None,
            thinking: None,
            output_config: None,
        };

        let resp = claude.message(&request).await?;

        // Append assistant response preserving full content
        messages.push(Message {
            role: "assistant".into(),
            content: serde_json::to_value(&resp.content)?,
        });

        if resp.stop_reason.as_deref() != Some("tool_use") {
            // Print final text
            for block in &resp.content {
                if let ContentBlock::Text { text } = block {
                    println!("{text}");
                }
            }
            break;
        }

        // Execute tool calls and build results
        let tool_results: Vec<serde_json::Value> = resp
            .content
            .iter()
            .filter_map(|block| match block {
                ContentBlock::ToolUse { id, name, input } => {
                    let result = execute_tool(name, input);
                    Some(serde_json::json!({
                        "type": "tool_result",
                        "tool_use_id": id,
                        "content": result,
                    }))
                }
                _ => None,
            })
            .collect();

        messages.push(Message {
            role: "user".into(),
            content: serde_json::Value::Array(tool_results),
        });
    }

    Ok(())
}

fn execute_tool(name: &str, input: &serde_json::Value) -> String {
    match name {
        "get_weather" => {
            let city = input["city"].as_str().unwrap_or("unknown");
            format!("The weather in {city} is sunny, 72F")
        }
        _ => format!("Unknown tool: {name}"),
    }
}
```

---

## Thinking (Adaptive)

```rust
let request = MessageRequest {
    model: "claude-opus-4-6".into(),
    max_tokens: 16_000,
    thinking: Some(ThinkingConfig {
        r#type: "adaptive".into(),
    }),
    messages: vec![Message {
        role: "user".into(),
        content: serde_json::json!("How many r's in strawberry?"),
    }],
    ..Default::default()
};

let resp = claude.message(&request).await?;

for block in &resp.content {
    match block {
        ContentBlock::Thinking { thinking } => println!("[thinking] {thinking}"),
        ContentBlock::Text { text } => println!("{text}"),
        _ => {}
    }
}
```

Combine with effort:

```rust
let request = MessageRequest {
    model: "claude-opus-4-6".into(),
    max_tokens: 16_000,
    thinking: Some(ThinkingConfig { r#type: "adaptive".into() }),
    output_config: Some(OutputConfig { effort: Some("max".into()) }),
    // ...
};
```

---

## Prompt Caching

Place `cache_control` on the last block of your stable prefix. See `shared/prompt-caching.md` for placement patterns.

```rust
let request_body = serde_json::json!({
    "model": "claude-opus-4-6",
    "max_tokens": 16_000,
    "system": [{
        "type": "text",
        "text": large_system_prompt,
        "cache_control": {"type": "ephemeral"}
    }],
    "messages": [{"role": "user", "content": "Summarize the key points"}]
});

// Use raw JSON body instead of typed struct for cache_control fields
let resp = claude.client
    .post("https://api.anthropic.com/v1/messages")
    .json(&request_body)
    .send()
    .await?;
```

Verify cache hits:

```rust
println!("cache hits: {}", resp.usage.cache_read_input_tokens);
```

---

## Error Handling

Use `thiserror` for typed API errors:

```rust
use thiserror::Error;

#[derive(Debug, Error)]
enum ClaudeError {
    #[error("rate limited (retry after backoff)")]
    RateLimited { body: String },

    #[error("overloaded (status 529)")]
    Overloaded { body: String },

    #[error("API error {status}: {body}")]
    Api { status: u16, body: String },

    #[error(transparent)]
    Http(#[from] reqwest::Error),
}

impl Claude {
    async fn message_typed(&self, request: &MessageRequest) -> Result<MessageResponse, ClaudeError> {
        let resp = self
            .client
            .post("https://api.anthropic.com/v1/messages")
            .json(request)
            .send()
            .await?;

        let status = resp.status().as_u16();
        match status {
            200 => Ok(resp.json().await?),
            429 => Err(ClaudeError::RateLimited {
                body: resp.text().await.unwrap_or_default(),
            }),
            529 => Err(ClaudeError::Overloaded {
                body: resp.text().await.unwrap_or_default(),
            }),
            _ => Err(ClaudeError::Api {
                status,
                body: resp.text().await.unwrap_or_default(),
            }),
        }
    }
}
```

For retries, use `reqwest-retry` or `tower::retry`:

```rust
// With backoff crate
use backoff::ExponentialBackoff;

let result = backoff::future::retry(ExponentialBackoff::default(), || async {
    claude.message_typed(&request).await.map_err(|e| match e {
        ClaudeError::RateLimited { .. } | ClaudeError::Overloaded { .. } => {
            backoff::Error::transient(e)
        }
        other => backoff::Error::permanent(other),
    })
}).await?;
```
