# MCP Tool Call Flow Implementation

## Overview
Implemented proper MCP tool call handling with correct API message sequencing and automatic follow-up responses.

## Architecture

### 1. Tool Call Storage (`ChatTool.swift`)
- Added convenience initializer for creating `ChatTool` from API tool call info
- Structure stores: `toolCallId`, `toolName`, `args`, and `result`

### 2. Message Conversion (`Message.swift`)
- **Changed**: `toChatRequestMessage()` now returns `[ChatRequestMessage]` instead of single message
- **Why**: OpenAI API requires separate messages for tool calls and tool results

#### Message Sequencing:
For assistant messages **with tools**:
1. Assistant message with `tool_calls` array (contains the tool call info)
2. Tool result message(s) with `role: .tool` (one per tool with results)

For regular messages:
1. Single message (user or assistant)

### 3. Stream Processing (`StreamHandler.swift`)

#### Flow:
1. **Accumulate tool calls** from API response stream
2. **Store in assistant.tools** as `ChatTool` objects
3. **Execute tools** via `MCPToolAdapter.callToolHTTP()`
4. **Update results** in `ChatTool.result` field
5. **Trigger follow-up request** to get assistant's response based on tool results

#### Key Methods:

**`processStreamWithOpenAI()`**
- Streams initial response
- Accumulates tool calls
- Stores them in `assistant.tools`
- Calls `executeToolCalls()` if tools present

**`executeToolCalls()`**
- Executes each tool via MCP server
- Updates `assistant.tools[index].result` with results or errors
- Handles errors gracefully per tool

**`getToolResponseFromAssistant()`**
- Makes follow-up API request
- Includes tool calls AND results in message history
- Streams assistant's response based on tool execution
- No tools in follow-up request (prevents infinite loops)

## API Message Flow

### Example Conversation:
```
User: "What's the weather in SF?"

1. User Message
   role: user
   content: "What's the weather in SF?"

2. Assistant Message (with tool call)
   role: assistant
   content: ""
   tool_calls: [{
     id: "call_123",
     type: "function",
     function: {
       name: "get_weather",
       arguments: '{"city": "San Francisco"}'
     }
   }]

3. Tool Result Message
   role: tool
   tool_call_id: "call_123"
   content: '{"temperature": 68, "conditions": "sunny"}'

4. Assistant Response (follow-up)
   role: assistant
   content: "The weather in San Francisco is 68°F and sunny!"
```

## Benefits

✅ **Semantically Correct**: API receives properly formatted message sequences
✅ **No Duplication**: Tool info not duplicated in text content
✅ **Automatic Follow-up**: Assistant automatically responds to tool results
✅ **Error Handling**: Graceful per-tool error handling
✅ **Clean Separation**: Tool calls and results properly separated in message structure

## Local Storage

In our local `Message` instances:
- `assistant.tools` contains array of `ChatTool` objects
- Each `ChatTool` has both the call info AND result
- Single message object contains both semantically

When converting to API format:
- Split into multiple `ChatRequestMessage` objects
- Maintains correct API contract
