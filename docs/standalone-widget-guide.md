# Standalone TimewarriorWidget Guide

This guide explains the conversion of the QuickShell-based TimewarriorWidget into a standalone QML component that can be used in any Qt Quick application.

## Overview

The standalone `TimewarriorWidget.qml` provides all the functionality of the original QuickShell widget while using only standard Qt/QML components. This makes it compatible with any Qt Quick application without requiring QuickShell dependencies.

## Key Changes from QuickShell Version

### 1. Dependencies Replaced

| QuickShell Component | Standard Qt/QML Replacement | Notes |
|----------------------|---------------------------|-------|
| `GlobalShortcut` | `Shortcut` | Standard Qt global shortcuts |
| `PanelWindow` | `Popup` | Standard popup windows with positioning |
| `Scope` | `QtObject` | Simple object container |
| `WlrLayershell` | `Popup` positioning | Standard screen positioning |
| `HyprlandFocusGrab` | `Popup.focus` | Built-in popup focus management |
| `IpcHandler` | `QtObject` stub | Placeholder for future IPC implementation |
| `Appearance` system | Material 3 colors | Custom color definitions |
| `RippleButton` | `MaterialButton` | Custom button component |
| `MaterialSymbol` | `MaterialIcon` | Text/emoji icon fallbacks |
| `StyledText` | `Text` | Standard text with Material styling |

### 2. Material 3 Theme Implementation

The widget includes a complete Material 3 color palette as a fallback for the QuickShell Appearance system:

```qml
readonly property var m3Colors: ({
    primary: "#6750A4",
    onPrimary: "#FFFFFF",
    primaryContainer: "#EADDFF",
    // ... complete color system
})
```

### 3. Optional Features

Features that depended on QuickShell-specific functionality are now optional:

- **Global Shortcuts**: Controlled by `enableGlobalShortcuts` property
- **IPC Handler**: Controlled by `enableIpcHandler` property (stub implementation)

## Usage

### Basic Integration

```qml
import QtQuick
import QtQuick.Window

// Import the widget (assuming module registration)
// import QSTimew.Widgets 1.0

ApplicationWindow {
    width: 800
    height: 600
    visible: true

    // Basic usage
    TimewarriorWidget {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10
    }
}
```

### Configuration Options

```qml
TimewarriorWidget {
    // Enable global shortcuts (default: false)
    enableGlobalShortcuts: true

    // Enable IPC handler (default: false)
    enableIpcHandler: false

    // Standard Qt properties
    implicitWidth: 180
    implicitHeight: 32

    // Position and layout
    anchors.centerIn: parent
}
```

## Features Preserved

### 1. Three States

1. **Idle State**: Shows "Start" button with timer icon
2. **Active State**: Shows elapsed time and current tags
3. **Error State**: Shows warning when timewarrior is not found

### 2. Timer Functionality

- Start timer with tags
- Stop active timer
- Real-time elapsed time updates
- Tag validation and error handling

### 3. Popups

- **Input Popup**: Enter tags for new timer
- **Tag Edit Popup**: Modify tags of active timer
- Both support keyboard navigation (Enter/Escape)

### 4. Visual Feedback

- Hover effects on all interactive elements
- Material 3 color scheme
- Smooth animations and transitions
- Validation error display

### 5. Keyboard Shortcuts (Optional)

When `enableGlobalShortcuts` is true:

- `Ctrl+Shift+T`: Start/Stop timer
- `Ctrl+Shift+I`: Open input popup
- `Ctrl+Shift+E`: Edit tags (if timer active)

## Component Architecture

### Custom Components

1. **MaterialButton**: Replaces QuickShell's RippleButton
   ```qml
   MaterialButton {
       text: "Start"
       icon: "▶"
       onClicked: { /* handle click */ }
   }
   ```

2. **MaterialIcon**: Replaces QuickShell's MaterialSymbol
   ```qml
   MaterialIcon {
       iconName: "timer"
       iconSize: 16
       iconColor: "#FFFFFF"
   }
   ```

### Popup System

Both popups use standard Qt Quick Popup with:
- Modal behavior
- Automatic positioning on screen
- Focus management
- Escape key handling

## Dependencies

The standalone widget requires only standard Qt modules:

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Window
import Qt.labs.platform
```

## Service Integration

The widget expects a `TimewarriorService` singleton with the following interface:

```qml
// Properties
property bool timerActive
property var currentTags: []
property int elapsedSeconds
property var lastUsedTags: []
property bool timewAvailable

// Functions
function startTimer(tags)
function stopTimer()
function validateTags(tagString)
function modifyTimerTags(timerId, newTags)
function getCurrentTimerId()
function formatElapsedTime(seconds)

// Signals
signal tagsUpdated(oldTags, newTags)
signal tagUpdateFailed(error)
```

## Module Registration

To use the widget as a module, create/update your `qmldir`:

```
module QSTimew.Widgets

singleton TimewarriorService 1.0 ../services/TimewarriorService.qml
TimewarriorWidget 1.0 ../widgets/TimewarriorWidget.qml
```

## Testing

The widget can be tested using the provided `StandaloneExample.qml` which demonstrates:

- Basic integration
- Configuration options
- Manual controls for testing
- Status monitoring

## Platform Considerations

### Global Shortcuts

Global shortcuts may require additional setup on some platforms:

- **Linux**: Works with standard Qt
- **Windows**: May need elevated privileges
- **macOS**: Accessibility permissions may be required

### IPC Handler

The current implementation provides a stub for IPC functionality. Platform-specific implementations can be added:

```qml
// Future platform-specific IPC implementations
QtObject {
    // Linux: DBus integration
    // Windows: Named pipes or COM
    // macOS: Distributed notifications
}
```

## Styling Customization

The widget's appearance can be customized by modifying the color properties:

```qml
// Override default colors
TimewarriorWidget {
    // Custom color overrides
    property color customPrimary: "#your-color"
    // Modify m3Colors object as needed
}
```

## Performance Considerations

- The widget uses efficient Timer components for real-time updates
- Lazy loading with Loader components for state management
- Minimal property bindings to reduce update overhead
- Optimized animations using standard Qt animation system

## Migration from QuickShell

To migrate existing QuickShell applications:

1. Replace QuickShell imports with standard Qt imports
2. Update widget instantiation to include configuration properties
3. Remove QuickShell-specific dependencies
4. Test global shortcut functionality on target platforms
5. Verify popup positioning and behavior

## Troubleshooting

### Common Issues

1. **Widget not visible**: Check that TimewarriorService is properly imported
2. **Popups not appearing**: Ensure modal popups are supported in your Qt version
3. **Global shortcuts not working**: Check platform-specific requirements
4. **Colors not applied**: Verify Material theme is properly set

### Debug Mode

Enable console logging by setting environment variable:
```
QT_LOGGING_RULES="*=true"
```

## Future Enhancements

Potential improvements for future versions:

- Complete IPC handler implementation
- Additional theme options
- Plugin system for custom icons
- Accessibility improvements
- Animation customization options