# Usage Examples

Comprehensive examples demonstrating how to use qs-timew in various scenarios and integration patterns.

## Table of Contents

- [Quick Start Examples](#quick-start-examples)
- [Basic Widget Integration](#basic-widget-integration)
- [Service-Level Integration](#service-level-integration)
- [High-Level API Integration](#high-level-api-integration)
- [Custom UI Examples](#custom-ui-examples)
- [Real-World Scenarios](#real-world-scenarios)
- [Advanced Patterns](#advanced-patterns)
- [Integration Examples](#integration-examples)

## Quick Start Examples

### Minimal Example

The simplest possible integration - just drop in the widget:

```qml
import QtQuick
import qs_timew 2.0

Rectangle {
    width: 180
    height: 32
    color: "#f5f5f5"
    radius: 4

    TimewarriorWidget {
        anchors.fill: parent
        anchors.margins: 2
    }
}
```

**Use Case:** Quick prototype or simple application where you just need basic time tracking.

### Basic Application Window

A complete minimal application with the timewarrior widget:

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import qs_timew 2.0

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "Time Tracker"

    Material.theme: Material.System
    Material.accent: Material.Blue

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 16

            Text {
                text: "Time Tracker"
                font.pixelSize: 18
                font.weight: Font.Bold
                Layout.fillWidth: true
            }

            Rectangle {
                Layout.preferredWidth: 200
                Layout.preferredHeight: 36
                color: Material.backgroundColor
                radius: 18
                border.color: Material.accent
                border.width: 1

                TimewarriorWidget {
                    anchors.fill: parent
                    anchors.margins: 4
                }
            }
        }
    }

    Label {
        anchors.centerIn: parent
        text: "Use the widget in the header to track time"
        font.pixelSize: 16
        color: Material.secondaryTextColor
    }
}
```

## Basic Widget Integration

### Custom Styled Widget

Widget with custom styling and theming:

```qml
import QtQuick
import QtQuick.Controls.Material
import qs_timew 2.0

Rectangle {
    id: root
    width: 220
    height: 40

    // Custom properties for styling
    property color backgroundColor: Material.backgroundColor
    property color textColor: Material.foreground
    property color accentColor: Material.accent
    property real borderRadius: 8

    color: backgroundColor
    radius: borderRadius
    border.color: accentColor
    border.width: 2

    Behavior on color {
        ColorAnimation { duration: 200 }
    }

    TimewarriorWidget {
        id: widget
        anchors.fill: parent
        anchors.margins: 4

        // Pass custom styling to widget
        backgroundColor: "transparent"
        textColor: root.textColor
        accentColor: root.accentColor

        // Handle hover states
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: root.color = Qt.lighter(root.backgroundColor, 1.1)
            onExited: root.color = root.backgroundColor
        }
    }
}
```

### Compact Widget

A smaller, more compact version for tight spaces:

```qml
import QtQuick
import qs_timew 2.0

Rectangle {
    width: 120
    height: 24
    color: "#e0e0e0"
    radius: 12

    TimewarriorWidget {
        anchors.fill: parent
        anchors.margins: 2

        // Override implicit size for compact display
        implicitWidth: 116
        implicitHeight: 20
    }
}
```

### Status Bar Integration

Integration into a status bar or toolbar:

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs_timew 2.0

ToolBar {
    id: root
    height: 32

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 16

        // Application title
        Label {
            text: "My Application"
            font.pixelSize: 14
            font.weight: Font.Medium
            Layout.fillWidth: true
        }

        // Status items
        Label {
            text: "Ready"
            font.pixelSize: 12
            color: "#666"
        }

        // Timewarrior widget
        Rectangle {
            Layout.preferredWidth: 160
            Layout.preferredHeight: 24
            color: "#f0f0f0"
            radius: 4

            TimewarriorWidget {
                anchors.fill: parent
                anchors.margins: 2

                // Disable global shortcuts in status bar context
                enableGlobalShortcuts: false
                enableIpcHandler: false
            }
        }

        // Clock
        Label {
            text: Qt.formatDateTime(new Date(), "hh:mm:ss")
            font.pixelSize: 12
            font.family: "monospace"

            Timer {
                interval: 1000
                repeat: true
                running: true
                onTriggered: parent.text = Qt.formatDateTime(new Date(), "hh:mm:ss")
            }
        }
    }
}
```

## Service-Level Integration

### Direct Service Access

Using the TimewarriorService directly for maximum control:

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import qs_timew 2.0

ApplicationWindow {
    visible: true
    width: 600
    height: 400
    title: "Service Integration Example"

    // Direct service access
    property var service: TimewarriorService

    Column {
        anchors.centerIn: parent
        spacing: 20
        width: 400

        // Timer status display
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: 80
            color: service.timerActive ? Material.color(Material.Green, 100) : Material.color(Material.Grey, 100)
            radius: 8
            border.color: service.timerActive ? Material.color(Material.Green) : Material.color(Material.Grey)
            border.width: 2

            Column {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: service.timerActive ? "Timer Running" : "No Timer Active"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    color: service.timerActive ? Material.color(Material.Green) : Material.color(Material.Grey)
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: service.timerActive
                        ? service.formatElapsedTime(service.elapsedSeconds)
                        : "Click to start timer"
                    font.pixelSize: 14
                    color: service.timerActive ? Material.color(Material.Green) : Material.color(Material.Grey)
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: service.currentTags.join(" ")
                    font.pixelSize: 12
                    color: Material.secondaryTextColor
                    visible: service.timerActive && service.currentTags.length > 0
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (service.timerActive) {
                        service.stopTimer()
                    } else {
                        // Start with default tags
                        service.startTimer(["work", "service-example"])
                    }
                }
            }
        }

        // Tag input section
        TextField {
            id: tagInput
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            placeholderText: "Enter tags (e.g., work project urgent)"
            enabled: !service.timerActive

            Keys.onReturnPressed: startTimerButton.clicked()
        }

        // Control buttons
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            Button {
                id: startTimerButton
                text: "Start Timer"
                enabled: tagInput.text.trim().length > 0 && !service.timerActive

                onClicked: {
                    const validation = service.validateTags(tagInput.text)
                    if (validation.isValid) {
                        service.startTimer(validation.tags)
                        tagInput.text = ""
                    } else {
                        errorText.text = "Invalid tags: " + validation.errors.join(", ")
                    }
                }
            }

            Button {
                text: "Stop Timer"
                enabled: service.timerActive
                highlighted: true

                onClicked: service.stopTimer()
            }
        }

        // Error display
        Text {
            id: errorText
            anchors.horizontalCenter: parent.horizontalCenter
            color: Material.color(Material.Red)
            font.pixelSize: 12
            visible: text.length > 0
        }

        // Service status
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: 60
            color: "#f5f5f5"
            radius: 4

            Column {
                anchors.centerIn: parent
                spacing: 2

                Text {
                    text: "Service Status: " + (service.timewAvailable ? "Available" : "Not Available")
                    font.pixelSize: 12
                    color: service.timewAvailable ? Material.color(Material.Green) : Material.color(Material.Red)
                }

                Text {
                    text: "Last Used Tags: " + service.lastUsedTags.join(" ")
                    font.pixelSize: 10
                    color: Material.secondaryTextColor
                }

                Text {
                    text: "Week Tags: " + service.weekTags.length + " unique"
                    font.pixelSize: 10
                    color: Material.secondaryTextColor
                }
            }
        }
    }

    // Timer for updating elapsed time display
    Timer {
        interval: 1000
        repeat: true
        running: service.timerActive
        onTriggered: {
            // Trigger re-evaluation of binding
            service.elapsedSeconds = service.elapsedSeconds
        }
    }
}
```

### Tag Management Interface

Advanced tag editing and management:

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import qs_timew 2.0

ApplicationWindow {
    visible: true
    width: 700
    height: 500
    title: "Tag Management Example"

    property var service: TimewarriorService

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Left panel - Current timer info
        Rectangle {
            Layout.preferredWidth: 300
            Layout.fillHeight: true
            color: Material.backgroundColor
            radius: 8
            border.color: Material.dividerColor
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                Text {
                    text: "Current Timer"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                }

                // Timer status
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: service.timerActive ? Material.color(Material.Green, 100) : Material.color(Material.Grey, 100)
                    radius: 4

                    Column {
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: service.timerActive ? "ACTIVE" : "INACTIVE"
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            color: service.timerActive ? Material.color(Material.Green) : Material.color(Material.Grey)
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: service.formatElapsedTime(service.elapsedSeconds)
                            font.pixelSize: 12
                            font.family: "monospace"
                            visible: service.timerActive
                        }
                    }
                }

                // Current tags
                GroupBox {
                    Layout.fillWidth: true
                    title: "Current Tags"

                    Column {
                        anchors.fill: parent
                        spacing: 4

                        Repeater {
                            model: service.currentTags

                            Rectangle {
                                width: parent.width
                                height: 24
                                color: Material.color(Material.Blue, 100)
                                radius: 4

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.pixelSize: 12
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "No tags"
                            color: Material.secondaryTextColor
                            visible: service.currentTags.length === 0
                        }
                    }
                }

                // Tag editing
                GroupBox {
                    Layout.fillWidth: true
                    title: "Edit Tags"
                    enabled: service.timerActive

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 8

                        TextField {
                            id: tagEditInput
                            Layout.fillWidth: true
                            placeholderText: "New tags..."
                            text: service.currentTags.join(" ")

                            Keys.onReturnPressed: updateTagsButton.clicked()
                        }

                        Button {
                            id: updateTagsButton
                            Layout.fillWidth: true
                            text: "Update Tags"

                            onClicked: {
                                const validation = service.validateTags(tagEditInput.text)
                                if (validation.isValid) {
                                    const timerId = service.getCurrentTimerId()
                                    service.modifyTimerTags(timerId, validation.tags)
                                } else {
                                    console.error("Invalid tags:", validation.errors)
                                }
                            }
                        }
                    }
                }

                Layout.fillHeight: true
            }
        }

        // Right panel - Tag history and suggestions
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Material.backgroundColor
            radius: 8
            border.color: Material.dividerColor
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                Text {
                    text: "Tag Management"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                }

                // Tag history
                GroupBox {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    title: "Tag History"

                    ScrollView {
                        anchors.fill: parent

                        Column {
                            width: parent.width
                            spacing: 4

                            Repeater {
                                model: service.tagHistory

                                Rectangle {
                                    width: parent.width
                                    height: 28
                                    color: "#f5f5f5"
                                    radius: 4

                                    Row {
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.margins: 8
                                        spacing: 8

                                        Text {
                                            text: modelData
                                            font.pixelSize: 12
                                        }

                                        Rectangle {
                                            width: 16
                                            height: 16
                                            radius: 8
                                            color: Material.color(Material.Blue)

                                            Text {
                                                anchors.centerIn: parent
                                                text: "+"
                                                color: "white"
                                                font.pixelSize: 12
                                                font.bold: true
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    // Add tag to edit input
                                                    const currentTags = tagEditInput.text.trim()
                                                    const newTags = currentTags
                                                        ? currentTags + " " + modelData
                                                        : modelData
                                                    tagEditInput.text = newTags
                                                    tagEditInput.focus = true
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "No tag history"
                                color: Material.secondaryTextColor
                                visible: service.tagHistory.length === 0
                            }
                        }
                    }
                }

                // Week tags
                GroupBox {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 150
                    title: "This Week's Tags"

                    ScrollView {
                        anchors.fill: parent

                        Flow {
                            width: parent.width
                            spacing: 4

                            Repeater {
                                model: service.weekTags

                                Rectangle {
                                    width: tagText.width + 16
                                    height: 24
                                    color: Material.color(Material.Purple, 100)
                                    radius: 12

                                    Text {
                                        id: tagText
                                        anchors.centerIn: parent
                                        text: modelData
                                        font.pixelSize: 10
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            const currentTags = tagEditInput.text.trim()
                                            const newTags = currentTags
                                                ? currentTags + " " + modelData
                                                : modelData
                                            tagEditInput.text = newTags
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Handle tag updates
    Connections {
        target: service

        function onTagsUpdated(oldTags, newTags) {
            console.log("Tags updated:", oldTags, "→", newTags)
        }

        function onTagUpdateFailed(error) {
            console.error("Tag update failed:", error)
        }
    }
}
```

## High-Level API Integration

### IntegrationComponent Example

Using the IntegrationComponent for simplified API access:

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import qs_timew 2.0

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "Integration Component Example"

    // High-level integration component
    IntegrationComponent {
        id: timew

        onTimerStarted: function(tags) {
            statusText.text = "Timer started: " + tags.join(", ")
            console.log("Timer started with tags:", tags)
        }

        onTimerStopped: {
            statusText.text = "Timer stopped"
            console.log("Timer stopped")
        }

        onTagsUpdated: function(oldTags, newTags) {
            statusText.text = "Tags updated: " + oldTags.join(", ") + " → " + newTags.join(", ")
            console.log("Tags updated:", oldTags, "→", newTags)
        }

        onError: function(message) {
            statusText.text = "Error: " + message
            console.error("Error:", message)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Status bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: Material.backgroundColor
            radius: 8
            border.color: Material.dividerColor
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 16

                Text {
                    text: "Status:"
                    font.pixelSize: 14
                    font.weight: Font.Bold
                }

                Text {
                    id: statusText
                    Layout.fillWidth: true
                    text: "Ready"
                    font.pixelSize: 14
                    color: Material.secondaryTextColor
                }

                Rectangle {
                    width: 12
                    height: 12
                    radius: 6
                    color: timew.timewAvailable ? Material.color(Material.Green) : Material.color(Material.Red)
                }

                Text {
                    text: timew.timewAvailable ? "Timewarrior OK" : "Timewarrior Error"
                    font.pixelSize: 12
                    color: timew.timewAvailable ? Material.color(Material.Green) : Material.color(Material.Red)
                }
            }
        }

        // Main content
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 20

            // Left panel - Quick controls
            Rectangle {
                Layout.preferredWidth: 250
                Layout.fillHeight: true
                color: Material.backgroundColor
                radius: 8
                border.color: Material.dividerColor
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Text {
                        text: "Quick Controls"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                    }

                    // Timer toggle button
                    Button {
                        Layout.fillWidth: true
                        text: timew.timerActive ? "Stop Timer" : "Start Timer"
                        highlighted: timew.timerActive

                        onClicked: {
                            if (timew.timerActive) {
                                timew.stopTimer()
                            } else {
                                // Start with quick tags
                                timew.startTimer(["work", "integration-example"])
                            }
                        }
                    }

                    // Current timer info
                    GroupBox {
                        Layout.fillWidth: true
                        title: "Current Timer"

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 8

                            Text {
                                text: "Active: " + (timew.timerActive ? "Yes" : "No")
                            }

                            Text {
                                text: "Tags: " + (timew.currentTags.length > 0 ? timew.currentTags.join(", ") : "None")
                            }

                            Text {
                                text: "Elapsed: " + timew.elapsedTime
                            }
                        }
                    }

                    // Quick tag buttons
                    GroupBox {
                        Layout.fillWidth: true
                        title: "Quick Start"

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 8

                            Button {
                                Layout.fillWidth: true
                                text: "Work"
                                enabled: !timew.timerActive

                                onClicked: timew.startTimer(["work"])
                            }

                            Button {
                                Layout.fillWidth: true
                                text: "Meeting"
                                enabled: !timew.timerActive

                                onClicked: timew.startTimer(["meeting"])
                            }

                            Button {
                                Layout.fillWidth: true
                                text: "Break"
                                enabled: !timew.timerActive

                                onClicked: timew.startTimer(["break"])
                            }
                        }
                    }

                    Layout.fillHeight: true
                }
            }

            // Right panel - Advanced controls
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Material.backgroundColor
                radius: 8
                border.color: Material.dividerColor
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Text {
                        text: "Advanced Controls"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                    }

                    // Custom tag input
                    GroupBox {
                        Layout.fillWidth: true
                        title: "Custom Tags"

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 8

                            TextField {
                                id: customTagInput
                                Layout.fillWidth: true
                                placeholderText: "Enter custom tags..."
                                enabled: !timew.timerActive

                                Keys.onReturnPressed: startCustomButton.clicked()
                            }

                            Button {
                                id: startCustomButton
                                Layout.fillWidth: true
                                text: "Start Custom Timer"
                                enabled: customTagInput.text.trim().length > 0 && !timew.timerActive

                                onClicked: {
                                    const validation = timew.validateTagInput(customTagInput.text)
                                    if (validation.isValid) {
                                        timew.startTimer(validation.tags)
                                        customTagInput.text = ""
                                    } else {
                                        statusText.text = "Invalid tags: " + validation.errors.join(", ")
                                    }
                                }
                            }
                        }
                    }

                    // Tag editing
                    GroupBox {
                        Layout.fillWidth: true
                        title: "Edit Current Tags"
                        enabled: timew.timerActive

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 8

                            TextField {
                                id: editTagInput
                                Layout.fillWidth: true
                                placeholderText: "Edit tags..."
                                text: timew.currentTags.join(" ")

                                Keys.onReturnPressed: updateTagsButton.clicked()
                            }

                            Button {
                                id: updateTagsButton
                                Layout.fillWidth: true
                                text: "Update Tags"

                                onClicked: {
                                    const validation = timew.validateTagInput(editTagInput.text)
                                    if (validation.isValid) {
                                        timew.updateTags(validation.tags)
                                    } else {
                                        statusText.text = "Invalid tags: " + validation.errors.join(", ")
                                    }
                                }
                            }
                        }
                    }

                    // Timer information
                    GroupBox {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        title: "Timer Information"

                        ScrollView {
                            anchors.fill: parent

                            Column {
                                width: parent.width
                                spacing: 8

                                Text {
                                    text: "Service Information:"
                                    font.weight: Font.Bold
                                }

                                Text {
                                    text: "Timer Active: " + timew.timerActive
                                }

                                Text {
                                    text: "Timewarrior Available: " + timew.timewAvailable
                                }

                                Text {
                                    text: "Error Message: " + (timew.errorMessage || "None")
                                }

                                Text {
                                    text: "\nCurrent Timer Details:"
                                    font.weight: Font.Bold
                                }

                                Text {
                                    text: "Active: " + timew.timerActive
                                }

                                Text {
                                    text: "Tags: " + timew.currentTags.join(", ")
                                }

                                Text {
                                    text: "Elapsed: " + timew.elapsedTime
                                }

                                Text {
                                    text: "\nService Methods Available:"
                                    font.weight: Font.Bold
                                }

                                Text {
                                    text: "• getActiveTimer()"
                                    font.family: "monospace"
                                    font.pixelSize: 10
                                }

                                Text {
                                    text: "• validateTagInput(input)"
                                    font.family: "monospace"
                                    font.pixelSize: 10
                                }

                                Text {
                                    text: "• startTimer(tags)"
                                    font.family: "monospace"
                                    font.pixelSize: 10
                                }

                                Text {
                                    text: "• stopTimer()"
                                    font.family: "monospace"
                                    font.pixelSize: 10
                                }

                                Text {
                                    text: "• updateTags(tags)"
                                    font.family: "monospace"
                                    font.pixelSize: 10
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
```

## Custom UI Examples

### Dashboard Integration

Integrating timewarrior into a productivity dashboard:

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import qs_timew 2.0

ApplicationWindow {
    visible: true
    width: 1200
    height: 800
    title: "Productivity Dashboard"

    Material.theme: Material.System
    Material.accent: Material.Blue

    // Integration component for time tracking
    IntegrationComponent {
        id: timew

        onTimerStarted: function(tags) {
            // Log to dashboard analytics
            dashboard.logEvent("timer_started", { tags: tags })
        }

        onTimerStopped: {
            dashboard.logEvent("timer_stopped")
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Left sidebar - Navigation
        Rectangle {
            Layout.preferredWidth: 200
            Layout.fillHeight: true
            color: Material.backgroundColor
            radius: 8
            border.color: Material.dividerColor
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                Text {
                    text: "Dashboard"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                }

                // Time tracking widget
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "#f8f9fa"
                    radius: 8
                    border.color: Material.dividerColor

                    Column {
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Time Tracker"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }

                        TimewarriorWidget {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 180
                            height: 32
                        }
                    }
                }

                // Quick stats
                GroupBox {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    title: "Today's Stats"

                    Column {
                        anchors.fill: parent
                        spacing: 8

                        Text {
                            text: "Focus Time: 4h 32m"
                            font.pixelSize: 12
                        }

                        Text {
                            text: "Tasks Completed: 8"
                            font.pixelSize: 12
                        }

                        Text {
                            text: "Current Project: " + (timew.currentTags[0] || "None")
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }

        // Main content area
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 20

            // Top bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: Material.backgroundColor
                radius: 8
                border.color: Material.dividerColor
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 20

                    Text {
                        text: "Productivity Dashboard"
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        Layout.fillWidth: true
                    }

                    // Timer status indicator
                    Rectangle {
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 36
                        color: timew.timerActive ? Material.color(Material.Green, 100) : Material.color(Material.Grey, 100)
                        radius: 18
                        border.color: timew.timerActive ? Material.color(Material.Green) : Material.color(Material.Grey)

                        Row {
                            anchors.centerIn: parent
                            spacing: 8

                            Rectangle {
                                width: 12
                                height: 12
                                radius: 6
                                color: timew.timerActive ? Material.color(Material.Green) : Material.color(Material.Grey)
                            }

                            Text {
                                text: timew.timerActive ? timew.elapsedTime : "No Timer"
                                font.pixelSize: 12
                                font.family: "monospace"
                            }

                            Text {
                                text: timew.currentTags.join(" ")
                                font.pixelSize: 10
                                color: Material.secondaryTextColor
                            }
                        }
                    }

                    // Quick actions
                    Button {
                        text: "Start Focus"
                        enabled: !timew.timerActive
                        onClicked: timew.startTimer(["focus", "deep-work"])
                    }

                    Button {
                        text: "Take Break"
                        enabled: !timew.timerActive
                        onClicked: timew.startTimer(["break"])
                    }
                }
            }

            // Main dashboard grid
            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 2
                columnSpacing: 20
                rowSpacing: 20

                // Time tracking detail
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Material.backgroundColor
                    radius: 8
                    border.color: Material.dividerColor
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16

                        Text {
                            text: "Time Tracking"
                            font.pixelSize: 18
                            font.weight: Font.Bold
                        }

                        // Current timer details
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 80
                            color: timew.timerActive ? Material.color(Material.Blue, 50) : Material.color(Material.Grey, 50)
                            radius: 8

                            Column {
                                anchors.centerIn: parent
                                spacing: 8

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: timew.timerActive ? "Timer Active" : "No Active Timer"
                                    font.pixelSize: 16
                                    font.weight: Font.Bold
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: timew.currentTags.join(", ")
                                    font.pixelSize: 14
                                    color: Material.accent
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: timew.elapsedTime
                                    font.pixelSize: 12
                                    font.family: "monospace"
                                }
                            }
                        }

                        // Tag management
                        GroupBox {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            title: "Tag Management"

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 8

                                TextField {
                                    id: tagInput
                                    Layout.fillWidth: true
                                    placeholderText: "Enter tags..."
                                    enabled: !timew.timerActive

                                    Keys.onReturnPressed: startButton.clicked()
                                }

                                Button {
                                    id: startButton
                                    Layout.fillWidth: true
                                    text: "Start Timer"
                                    enabled: tagInput.text.trim().length > 0 && !timew.timerActive

                                    onClicked: {
                                        const validation = timew.validateTagInput(tagInput.text)
                                        if (validation.isValid) {
                                            timew.startTimer(validation.tags)
                                            tagInput.text = ""
                                        }
                                    }
                                }

                                Button {
                                    Layout.fillWidth: true
                                    text: "Stop Timer"
                                    enabled: timew.timerActive
                                    highlighted: true

                                    onClicked: timew.stopTimer()
                                }
                            }
                        }
                    }
                }

                // Task management
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Material.backgroundColor
                    radius: 8
                    border.color: Material.dividerColor
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16

                        Text {
                            text: "Tasks"
                            font.pixelSize: 18
                            font.weight: Font.Bold
                        }

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Column {
                                width: parent.width
                                spacing: 8

                                Repeater {
                                    model: 5

                                    Rectangle {
                                        width: parent.width
                                        height: 60
                                        color: "#f8f9fa"
                                        radius: 8
                                        border.color: Material.dividerColor

                                        Row {
                                            anchors.fill: parent
                                            anchors.margins: 12
                                            spacing: 12

                                            CheckBox {
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            Column {
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: 2

                                                Text {
                                                    text: "Task " + (index + 1)
                                                    font.pixelSize: 14
                                                    font.weight: Font.Medium
                                                }

                                                Text {
                                                    text: "Project: " + (timew.currentTags[0] || "unassigned")
                                                    font.pixelSize: 12
                                                    color: Material.secondaryTextColor
                                                }
                                            }

                                            Rectangle {
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: 80
                                                height: 24
                                                radius: 12
                                                color: Material.color(Material.Blue, 100)

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "2h 15m"
                                                    font.pixelSize: 10
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Button {
                            Layout.fillWidth: true
                            text: "Add Task"
                        }
                    }
                }
            }
        }
    }

    // Mock dashboard object for logging
    QtObject {
        id: dashboard

        function logEvent(event, data) {
            console.log("Dashboard Event:", event, data)
        }
    }
}
```

## Real-World Scenarios

### Freelancer Time Tracking

Complete time tracking solution for freelancers:

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import qs_timew 2.0

ApplicationWindow {
    visible: true
    width: 1000
    height: 700
    title: "Freelancer Time Tracker"

    IntegrationComponent {
        id: timew

        onTimerStarted: function(tags) {
            // Log to project tracking
            projectTracker.logTimeEntry(tags)
        }

        onTimerStopped: {
            // Calculate session duration
            projectTracker.closeCurrentEntry()
        }
    }

    property var projectTracker: QtObject {
        property var currentProject: ""
        property var currentRate: 0
        property var todayEarnings: 0

        function logTimeEntry(tags) {
            // Extract project from tags
            for (let tag of tags) {
                if (tag.startsWith("project:")) {
                    currentProject = tag.substring(8)
                    break
                }
            }
        }

        function closeCurrentEntry() {
            // Calculate earnings based on time and rate
            // This would integrate with your billing system
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Header with client info
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: Material.backgroundColor
            radius: 8
            border.color: Material.dividerColor

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 20

                Column {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: "Current Project: " + projectTracker.currentProject
                        font.pixelSize: 16
                        font.weight: Font.Bold
                    }

                    Text {
                        text: "Today's Earnings: $" + projectTracker.todayEarnings.toFixed(2)
                        font.pixelSize: 14
                        color: Material.color(Material.Green)
                    }
                }

                // Timer display
                Rectangle {
                    Layout.preferredWidth: 250
                    Layout.preferredHeight: 50
                    color: timew.timerActive ? Material.color(Material.Green, 100) : Material.color(Material.Grey, 100)
                    radius: 8
                    border.color: timew.timerActive ? Material.color(Material.Green) : Material.color(Material.Grey)

                    Row {
                        anchors.centerIn: parent
                        spacing: 12

                        Text {
                            text: timew.elapsedTime
                            font.pixelSize: 18
                            font.family: "monospace"
                            font.weight: Font.Bold
                        }

                        Text {
                            text: timew.currentTags.join(" ")
                            font.pixelSize: 12
                            color: Material.secondaryTextColor
                        }
                    }
                }
            }
        }

        // Main workspace
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 20

            // Left panel - Project selection and quick actions
            Rectangle {
                Layout.preferredWidth: 300
                Layout.fillHeight: true
                color: Material.backgroundColor
                radius: 8
                border.color: Material.dividerColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Text {
                        text: "Projects"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                    }

                    // Project list
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200

                        Column {
                            width: parent.width
                            spacing: 8

                            Repeater {
                                model: [
                                    { name: "Website Redesign", rate: 75, tags: ["project:website", "client:abc"] },
                                    { name: "Mobile App", rate: 85, tags: ["project:mobile", "client:xyz"] },
                                    { name: "Database Migration", rate: 90, tags: ["project:database", "client:abc"] },
                                    { name: "API Development", rate: 80, tags: ["project:api", "client:def"] }
                                ]

                                Rectangle {
                                    width: parent.width
                                    height: 60
                                    color: projectTracker.currentProject === modelData.name
                                        ? Material.color(Material.Blue, 100)
                                        : "#f8f9fa"
                                    radius: 8
                                    border.color: Material.dividerColor

                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        spacing: 2

                                        Text {
                                            text: modelData.name
                                            font.pixelSize: 14
                                            font.weight: Font.Bold
                                        }

                                        Text {
                                            text: "$" + modelData.rate + "/hour"
                                            font.pixelSize: 12
                                            color: Material.color(Material.Green)
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            projectTracker.currentProject = modelData.name
                                            projectTracker.currentRate = modelData.rate
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Quick timer controls
                    GroupBox {
                        Layout.fillWidth: true
                        title: "Quick Timer"

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 8

                            Button {
                                Layout.fillWidth: true
                                text: timew.timerActive ? "Stop Timer" : "Start Timer"
                                highlighted: timew.timerActive

                                onClicked: {
                                    if (timew.timerActive) {
                                        timew.stopTimer()
                                    } else {
                                        const tags = ["project:" + projectTracker.currentProject, "freelance"]
                                        timew.startTimer(tags)
                                    }
                                }
                            }

                            Text {
                                text: "Current: " + (timew.timerActive ? timew.currentTags.join(" ") : "No timer")
                                font.pixelSize: 12
                                color: Material.secondaryTextColor
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }

                    // Time summary
                    GroupBox {
                        Layout.fillWidth: true
                        title: "Today's Summary"

                        Column {
                            anchors.fill: parent
                            spacing: 8

                            Text {
                                text: "Total Time: 6h 45m"
                                font.pixelSize: 12
                            }

                            Text {
                                text: "Billable Hours: 6.75"
                                font.pixelSize: 12
                            }

                            Text {
                                text: "Earnings: $" + projectTracker.todayEarnings.toFixed(2)
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                color: Material.color(Material.Green)
                            }
                        }
                    }

                    Layout.fillHeight: true
                }
            }

            // Right panel - Detailed time tracking
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Material.backgroundColor
                radius: 8
                border.color: Material.dividerColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Text {
                        text: "Time Entries"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                    }

                    // Time entries list
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Column {
                            width: parent.width
                            spacing: 8

                            Repeater {
                                model: [
                                    { time: "09:00 - 10:30", duration: "1h 30m", tags: ["project:website", "design"], earnings: 112.50 },
                                    { time: "10:45 - 12:15", duration: "1h 30m", tags: ["project:website", "development"], earnings: 112.50 },
                                    { time: "13:00 - 15:30", duration: "2h 30m", tags: ["project:mobile", "coding"], earnings: 212.50 },
                                    { time: "16:00 - 17:00", duration: "1h 0m", tags: ["project:website", "testing"], earnings: 75.00 }
                                ]

                                Rectangle {
                                    width: parent.width
                                    height: 70
                                    color: "#f8f9fa"
                                    radius: 8
                                    border.color: Material.dividerColor

                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 16

                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 2

                                            Text {
                                                text: modelData.time
                                                font.pixelSize: 12
                                                font.weight: Font.Bold
                                            }

                                            Text {
                                                text: modelData.duration
                                                font.pixelSize: 11
                                                color: Material.secondaryTextColor
                                            }

                                            Text {
                                                text: modelData.tags.join(", ")
                                                font.pixelSize: 10
                                                color: Material.accent
                                            }
                                        }

                                        Rectangle {
                                            anchors.verticalCenter: parent.verticalCenter
                                            Layout.fillWidth: true
                                            height: 30
                                            color: Material.color(Material.Green, 100)
                                            radius: 4

                                            Text {
                                                anchors.centerIn: parent
                                                text: "$" + modelData.earnings.toFixed(2)
                                                font.pixelSize: 14
                                                font.weight: Font.Bold
                                                color: Material.color(Material.Green)
                                            }
                                        }
                                    }
                                }
                            }

                            // Current running timer
                            Rectangle {
                                width: parent.width
                                height: 70
                                color: Material.color(Material.Blue, 50)
                                radius: 8
                                border.color: Material.color(Material.Blue)
                                visible: timew.timerActive

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 16

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 2

                                            Text {
                                                text: "Now - Running"
                                                font.pixelSize: 12
                                                font.weight: Font.Bold
                                                color: Material.color(Material.Blue)
                                            }

                                            Text {
                                                text: timew.elapsedTime
                                                font.pixelSize: 11
                                                color: Material.color(Material.Blue)
                                            }

                                            Text {
                                                text: timew.currentTags.join(", ")
                                                font.pixelSize: 10
                                                color: Material.accent
                                            }
                                        }

                                        Rectangle {
                                            anchors.verticalCenter: parent.verticalCenter
                                            Layout.fillWidth: true
                                            height: 30
                                            color: Material.color(Material.Blue, 100)
                                            radius: 4

                                            Text {
                                                anchors.centerIn: parent
                                                text: "Running..."
                                                font.pixelSize: 14
                                                font.weight: Font.Bold
                                                color: Material.color(Material.Blue)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Export and reports
                    Row {
                        Layout.fillWidth: true
                        spacing: 10

                        Button {
                            text: "Export Timesheet"
                            Layout.fillWidth: true
                        }

                        Button {
                            text: "Generate Report"
                            Layout.fillWidth: true
                        }

                        Button {
                            text: "Send Invoice"
                            Layout.fillWidth: true
                            highlighted: true
                        }
                    }
                }
            }
        }
    }
}
```

## Advanced Patterns

### Multi-User Time Tracking

Example for team or multi-user scenarios:

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import qs_timew 2.0

ApplicationWindow {
    visible: true
    width: 900
    height: 600
    title: "Team Time Tracker"

    property var currentUser: "John Doe"
    property var users: [
        { name: "John Doe", tags: ["user:john"], color: Material.Blue },
        { name: "Jane Smith", tags: ["user:jane"], color: Material.Purple },
        { name: "Bob Wilson", tags: ["user:bob"], color: Material.Green }
    ]

    // Multiple integration components for different users
    property var timewInstances: ({})

    Component.onCompleted: {
        // Initialize instances for each user
        for (let user of users) {
            const component = Qt.createComponent("IntegrationComponent.qml")
            const instance = component.createObject(parent)
            timewInstances[user.name] = instance
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // User selector
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: Material.backgroundColor
            radius: 8
            border.color: Material.dividerColor

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                Text {
                    text: "Current User:"
                    font.pixelSize: 16
                    font.weight: Font.Bold
                }

                ComboBox {
                    model: users.map(user => user.name)
                    currentIndex: 0
                    Layout.preferredWidth: 150

                    onCurrentValueChanged: {
                        currentUser = currentValue
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    color: users.find(u => u.name === currentUser).color
                    radius: 18
                    opacity: 0.2
                }

                // Current user's timer widget
                Rectangle {
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 36
                    color: Material.backgroundColor
                    radius: 18
                    border.color: users.find(u => u.name === currentUser).color
                    border.width: 2

                    TimewarriorWidget {
                        anchors.fill: parent
                        anchors.margins: 4

                        // Custom styling for current user
                        accentColor: users.find(u => u.name === currentUser).color
                    }
                }
            }
        }

        // Team overview
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 20

            // Current user details
            Rectangle {
                Layout.preferredWidth: 300
                Layout.fillHeight: true
                color: Material.backgroundColor
                radius: 8
                border.color: Material.dividerColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Text {
                        text: currentUser + " - Time Tracking"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                    }

                    // Timer controls
                    GroupBox {
                        Layout.fillWidth: true
                        title: "Timer Controls"

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 8

                            TextField {
                                id: tagInput
                                Layout.fillWidth: true
                                placeholderText: "Enter tags..."

                                Keys.onReturnPressed: startButton.clicked()
                            }

                            Button {
                                id: startButton
                                Layout.fillWidth: true
                                text: "Start Timer"

                                onClicked: {
                                    const userTags = users.find(u => u.name === currentUser).tags
                                    const customTags = tagInput.text.trim().split(/\s+/).filter(t => t.length > 0)
                                    const allTags = [...userTags, ...customTags]

                                    timewInstances[currentUser].startTimer(allTags)
                                    tagInput.text = ""
                                }
                            }

                            Button {
                                Layout.fillWidth: true
                                text: "Stop Timer"
                                highlighted: true
                                enabled: timewInstances[currentUser].timerActive

                                onClicked: timewInstances[currentUser].stopTimer()
                            }
                        }
                    }

                    // Current status
                    GroupBox {
                        Layout.fillWidth: true
                        title: "Current Status"

                        Column {
                            anchors.fill: parent
                            spacing: 8

                            Text {
                                text: "Active: " + (timewInstances[currentUser].timerActive ? "Yes" : "No")
                            }

                            Text {
                                text: "Elapsed: " + timewInstances[currentUser].elapsedTime
                            }

                            Text {
                                text: "Tags: " + timewInstances[currentUser].currentTags.join(", ")
                                font.pixelSize: 10
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    Layout.fillHeight: true
                }
            }

            // Team overview
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Material.backgroundColor
                radius: 8
                border.color: Material.dividerColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Text {
                        text: "Team Overview"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                    }

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Column {
                            width: parent.width
                            spacing: 12

                            Repeater {
                                model: users

                                Rectangle {
                                    width: parent.width
                                    height: 80
                                    color: modelData.name === currentUser
                                        ? Material.color(modelData.color, 100)
                                        : "#f8f9fa"
                                    radius: 8
                                    border.color: modelData.color
                                    border.width: modelData.name === currentUser ? 2 : 1

                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: 16
                                        spacing: 16

                                        // User info
                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 4

                                            Text {
                                                text: modelData.name
                                                font.pixelSize: 16
                                                font.weight: Font.Bold
                                            }

                                            Text {
                                                text: modelData.tags.join(", ")
                                                font.pixelSize: 12
                                                color: Material.secondaryTextColor
                                            }
                                        }

                                        // Timer status
                                        Rectangle {
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: 120
                                            height: 40
                                            color: timewInstances[modelData.name].timerActive
                                                ? Material.color(Material.Green, 100)
                                                : Material.color(Material.Grey, 100)
                                            radius: 6
                                            border.color: timewInstances[modelData.name].timerActive
                                                ? Material.color(Material.Green)
                                                : Material.color(Material.Grey)

                                            Column {
                                                anchors.centerIn: parent
                                                spacing: 2

                                                Text {
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    text: timewInstances[modelData.name].timerActive ? "Active" : "Inactive"
                                                    font.pixelSize: 12
                                                    font.weight: Font.Bold
                                                }

                                                Text {
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    text: timewInstances[modelData.name].elapsedTime
                                                    font.pixelSize: 10
                                                    font.family: "monospace"
                                                }
                                            }
                                        }

                                        // Current tags
                                        Rectangle {
                                            anchors.verticalCenter: parent.verticalCenter
                                            Layout.fillWidth: true
                                            height: 40
                                            color: "#f0f0f0"
                                            radius: 6

                                            Text {
                                                anchors.centerIn: parent
                                                text: timewInstances[modelData.name].currentTags.length > 0
                                                    ? timewInstances[modelData.name].currentTags.join(", ")
                                                    : "No active timer"
                                                font.pixelSize: 11
                                                horizontalAlignment: Text.AlignHCenter
                                                wrapMode: Text.WordWrap
                                                width: parent.width - 16
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
```

## Integration Examples

### Qt Quick Controls 2 Integration

Modern integration with Qt Quick Controls 2:

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import qs_timew 2.0

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "Modern Controls Integration"

    Material.theme: Material.System
    Material.accent: Material.Teal

    IntegrationComponent {
        id: timew

        onTimerStarted: function(tags) {
            showNotification("Timer started", tags.join(", "))
        }

        onTimerStopped: {
            showNotification("Timer stopped", "Session completed")
        }
    }

    function showNotification(title, message) {
        // Custom notification implementation
        console.log("Notification:", title, "-", message)
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: mainPage
    }

    Component {
        id: mainPage

        Pane {
            padding: 20

            ColumnLayout {
                anchors.fill: parent
                spacing: 20

                // Header card
                Card {
                    Layout.fillWidth: true

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 16

                        RowLayout {
                            Text {
                                text: "Time Tracker"
                                font.pixelSize: 24
                                font.weight: Font.Bold
                                Layout.fillWidth: true
                            }

                            Chip {
                                text: timew.timerActive ? "Active" : "Inactive"
                                highlighted: timew.timerActive
                            }
                        }

                        // Timer display card
                        Card {
                            Layout.fillWidth: true
                            Material.elevation: timew.timerActive ? 8 : 2

                            Row {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 16

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 4

                                        Text {
                                            text: timew.timerActive ? "Current Session" : "No Active Session"
                                            font.pixelSize: 18
                                            font.weight: Font.Medium
                                        }

                                        Text {
                                            text: timew.elapsedTime
                                            font.pixelSize: 32
                                            font.family: "monospace"
                                            font.weight: Font.Bold
                                            color: Material.accent
                                        }

                                        Text {
                                            text: timew.currentTags.join(" ")
                                            font.pixelSize: 14
                                            color: Material.secondaryTextColor
                                        }
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 8

                                        Button {
                                            text: timew.timerActive ? "Stop" : "Start"
                                            highlighted: timew.timerActive
                                            onClicked: timew.timerActive ? timew.stopTimer() : timew.startTimer(["work"])
                                        }

                                        Button {
                                            text: "Edit Tags"
                                            enabled: timew.timerActive
                                            flat: true
                                            onClicked: stackView.push(tagEditPage)
                                        }
                                    }
                                }
                            }
                        }

                        // Quick actions
                        Row {
                            spacing: 12

                            Repeater {
                                model: [
                                    { label: "Focus", tags: ["focus", "deep-work"], icon: "⏰" },
                                    { label: "Meeting", tags: ["meeting"], icon: "👥" },
                                    { label: "Break", tags: ["break"], icon: "☕" },
                                    { label: "Learning", tags: ["learning", "study"], icon: "📚" }
                                ]

                                Card {
                                    width: 120
                                    height: 80
                                    Material.elevation: 2

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 4

                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: modelData.icon
                                            font.pixelSize: 24
                                        }

                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: modelData.label
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: timew.startTimer(modelData.tags)
                                    }
                                }
                            }
                        }

                        // Recent activity
                        Card {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 12

                                Text {
                                    text: "Recent Activity"
                                    font.pixelSize: 16
                                    font.weight: Font.Bold
                                }

                                ScrollView {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    Column {
                                        width: parent.width
                                        spacing: 8

                                        Repeater {
                                            model: [
                                                { time: "2 hours ago", tags: ["focus", "deep-work"], duration: "2h 15m" },
                                                { time: "4 hours ago", tags: ["meeting", "team"], duration: "1h 0m" },
                                                { time: "Yesterday", tags: ["learning", "qml"], duration: "3h 30m" }
                                            ]

                                            ListItem {
                                                width: parent.width

                                                Column {
                                                    spacing: 2

                                                    Text {
                                                        text: modelData.tags.join(", ")
                                                        font.pixelSize: 14
                                                        font.weight: Font.Medium
                                                    }

                                                    Text {
                                                        text: modelData.time + " • " + modelData.duration
                                                        font.pixelSize: 12
                                                        color: Material.secondaryTextColor
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: tagEditPage

        Pane {
            padding: 20

            ColumnLayout {
                anchors.fill: parent
                spacing: 20

                RowLayout {
                    ToolButton {
                        text: "←"
                        onClicked: stackView.pop()
                    }

                    Text {
                        text: "Edit Timer Tags"
                        font.pixelSize: 20
                        font.weight: Font.Bold
                        Layout.fillWidth: true
                    }
                }

                Card {
                    Layout.fillWidth: true

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 16

                        Text {
                            text: "Current Tags"
                            font.pixelSize: 16
                            font.weight: Font.Medium
                        }

                        Flow {
                            Layout.fillWidth: true
                            spacing: 8

                            Repeater {
                                model: timew.currentTags

                                Chip {
                                    text: modelData
                                    closeIcon.visible: false
                                }
                            }
                        }

                        TextField {
                            id: tagEditInput
                            Layout.fillWidth: true
                            placeholderText: "Enter new tags..."
                            text: timew.currentTags.join(" ")

                            Keys.onReturnPressed: updateButton.clicked()
                        }

                        Row {
                            spacing: 12

                            Button {
                                id: updateButton
                                text: "Update Tags"
                                highlighted: true
                                onClicked: {
                                    const validation = timew.validateTagInput(tagEditInput.text)
                                    if (validation.isValid) {
                                        timew.updateTags(validation.tags)
                                        stackView.pop()
                                    }
                                }
                            }

                            Button {
                                text: "Cancel"
                                flat: true
                                onClicked: stackView.pop()
                            }
                        }
                    }
                }
            }
        }
    }
}
```

This comprehensive set of usage examples demonstrates the flexibility and power of the qs-timew module across various scenarios and integration patterns. Each example can be adapted and modified to fit specific application requirements and user workflows.