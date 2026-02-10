# slack

Slack API bindings for Hot.

## Installation

Add this to the `deps` in your `hot.hot` file:

```hot
"hot.dev/slack": "1.0.1"
```

## Configuration

The `slack.api.key` context variable is required. Set it to your Slack Bot User OAuth Token via the Hot app.

## Usage

### Send a Message

```hot
::slack ::slack::messaging

response slack/chat-post-message(slack/ChatPostMessageRequest({
  channel: "C01ABCDEF",
  text: "Hello from Hot!"
}))
```

### List Channels

```hot
::slack ::slack::channels

response slack/conversations-list(slack/ConversationsListRequest({}))
for-each(response.channels, (ch) {
  println(ch.name)
})
```

### Get User Info

```hot
::slack ::slack::users

response slack/users-info(slack/UsersInfoRequest({
  user: "U01ABCDEF"
}))
println(response.user.real_name)
```

### Upload a File

```hot
::slack ::slack::files

response slack/files-upload-v2(slack/FilesUploadV2Request({
  channel_id: "C01ABCDEF",
  filename: "report.txt",
  content: "File contents here"
}))
```

## API Base URL

`https://slack.com/api`

## Modules

| Module | Description |
|--------|-------------|
| `::slack::messaging` | Chat messages, reactions, pins, scheduled messages |
| `::slack::channels` | Conversations (channels, DMs, groups) |
| `::slack::users` | User info, lists, profiles |
| `::slack::files` | File uploads, listing, sharing, deletion |
| `::slack::apps` | Bot info and app management |
| `::slack::calls` | RTM connections |
| `::slack::misc` | Auth, team info, emoji, views, dialogs, OAuth |
| `::slack::api` | Low-level authenticated HTTP client |
| `::slack::core` | Shared configuration (BASE_URL) |

## Documentation

- [Slack API Documentation](https://api.slack.com/methods)
- [Hot Package Documentation](https://hot.dev/pkg/slack)

## License

Apache-2.0 - see [LICENSE](LICENSE)
