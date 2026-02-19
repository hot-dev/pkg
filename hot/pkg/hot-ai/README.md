# hot-ai

AI types and utilities for Hot. Provides unified types for AI-generated content, independent of specific AI providers.

## Installation

Add this to the `deps` in your `hot.hot` file:

```hot
"hot.dev/hot-ai": "1.0.1"
```

## Namespaces

- `::ai::media` - AI-generated media types (images, audio, video)

## Usage

```hot
import ::hot::media
import ::ai::media

// Create AI-generated image
ai-image AIImage({
    media: Image({file: file-meta, width: 1024, height: 1024, format: "png"}),
    provider: "openai",
    model: "dall-e-3",
    prompt: "A sunset over mountains",
    style: "vivid",
    quality: "hd"
})

// Pattern match on AI media type
describe-ai-media fn (ai: AIMedia): Str {
    match ai {
        AIMedia.Image => { `AI Image: ${ai.prompt} via ${ai.provider}` }
        AIMedia.Audio => { `AI Audio: ${ai.voice} voice via ${ai.provider}` }
        AIMedia.Video => { `AI Video: ${ai.prompt} via ${ai.provider}` }
    }
}

// Access underlying pure media
pure-image ai-image.media
file-path ai-image.media.file.path
```

## License

Hot Dev Software License Agreement
