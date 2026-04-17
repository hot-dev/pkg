# hot-ai

Dependency-free building blocks for AI agents in Hot. Multi-tenant sessions, typed messages, scoped memory, RAG, context management, and inter-agent communication — all without depending on any specific AI provider package.

Provider-specific code (Anthropic, OpenAI, xAI, Gemini) stays in the user's project; `hot-ai` calls it through a `chat-fn` parameter.

## Installation

Add this to the `deps` in your `hot.hot` file:

```hot
"hot.dev/hot-ai": "1.2.0"
```

## Namespaces

### `::ai::session` — Multi-tenant primitives

Lightweight handle types for organizing agents across platforms.

```hot
::session ::ai::session

chat  ::session/Session({id: "telegram:12345"})
alice ::session/Identity({id: "u1", name: "alice"})

// Scoped keys for store names
::session/session-key("brain", chat, "memory")   // "brain:session:telegram:12345:memory"
::session/user-key("brain", alice, "profile")    // "brain:user:u1:profile"
::session/agent-key("brain", "kb")               // "brain:agent:kb"
```

### `::ai::message` — Normalized message types

- `Role` enum (`User`, `Assistant`, `System`)
- `ChatMessage` — role + content for AI API calls
- `Message` — inbound user messages with `sender`, `session`, `source`
- `AgentMessage` — inter-agent envelopes

```hot
::msg ::ai::message

msg ::msg/user-msg("Hello!")                       // ChatMessage
m   ::msg/Message({
  id: "42", content: "hi team",
  sender: alice, session: chat,
  timestamp: 1700000000, source: "telegram",
})
```

### `::ai::chat` — Provider-agnostic dispatch

Detects the provider for any model name and bundles a caller-provided chat function.

```hot
::chat ::ai::chat

::chat/detect-provider("claude-sonnet-4-5")   // Provider.Anthropic
::chat/detect-provider("gpt-5.2")             // Provider.OpenAi
::chat/provider-name(Provider.Anthropic)      // "Anthropic"

opts ::chat/ChatOptions({
  chat-fn: ::anthropic::messages/chat,   // YOUR provider's chat function
  model:   "claude-sonnet-4-5",
  system:  "You are a helpful assistant.",
})
```

### `::ai::memory` — Three-level scoped memory

Session (shared conversation history), User (per-identity data), and KB (shared knowledge base). Plus per-user `Thread` for multi-turn conversations.

```hot
::mem ::ai::memory

mem ::mem/create-memory("brain", chat, alice)

// Session-level: remember a message, then recall semantically
::mem/remember(mem, message)
results ::mem/recall(mem, "what did we decide?", {limit: 10, min-score: 0.3})

// User-level: per-identity profile data
::mem/set-user-data(mem, "timezone", "America/New_York")
::mem/get-user-data(mem, "timezone")

// KB: shared, embedded knowledge
::mem/learn(mem, "onboarding", {content: "Welcome! Start with /help"})

// Per-user multi-turn thread
t ::mem/thread("brain", alice, {max-turns: 10})
::mem/thread-add(t, Role.User, "hello")
::mem/thread-add(t, Role.Assistant, "hi alice")
hist ::mem/thread-history(t, null)
```

### `::ai::rag` — Retrieve-Augment-Generate

Composes memory search with a caller-provided `chat-fn`.

```hot
::rag ::ai::rag

// Single-shot Q&A grounded in memory
result ::rag/ask(mem, "when did alice join?", opts, {limit: 10})
// => {answer: "...", sources: [...]}

// Multi-turn with thread history
result ::rag/ask-with-thread(mem, t, "and when did bob?", opts, {limit: 10})

// Summarize recent activity
summary ::rag/summarize(mem, opts, {hours: 24, instruction: "..."})
```

Pure helpers (testable without stores):
`format-session-results`, `format-kb-results`, `format-thread-lines`, `build-rag-prompt`

### `::ai::context` — Token budgets

```hot
::aictx ::ai::context

::aictx/estimate-tokens("hello world")
::aictx/sample(messages, {max-items: 300, strategy: "bookend"})
::aictx/fit(messages, {max-tokens: 8000})
::aictx/truncate("very long text", {max-chars: 2000})
```

### `::ai::bus` — Inter-agent communication

Typed event-bus patterns: targeted `tell`, `broadcast`, `collaborate`, `respond`.

```hot
::bus ::ai::bus

// Targeted delivery
::bus/tell(AgentMessage({
  session: chat, sender: alice,
  to-agent: "researcher", from-agent: "brain",
  content: "please research topic X", timestamp: 1700000000,
}))

// Collaboration request with async reply
::bus/collaborate(CollaborationRequest({
  session: chat, sender: alice,
  from-agent: "brain",
  question: "What's alice's last login?",
  reply-event: "brain:reply:42",
  correlation-id: "42",
}))
```

### `::ai::media` — Multi-modal media types

Unified types for AI-generated images, audio, and video (independent of provider).

## Testing

The package ships with 54 unit tests covering session, message, chat, memory (pure), RAG (pure), context, and bus type construction.

```bash
hot test --project pkg-test-hot-ai
```

Memory and RAG paths that touch persistent stores are exercised by running the demo agent (see `hot/src/telegram-agent`) rather than by unit tests.

## License

Hot Dev Software License Agreement
