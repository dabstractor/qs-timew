# API Reference

Complete reference documentation for all public APIs in the qs-timew module.

## Table of Contents

- [Module Overview](#module-overview)
- [TimewarriorService](#timewarriorservice)
- [TimewarriorWidget](#timewarriorwidget)
- [IntegrationComponent](#integrationcomponent)
- [Type Definitions](#type-definitions)
- [Signals and Events](#signals-and-events)
- [Error Handling](#error-handling)
- [Usage Patterns](#usage-patterns)

## Module Overview

### Module Information

- **Module Name**: `qs_timew`
- **Version**: `2.0`
- **Import Statement**: `import qs_timew 2.0`

### Available Components

```qml
import qs_timew 2.0

// Core service singleton
TimewarriorService

// UI widget
TimewarriorWidget

// High-level integration API
IntegrationComponent
```

## TimewarriorService

The core singleton service that manages all timewarrior operations and state.

### Properties

#### Timer State Properties

| Property | Type | Read-Only | Description |
|----------|------|-----------|-------------|
| `timerActive` | `bool` | Yes | `true` if a timer is currently running |
| `currentTags` | `array<string>` | Yes | Tags of the currently active timer |
| `elapsedSeconds` | `int` | Yes | Seconds elapsed since timer started |
| `startTime` | `string` | Yes | ISO 8601 start time of current timer |
| `currentTimerId` | `string` | Yes | Unique identifier for current timer |
| `lastUsedTags` | `array<string>` | No | Tags from the most recently stopped timer |
| `weekTags` | `array<string>` | Yes | Unique tags used in the current week |

#### System Properties

| Property | Type | Read-Only | Description |
|----------|------|-----------|-------------|
| `timewAvailable` | `bool` | Yes | `true` if timewarrior binary is available |
| `errorMessage` | `string` | Yes | Current error message, empty if no error |
| `tagHistory` | `array<string>` | No | History of used tags for autocomplete |

### Methods

#### Timer Management

##### `startTimer(tags)`

Starts a new timewarrior timer with the specified tags.

```qml
// Basic usage
TimewarriorService.startTimer(["work", "project"])

// With validation
const validation = TimewarriorService.validateTags("work project urgent")
if (validation.isValid) {
    TimewarriorService.startTimer(validation.tags)
}
```

**Parameters:**
- `tags` (`array<string>`): Array of tag strings to associate with the timer

**Returns:** `void`

**Side Effects:**
- Starts timewarrior timer process
- Updates `timerActive` to `true`
- Populates `currentTags` and `startTime`
- Clears `errorMessage`

**Errors:**
- Console warning if tags array is empty
- Sets `errorMessage` if timewarrior command fails

##### `stopTimer()`

Stops the currently active timer.

```qml
if (TimewarriorService.timerActive) {
    TimewarriorService.stopTimer()
}
```

**Parameters:** None

**Returns:** `void`

**Side Effects:**
- Stops timewarrior timer process
- Updates `timerActive` to `false`
- Moves current tags to `lastUsedTags`
- Clears timer state properties

**Errors:**
- Console info if no active timer
- Sets `errorMessage` if timewarrior command fails

##### `refreshState()`

Manually refreshes the timer state from timewarrior.

```qml
// Refresh after external changes
TimewarriorService.refreshState()
```

**Parameters:** None

**Returns:** `void`

**Side Effects:**
- Executes `timew export` command
- Updates all timer state properties
- Triggers state polling cycle

#### Tag Management

##### `modifyTimerTags(timerId, newTags)`

Modifies tags on an active timer while preserving timer state.

```qml
const timerId = TimewarriorService.getCurrentTimerId()
const newTags = ["work", "project", "urgent"]
TimewarriorService.modifyTimerTags(timerId, newTags)
```

**Parameters:**
- `timerId` (`string`): ID of the timer to modify
- `newTags` (`array<string>`): New tags to apply to the timer

**Returns:** `bool` - `true` if modification initiated successfully

**Side Effects:**
- Executes `timew retag` command
- Emits `tagsUpdated` signal on success
- Emits `tagUpdateFailed` signal on error
- Updates `tagHistory` with new tags

**Errors:**
- Returns `false` and emits error if no active timer
- Returns `false` if timer ID is invalid
- Returns `false` if new tags array is empty

##### `validateTags(tagString)`

Validates tag input string and returns parsed tags with validation results.

```qml
const validation = TimewarriorService.validateTags("work, project; urgent")
if (validation.isValid) {
    console.log("Valid tags:", validation.tags)
} else {
    console.log("Errors:", validation.errors)
}
```

**Parameters:**
- `tagString` (`string`): Raw tag input string

**Returns:** `object` with properties:
- `isValid` (`bool`): `true` if all tags are valid
- `errors` (`array<string>`): List of validation error messages
- `tags` (`array<string>`): Parsed and cleaned tag array

**Validation Rules:**
- Tags cannot contain whitespace
- Tags must be 1-128 characters long
- Tags cannot contain shell injection characters (`;&|`$(){}[]`)
- Input can use spaces, commas, or semicolons as separators

##### `parseTagInput(input)`

Parses raw tag input into an array of individual tags.

```qml
const tags = TimewarriorService.parseTagInput("work, project; urgent client")
// Result: ["work", "project", "urgent", "client"]
```

**Parameters:**
- `input` (`string`): Raw tag input string

**Returns:** `array<string>` - Parsed tag array

**Behavior:**
- Handles spaces, commas, and semicolons as separators
- Trims whitespace from each tag
- Filters out empty strings
- Returns empty array for null/empty input

##### `updateTagHistory(newTags)`

Updates the tag history with new tags for autocomplete functionality.

```qml
TimewarriorService.updateTagHistory(["project", "urgent"])
```

**Parameters:**
- `newTags` (`array<string>`): Tags to add to history

**Returns:** `void`

**Side Effects:**
- Adds new unique tags to `tagHistory`
- Maintains maximum history size of 100 tags
- Preserves insertion order for recent tags

#### Utility Methods

##### `getActiveTimer()`

Returns complete information about the currently active timer.

```qml
const timer = TimewarriorService.getActiveTimer()
console.log("Timer active:", timer.active)
console.log("Tags:", timer.tags)
console.log("Elapsed:", timer.elapsedSeconds)
```

**Parameters:** None

**Returns:** `object` with properties:
- `active` (`bool`): Whether timer is currently active
- `timerId` (`string`): Unique timer identifier
- `tags` (`array<string>`): Current timer tags
- `startTime` (`string`): ISO 8601 start time
- `elapsedSeconds` (`int`): Seconds elapsed

##### `getCurrentTimerId()`

Returns the unique identifier of the current timer.

```qml
const timerId = TimewarriorService.getCurrentTimerId()
```

**Parameters:** None

**Returns:** `string` - Timer ID or empty string if no active timer

##### `formatElapsedTime(seconds)`

Formats elapsed time as HH:MM:SS string.

```qml
const formatted = TimewarriorService.formatElapsedTime(3661)
// Result: "01:01:01"
```

**Parameters:**
- `seconds` (`int`): Number of seconds to format

**Returns:** `string` - Formatted time string

### Signals

#### Timer State Signals

##### `tagsUpdated(oldTags, newTags)`

Emitted when timer tags are successfully modified.

```qml
Connections {
    target: TimewarriorService
    function onTagsUpdated(oldTags, newTags) {
        console.log("Tags changed from", oldTags, "to", newTags)
    }
}
```

**Parameters:**
- `oldTags` (`array<string>`): Previous timer tags
- `newTags` (`array<string>`): New timer tags

##### `tagUpdateFailed(error)`

Emitted when tag modification fails.

```qml
Connections {
    target: TimewarriorService
    function onTagUpdateFailed(error) {
        console.error("Tag update failed:", error)
    }
}
```

**Parameters:**
- `error` (`string`): Error message describing the failure

## TimewarriorWidget

Complete UI widget with Material 3 theming and user interactions.

### Properties

#### Widget Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `implicitWidth` | `real` | `180` | Natural width of the widget |
| `implicitHeight` | `real` | `32` | Natural height of the widget |
| `enableGlobalShortcuts` | `bool` | `true` | Enable global keyboard shortcuts |
| `enableIpcHandler` | `bool` | `true` | Enable IPC command handling |

#### Styling Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `backgroundColor` | `color` | `Material.backgroundColor` | Widget background color |
| `textColor` | `color` | `Material.foreground` | Widget text color |
| `accentColor` | `color` | `Material.accent` | Widget accent color |
| `borderRadius` | `real` | `4` | Widget corner radius |

### Methods

#### Popup Management

##### `openInputPopup()`

Opens the timer input popup for starting a new timer.

```qml
widget.openInputPopup()
```

##### `closeInputPopup()`

Closes the timer input popup.

```qml
widget.closeInputPopup()
```

##### `openTagEditPopup()`

Opens the tag editing popup for modifying current timer tags.

```qml
widget.openTagEditPopup()
```

##### `closeTagEditPopup()`

Closes the tag editing popup.

```qml
widget.closeTagEditPopup()
```

### Global Shortcuts

When `enableGlobalShortcuts` is `true`, the widget registers these shortcuts:

| Shortcut | Action | Description |
|----------|--------|-------------|
| `timewarriorStartOrStop` | Toggle timer | Start timer or stop current timer |
| `timewarriorOpenInput` | Open input | Open timer input dialog |
| `timewarriorEditTags` | Edit tags | Edit tags on current timer |

### IPC Interface

When `enableIpcHandler` is `true`, the widget responds to IPC commands:

| Command | Parameters | Description |
|---------|------------|-------------|
| `startOrStop()` | none | Toggle timer start/stop |
| `openInput()` | none | Open input dialog |
| `editTags()` | none | Edit current timer tags |

## IntegrationComponent

High-level API component that simplifies integration with external applications.

### Properties

#### Read-Only Properties

| Property | Type | Description |
|----------|------|-------------|
| `service` | `object` | Reference to TimewarriorService singleton |
| `timerActive` | `bool` | Current timer active state |
| `currentTags` | `array<string>` | Current timer tags |
| `elapsedTime` | `string` | Formatted elapsed time string |
| `timewAvailable` | `bool` | Timewarrior availability status |
| `errorMessage` | `string` | Current error message |

### Methods

#### Timer Control

##### `startTimer(tags)`

Starts a timer with validation and error handling.

```qml
const success = integration.startTimer(["work", "project"])
if (success) {
    console.log("Timer started successfully")
}
```

**Parameters:**
- `tags` (`array<string>`): Tags for the new timer

**Returns:** `bool` - `true` if timer started successfully

**Side Effects:**
- Emits `timerStarted` signal on success
- Emits `error` signal on failure

##### `stopTimer()`

Stops the current timer with validation.

```qml
const success = integration.stopTimer()
```

**Returns:** `bool` - `true` if timer stopped successfully

**Side Effects:**
- Emits `timerStopped` signal on success
- Emits `error` signal on failure

##### `updateTags(newTags)`

Updates tags on the current timer.

```qml
const success = integration.updateTags(["work", "urgent", "meeting"])
```

**Parameters:**
- `newTags` (`array<string>`): New tags to apply

**Returns:** `bool` - `true` if tags updated successfully

##### `toggleTimer()`

Toggles timer state (requires tags for starting).

```qml
const success = integration.toggleTimer()
```

**Returns:** `bool` - `true` if operation successful

**Note:** For starting, requires tags to be available from context or user input.

#### Utility Methods

##### `getActiveTimer()`

Returns active timer information.

```qml
const timer = integration.getActiveTimer()
```

**Returns:** `object` - Timer information object

##### `validateTagInput(input)`

Validates tag input string.

```qml
const validation = integration.validateTagInput("work, project")
```

**Returns:** `object` - Validation result with `isValid`, `errors`, and `tags` properties

### Signals

#### User Action Signals

##### `timerStarted(tags)`

Emitted when a timer is started.

```qml
IntegrationComponent {
    onTimerStarted: function(tags) {
        console.log("Timer started with tags:", tags)
        // Update UI, log to database, etc.
    }
}
```

**Parameters:**
- `tags` (`array<string>`): Tags used for the started timer

##### `timerStopped()`

Emitted when a timer is stopped.

```qml
onTimerStopped: {
    console.log("Timer stopped")
    // Update UI, save duration, etc.
}
```

##### `tagsUpdated(oldTags, newTags)`

Emitted when timer tags are updated.

```qml
onTagsUpdated: function(oldTags, newTags) {
    console.log("Tags changed:", oldTags, "→", newTags)
    // Update UI displays, log changes, etc.
}
```

**Parameters:**
- `oldTags` (`array<string>`): Previous tags
- `newTags` (`array<string>`): New tags

##### `error(message)`

Emitted when an error occurs.

```qml
onError: function(message) {
    console.error("Integration error:", message)
    // Show error message to user, log, etc.
}
```

**Parameters:**
- `message` (`string`): Error message

## Type Definitions

### TimerInfo Object

```javascript
{
    active: boolean,           // Timer is currently running
    timerId: string,          // Unique timer identifier
    tags: string[],           // Array of timer tags
    startTime: string,        // ISO 8601 start time
    elapsedSeconds: number    // Seconds since start
}
```

### ValidationResult Object

```javascript
{
    isValid: boolean,         // Tags passed validation
    errors: string[],         // Array of error messages
    tags: string[]           // Parsed and cleaned tags
}
```

### TagHistoryEntry Object

```javascript
{
    tag: string,             // Tag value
    lastUsed: string,        // ISO 8601 timestamp of last use
    usageCount: number       // Number of times tag was used
}
```

## Signals and Events

### Signal Connection Patterns

#### Service-Level Connections

```qml
Connections {
    target: TimewarriorService

    function onTagsUpdated(oldTags, newTags) {
        // Handle tag updates
    }

    function onTagUpdateFailed(error) {
        // Handle tag update errors
    }
}
```

#### Integration-Level Connections

```qml
IntegrationComponent {
    id: integration

    onTimerStarted: function(tags) {
        // Custom timer started handling
    }

    onTimerStopped: {
        // Custom timer stopped handling
    }

    onError: function(message) {
        // Custom error handling
    }
}
```

### Event Flow

1. **Timer Start**
   - User action → `startTimer()` → timewarrior command → state update → `timerStarted` signal

2. **Timer Stop**
   - User action → `stopTimer()` → timewarrior command → state update → `timerStopped` signal

3. **Tag Update**
   - User action → `modifyTimerTags()` → validation → timewarrior command → result → `tagsUpdated` or `tagUpdateFailed` signal

## Error Handling

### Error Types

#### System Errors

- **Timewarrior not found**: `timewAvailable` becomes `false`, `errorMessage` set
- **Command execution failures**: `errorMessage` updated with command output
- **JSON parsing errors**: Console error, state reset to inactive

#### Validation Errors

- **Empty tags**: Validation fails with descriptive error
- **Invalid tag format**: Validation fails with character/length errors
- **Security violations**: Tags with dangerous characters rejected

#### State Errors

- **No active timer**: Operations requiring active timer fail gracefully
- **Invalid timer ID**: Tag modification fails with appropriate error
- **Concurrent modifications**: State conflicts detected and resolved

### Error Handling Patterns

#### Graceful Degradation

```qml
// Check availability before use
if (!TimewarriorService.timewAvailable) {
    console.error("Timewarrior not available:", TimewarriorService.errorMessage)
    return
}

// Validate input before processing
const validation = TimewarriorService.validateTags(userInput)
if (!validation.isValid) {
    console.error("Invalid tags:", validation.errors.join(", "))
    return
}
```

#### Error Recovery

```qml
Connections {
    target: TimewarriorService
    function onTagUpdateFailed(error) {
        // Implement retry logic or user notification
        console.error("Tag update failed, retrying...")
        setTimeout(() => {
            // Retry operation or notify user
        }, 1000)
    }
}
```

## Usage Patterns

### Basic Widget Integration

```qml
import QtQuick
import qs_timew 2.0

Rectangle {
    width: 200
    height: 40

    TimewarriorWidget {
        id: widget
        anchors.fill: parent
        anchors.margins: 4

        // Custom styling (optional)
        backgroundColor: "#f0f0f0"
        textColor: "#333333"
        borderRadius: 8
    }
}
```

### Service-Level Integration

```qml
import QtQuick
import qs_timew 2.0

Item {
    // Direct service access
    property var timerState: TimewarriorService.getActiveTimer()

    Timer {
        interval: 1000
        repeat: true
        running: TimewarriorService.timerActive
        onTriggered: {
            // Update custom UI with elapsed time
            customTimerDisplay.text = TimewarriorService.formatElapsedTime(
                TimewarriorService.elapsedSeconds
            )
        }
    }

    Button {
        text: "Start Work Timer"
        onClicked: TimewarriorService.startTimer(["work", "project"])
    }
}
```

### High-Level Integration

```qml
import QtQuick
import QtQuick.Controls
import qs_timew 2.0

ApplicationWindow {
    IntegrationComponent {
        id: timew

        onTimerStarted: function(tags) {
            statusLabel.text = "Started: " + tags.join(", ")
        }

        onTimerStopped: {
            statusLabel.text = "Timer stopped"
        }

        onError: function(message) {
            statusLabel.text = "Error: " + message
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 10

        Label {
            id: statusLabel
            text: "Ready"
        }

        Button {
            text: timew.timerActive ? "Stop Timer" : "Start Timer"
            onClicked: timew.timerActive ? timew.stopTimer() : timew.startTimer(["demo"])
        }
    }
}
```

### Custom UI with Service Integration

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import qs_timew 2.0

Rectangle {
    width: 300
    height: 200

    // Custom timer display
    Row {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        spacing: 10

        Text {
            text: TimewarriorService.timerActive
                ? TimewarriorService.formatElapsedTime(TimewarriorService.elapsedSeconds)
                : "No timer running"
            font.pixelSize: 24
            font.weight: Font.Bold
        }

        Text {
            text: TimewarriorService.currentTags.join(" ")
            font.pixelSize: 16
            color: Material.accent
        }
    }

    // Custom controls
    Column {
        anchors.centerIn: parent
        spacing: 10

        TextField {
            id: tagInput
            placeholderText: "Enter tags..."
            width: 200
        }

        Button {
            text: "Start Timer"
            anchors.horizontalCenter: parent.horizontalCenter
            enabled: tagInput.text.trim().length > 0 && !TimewarriorService.timerActive

            onClicked: {
                const validation = TimewarriorService.validateTags(tagInput.text)
                if (validation.isValid) {
                    TimewarriorService.startTimer(validation.tags)
                    tagInput.text = ""
                } else {
                    console.error("Invalid tags:", validation.errors.join(", "))
                }
            }
        }

        Button {
            text: "Stop Timer"
            anchors.horizontalCenter: parent.horizontalCenter
            enabled: TimewarriorService.timerActive
            highlighted: true

            onClicked: TimewarriorService.stopTimer()
        }
    }

    // Error display
    Text {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 10
        text: TimewarriorService.errorMessage
        color: Material.color(Material.Red)
        visible: TimewarriorService.errorMessage.length > 0
    }
}
```

This API reference provides comprehensive documentation for all public interfaces in the qs-timew module. For practical examples and integration patterns, see the [Usage Examples](usage-examples.md) and [Integration Guide](integration-guide.md).