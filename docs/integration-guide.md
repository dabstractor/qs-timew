# Integration Guide

Comprehensive guide for integrating qs-timew into various types of Qt Quick applications and development environments.

## Table of Contents

- [Integration Overview](#integration-overview)
- [Integration Methods](#integration-methods)
- [Application Types](#application-types)
- [Framework Integration](#framework-integration)
- [Build System Integration](#build-system-integration)
- [Deployment Strategies](#deployment-strategies)
- [Best Practices](#best-practices)
- [Performance Optimization](#performance-optimization)
- [Security Considerations](#security-considerations)
- [Testing Integration](#testing-integration)

## Integration Overview

### Integration Levels

qs-timew supports multiple levels of integration to suit different use cases:

1. **Widget-Only Integration** - Drop-in UI component
2. **Service-Level Integration** - Direct API access
3. **High-Level Integration** - Simplified API wrapper
4. **Custom Integration** - Full control and customization

### Integration Decision Matrix

| Integration Type | Best For | Complexity | Customization |
|------------------|-----------|------------|---------------|
| Widget-Only | Quick prototypes, simple apps | Low | Minimal |
| Service-Level | Custom UI, advanced features | Medium | High |
| High-Level | Standard applications | Low | Medium |
| Custom | Specialized requirements | High | Complete |

## Integration Methods

### Method 1: QML Import Path

Set up the module path for QML imports:

```bash
# System-wide installation
sudo ln -s /path/to/qs-timew /usr/lib/qt6/qml/qs_timew

# User-level installation
export QML2_IMPORT_PATH=$QML2_IMPORT_PATH:/path/to/qs-timew
echo 'export QML2_IMPORT_PATH=$QML2_IMPORT_PATH:/path/to/qs-timew' >> ~/.bashrc

# Project-level installation
qmlscene -I /path/to/qs-timew app.qml
```

**Advantages:**
- Clean import statements
- Standard QML module behavior
- Easy for multiple projects

**Disadvantages:**
- Requires path configuration
- System-wide changes need admin access

### Method 2: Relative Path Import

Use relative paths for project-specific integration:

```qml
import "../libs/qs-timew"

ApplicationWindow {
    TimewarriorWidget {
        anchors.fill: parent
    }
}
```

**Advantages:**
- No system configuration required
- Portable projects
- Version control friendly

**Disadvantages:**
- Messy import statements
- Path management complexity

### Method 3: Git Submodule

Include qs-timew as a git submodule:

```bash
# Add submodule
git submodule add https://github.com/dustin-s/qs-timew.git libs/qs-timew

# Initialize submodule
git submodule update --init --recursive

# Use in QML
import "./libs/qs-timew"
```

**Advantages:**
- Version control integration
- Dependency management
- Easy updates

**Disadvantages:**
- Git complexity
- Submodule management overhead

### Method 4: Copy to Project

Copy module files directly to project:

```bash
# Copy source files
cp -r /path/to/qs-timew/src ./qs-timew

# Use in QML
import "./qs-timew"
```

**Advantages:**
- Simple setup
- Full control over files
- Easy customization

**Disadvantages:**
- Manual updates required
- Code duplication

## Application Types

### Desktop Applications

#### Standard Qt Quick Application

```qml
// main.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import qs_timew 2.0

ApplicationWindow {
    visible: true
    width: 1024
    height: 768
    title: "My Desktop App"

    Material.theme: Material.System
    Material.accent: Material.Blue

    // Integration component for easy API access
    IntegrationComponent {
        id: timew

        onTimerStarted: function(tags) {
            statusBar.showMessage("Timer started: " + tags.join(", "))
        }

        onTimerStopped: {
            statusBar.showMessage("Timer stopped")
        }
    }

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 16

            Text {
                text: "My Application"
                font.pixelSize: 18
                font.weight: Font.Bold
                Layout.fillWidth: true
            }

            // Integrated timewarrior widget
            Rectangle {
                Layout.preferredWidth: 200
                Layout.preferredHeight: 36
                color: Material.backgroundColor
                radius: 18
                border.color: Material.accent

                TimewarriorWidget {
                    anchors.fill: parent
                    anchors.margins: 4
                }
            }
        }
    }

    // Main content area
    Rectangle {
        anchors.fill: parent
        color: Material.backgroundColor

        // Your application content here
        Text {
            anchors.centerIn: parent
            text: "Application Content"
            font.pixelSize: 24
        }
    }

    footer: StatusBar {
        id: statusBar
    }
}
```

#### CMake Integration

```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 3.16)
project(MyDesktopApp)

find_package(Qt6 REQUIRED COMPONENTS Core Quick QuickControls2)

# Add qs-timew module
set(QS_TIMEW_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../qs-timew")
set(QML_IMPORT_PATH "${QML_IMPORT_PATH}:${QS_TIMEW_DIR}" CACHE STRING "")

qt_add_executable(MyDesktopApp
    main.cpp
    qml.qrc
)

qt_add_qml_module(MyDesktopApp
    URI MyDesktopApp
    VERSION 1.0
    QML_FILES
        main.qml
    IMPORT_PATH
        ${QS_TIMEW_DIR}
)

# Set environment variable for QML imports
set_target_properties(MyDesktopApp PROPERTIES
    QT_QML_IMPORT_PATH ${QS_TIMEW_DIR}
)
```

### Mobile Applications

#### Mobile-Optimized Interface

```qml
// MobileMain.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import qs_timew 2.0

ApplicationWindow {
    id: window
    visible: true
    width: 360
    height: 640
    title: "Mobile Time Tracker"

    Material.theme: Material.System
    Material.accent: Material.Teal

    // Mobile-optimized integration
    IntegrationComponent {
        id: timew

        onTimerStarted: function(tags) {
            // Mobile notification
            mobileNotification.show("Timer Started", tags.join(", "))
        }

        onTimerStopped: {
            mobileNotification.show("Timer Stopped", "Session completed")
        }
    }

    // Mobile notification service
    QtObject {
        id: mobileNotification

        function show(title, message) {
            // Platform-specific notification implementation
            console.log("Mobile Notification:", title, "-", message)
        }
    }

    Page {
        header: ToolBar {
            Material.background: Material.primary

            Label {
                anchors.centerIn: parent
                text: "Time Tracker"
                color: "white"
                font.pixelSize: 18
                font.weight: Font.Bold
            }
        }

        Flickable {
            anchors.fill: parent
            contentHeight: column.height

            Column {
                id: column
                width: parent.width
                spacing: 16
                padding: 16

                // Timer status card
                Card {
                    width: parent.width
                    height: 120

                    Column {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: timew.timerActive ? "Timer Active" : "No Timer"
                            font.pixelSize: 16
                            font.weight: Font.Bold
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: timew.elapsedTime
                            font.pixelSize: 32
                            font.family: "monospace"
                            font.weight: Font.Bold
                            color: Material.accent
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: timew.currentTags.join(" ")
                            font.pixelSize: 12
                            color: Material.secondaryTextColor
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (timew.timerActive) {
                                timew.stopTimer()
                            } else {
                                timerPage.open()
                            }
                        }
                    }
                }

                // Quick start buttons
                GridLayout {
                    width: parent.width
                    columns: 2
                    columnSpacing: 8
                    rowSpacing: 8

                    Repeater {
                        model: [
                            { label: "Work", tags: ["work"], color: Material.Blue },
                            { label: "Meeting", tags: ["meeting"], color: Material.Purple },
                            { label: "Break", tags: ["break"], color: Material.Green },
                            { label: "Learning", tags: ["learning"], color: Material.Orange }
                        ]

                        Card {
                            width: (parent.width - parent.columnSpacing) / 2
                            height: 80
                            Material.elevation: 2

                            Column {
                                anchors.centerIn: parent
                                spacing: 4

                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 12
                                    color: modelData.color
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.label
                                    font.pixelSize: 14
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
                    width: parent.width
                    height: 200

                    Column {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        Text {
                            text: "Recent Activity"
                            font.pixelSize: 16
                            font.weight: Font.Bold
                        }

                        ScrollView {
                            width: parent.width
                            height: 120

                            Column {
                                width: parent.width
                                spacing: 8

                                Repeater {
                                    model: [
                                        { tags: ["work", "project"], time: "2 hours ago", duration: "1h 30m" },
                                        { tags: ["meeting"], time: "4 hours ago", duration: "45m" },
                                        { tags: ["break"], time: "6 hours ago", duration: "15m" }
                                    ]

                                    Rectangle {
                                        width: parent.width
                                        height: 40
                                        color: "#f5f5f5"
                                        radius: 4

                                        Row {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            spacing: 8

                                            Column {
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: 2

                                                Text {
                                                    text: modelData.tags.join(", ")
                                                    font.pixelSize: 12
                                                    font.weight: Font.Medium
                                                }

                                                Text {
                                                    text: modelData.time + " • " + modelData.duration
                                                    font.pixelSize: 10
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

    // Timer input page
    Page {
        id: timerPage
        visible: false

        header: ToolBar {
            RowLayout {
                anchors.fill: parent
                anchors.margins: 8

                ToolButton {
                    text: "←"
                    onClicked: timerPage.close()
                }

                Label {
                    text: "Start Timer"
                    Layout.fillWidth: true
                }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            TextField {
                id: tagInput
                Layout.fillWidth: true
                placeholderText: "Enter tags..."
                font.pixelSize: 16

                Keys.onReturnPressed: startButton.clicked()
            }

            Button {
                id: startButton
                Layout.fillWidth: true
                text: "Start Timer"
                highlighted: true
                font.pixelSize: 16

                onClicked: {
                    if (tagInput.text.trim().length > 0) {
                        const validation = timew.validateTagInput(tagInput.text)
                        if (validation.isValid) {
                            timew.startTimer(validation.tags)
                            tagInput.text = ""
                            timerPage.close()
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }

        function open() {
            visible = true
            tagInput.focus = true
            tagInput.selectAll()
        }

        function close() {
            visible = false
        }
    }
}
```

### Embedded Systems

#### Touch Interface for Kiosks

```qml
// KioskInterface.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import qs_timew 2.0

ApplicationWindow {
    visible: true
    width: 800
    height: 480
    title: "Kiosk Time Tracker"

    // Kiosk-optimized settings
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    Material.theme: Material.System
    Material.accent: Material.Indigo

    IntegrationComponent {
        id: timew

        onTimerStarted: function(tags) {
            // Kiosk notification system
            kioskDisplay.showNotification("Timer Started", tags.join(", "))
        }

        onTimerStopped: {
            kioskDisplay.showNotification("Timer Stopped", "Session completed")
        }
    }

    // Kiosk display system
    QtObject {
        id: kioskDisplay

        function showNotification(title, message) {
            // Implement kiosk-specific notification
            notificationPopup.title = title
            notificationPopup.message = message
            notificationPopup.open()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Material.backgroundColor

        // Large touch targets for kiosk use
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 30

            Text {
                text: "Time Tracking Kiosk"
                font.pixelSize: 32
                font.weight: Font.Bold
                Layout.alignment: Qt.AlignHCenter
            }

            // Timer display
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: timew.timerActive ? Material.color(Material.Green, 100) : Material.color(Material.Grey, 100)
                radius: 16
                border.color: timew.timerActive ? Material.color(Material.Green) : Material.color(Material.Grey)
                border.width: 4

                Column {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: timew.timerActive ? "TIMER ACTIVE" : "NO TIMER"
                        font.pixelSize: 24
                        font.weight: Font.Bold
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: timew.elapsedTime
                        font.pixelSize: 48
                        font.family: "monospace"
                        font.weight: Font.Bold
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: timew.currentTags.join(" ")
                        font.pixelSize: 18
                        color: Material.secondaryTextColor
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (timew.timerActive) {
                            timew.stopTimer()
                        } else {
                            categorySelection.open()
                        }
                    }
                }
            }

            // Quick category buttons
            GridLayout {
                Layout.fillWidth: true
                columns: 3
                columnSpacing: 20
                rowSpacing: 20

                Repeater {
                    model: [
                        { label: "WORK", tags: ["work"], color: Material.Blue },
                        { label: "MEETING", tags: ["meeting"], color: Material.Purple },
                        { label: "BREAK", tags: ["break"], color: Material.Green },
                        { label: "TRAINING", tags: ["training"], color: Material.Orange },
                        { label: "PROJECT", tags: ["project"], color: Material.Teal },
                        { label: "OTHER", tags: ["other"], color: Material.Grey }
                    ]

                    Rectangle {
                        width: (parent.width - 40) / 3
                        height: 100
                        color: modelData.color
                        radius: 12
                        border.width: 2
                        border.color: "white"

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            color: "white"
                            font.pixelSize: 18
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                timew.startTimer(modelData.tags)
                            }
                        }
                    }
                }
            }

            // Instructions
            Text {
                text: "Tap the timer or select a category to start tracking time"
                font.pixelSize: 16
                color: Material.secondaryTextColor
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                width: parent.width
            }
        }
    }

    // Category selection popup
    Popup {
        id: categorySelection
        width: 600
        height: 400
        modal: true
        focus: true

        Rectangle {
            anchors.fill: parent
            color: Material.backgroundColor
            radius: 8

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                Text {
                    text: "Select Category"
                    font.pixelSize: 24
                    font.weight: Font.Bold
                    Layout.alignment: Qt.AlignHCenter
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    GridLayout {
                        width: parent.width
                        columns: 2
                        columnSpacing: 15
                        rowSpacing: 15

                        Repeater {
                            model: [
                                { label: "Work", tags: ["work"], icon: "💼" },
                                { label: "Meeting", tags: ["meeting"], icon: "👥" },
                                { label: "Break", tags: ["break"], icon: "☕" },
                                { label: "Training", tags: ["training"], icon: "📚" },
                                { label: "Project", tags: ["project"], icon: "📋" },
                                { label: "Research", tags: ["research"], icon: "🔍" },
                                { label: "Development", tags: ["development"], icon: "💻" },
                                { label: "Other", tags: ["other"], icon: "📌" }
                            ]

                            Rectangle {
                                width: (parent.width - 15) / 2
                                height: 80
                                color: "#f5f5f5"
                                radius: 8
                                border.width: 2
                                border.color: Material.accent

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 12

                                    Text {
                                        text: modelData.icon
                                        font.pixelSize: 32
                                    }

                                    Text {
                                        text: modelData.label
                                        font.pixelSize: 18
                                        font.weight: Font.Medium
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        timew.startTimer(modelData.tags)
                                        categorySelection.close()
                                    }
                                }
                            }
                        }
                    }
                }

                Button {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Cancel"
                    onClicked: categorySelection.close()
                }
            }
        }
    }

    // Notification popup
    Popup {
        id: notificationPopup
        width: 400
        height: 150
        modal: true
        closePolicy: Popup.CloseOnTimeout | Popup.CloseOnEscape
        timeout: 3000

        property string title: ""
        property string message: ""

        Rectangle {
            anchors.fill: parent
            color: Material.primary
            radius: 8

            Column {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: notificationPopup.title
                    color: "white"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: notificationPopup.message
                    color: "white"
                    font.pixelSize: 14
                }
            }
        }
    }
}
```

## Framework Integration

### Qt Quick Controls 2

Modern integration with Qt Quick Controls 2 components:

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
    title: "Modern Qt Application"

    Material.theme: Material.System
    Material.accent: Material.Blue

    // High-level integration
    IntegrationComponent {
        id: timew

        onTimerStarted: function(tags) {
            drawer.open()
            timerStartedNotification.show()
        }

        onTimerStopped: {
            timerStoppedNotification.show()
        }
    }

    // Navigation drawer
    Drawer {
        id: drawer
        width: 300
        height: parent.height

        Pane {
            padding: 0

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    color: Material.primary

                    Column {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.margins: 16
                        spacing: 8

                        Text {
                            text: "Time Tracker"
                            color: "white"
                            font.pixelSize: 20
                            font.weight: Font.Bold
                        }

                        Text {
                            text: timew.timerActive ? "Timer Active" : "No Timer"
                            color: "white"
                            font.pixelSize: 14
                            opacity: 0.8
                        }
                    }
                }

                // Quick actions
                Pane {
                    Layout.fillWidth: true

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 8

                        Label {
                            text: "Quick Actions"
                            font.pixelSize: 16
                            font.weight: Font.Bold
                        }

                        Button {
                            Layout.fillWidth: true
                            text: timew.timerActive ? "Stop Timer" : "Start Work"
                            highlighted: timew.timerActive
                            onClicked: timew.timerActive ? timew.stopTimer() : timew.startTimer(["work"])
                        }

                        Button {
                            Layout.fillWidth: true
                            text: "Start Meeting"
                            onClicked: timew.startTimer(["meeting"])
                        }

                        Button {
                            Layout.fillWidth: true
                            text: "Take Break"
                            onClicked: timew.startTimer(["break"])
                        }
                    }
                }

                // Timer status
                Pane {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12

                        Label {
                            text: "Timer Status"
                            font.pixelSize: 16
                            font.weight: Font.Bold
                        }

                        Card {
                            Layout.fillWidth: true

                            Column {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 8

                                Row {
                                    spacing: 8

                                    Rectangle {
                                        width: 12
                                        height: 12
                                        radius: 6
                                        color: timew.timerActive ? Material.color(Material.Green) : Material.color(Material.Grey)
                                    }

                                    Text {
                                        text: timew.timerActive ? "Active" : "Inactive"
                                        font.pixelSize: 14
                                        font.weight: Font.Medium
                                    }
                                }

                                Text {
                                    text: timew.elapsedTime
                                    font.pixelSize: 18
                                    font.family: "monospace"
                                }

                                Text {
                                    text: timew.currentTags.join(", ")
                                    font.pixelSize: 12
                                    color: Material.secondaryTextColor
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                        }
                    }
                }
            }
        }
    }

    // Main content
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

                // Header with timer widget
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20

                    Text {
                        text: "Dashboard"
                        font.pixelSize: 28
                        font.weight: Font.Bold
                        Layout.fillWidth: true
                    }

                    // Compact timer widget
                    Rectangle {
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 40
                        color: Material.backgroundColor
                        radius: 20
                        border.color: Material.accent
                        border.width: 1

                        TimewarriorWidget {
                            anchors.fill: parent
                            anchors.margins: 4
                        }
                    }
                }

                // Quick stats
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20

                    Repeater {
                        model: [
                            { label: "Focus Time", value: "4h 32m", color: Material.Blue },
                            { label: "Meetings", value: "2h 15m", color: Material.Purple },
                            { label: "Breaks", value: "45m", color: Material.Green },
                            { label: "Total", value: "7h 32m", color: Material.Orange }
                        ]

                        Card {
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 100
                            Layout.fillWidth: true

                            Column {
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.label
                                    font.pixelSize: 12
                                    color: Material.secondaryTextColor
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.value
                                    font.pixelSize: 20
                                    font.weight: Font.Bold
                                    color: modelData.color
                                }
                            }
                        }
                    }
                }

                // Main content grid
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 2
                    columnSpacing: 20
                    rowSpacing: 20

                    // Timer details
                    Card {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 16

                            Text {
                                text: "Timer Details"
                                font.pixelSize: 18
                                font.weight: Font.Bold
                            }

                            ScrollView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                Column {
                                    width: parent.width
                                    spacing: 12

                                    Rectangle {
                                        width: parent.width
                                        height: 60
                                        color: timew.timerActive ? Material.color(Material.Green, 100) : Material.color(Material.Grey, 100)
                                        radius: 8

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 4

                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: timew.timerActive ? "Timer Running" : "No Timer Active"
                                                font.pixelSize: 14
                                                font.weight: Font.Medium
                                            }

                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: timew.elapsedTime
                                                font.pixelSize: 16
                                                font.family: "monospace"
                                            }

                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: timew.currentTags.join(" ")
                                                font.pixelSize: 10
                                                color: Material.secondaryTextColor
                                            }
                                        }
                                    }

                                    // Recent entries would go here
                                    Repeater {
                                        model: [
                                            { tags: ["work", "project"], duration: "2h 15m", time: "10:00 AM" },
                                            { tags: ["meeting"], duration: "1h 0m", time: "8:00 AM" }
                                        ]

                                        Rectangle {
                                            width: parent.width
                                            height: 50
                                            color: "#f5f5f5"
                                            radius: 4

                                            Row {
                                                anchors.fill: parent
                                                anchors.margins: 12
                                                spacing: 12

                                                Column {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    spacing: 2

                                                    Text {
                                                        text: modelData.tags.join(", ")
                                                        font.pixelSize: 12
                                                        font.weight: Font.Medium
                                                    }

                                                    Text {
                                                        text: modelData.time + " • " + modelData.duration
                                                        font.pixelSize: 10
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

                    // Quick actions
                    Card {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 16

                            Text {
                                text: "Quick Actions"
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
                                            model: [
                                                { label: "Start Focus Session", tags: ["focus", "deep-work"], icon: "🎯" },
                                                { label: "Join Meeting", tags: ["meeting"], icon: "📞" },
                                                { label: "Take Break", tags: ["break"], icon: "☕" },
                                                { label: "Code Review", tags: ["review", "coding"], icon: "👀" },
                                                { label: "Learning Time", tags: ["learning", "study"], icon: "📚" },
                                                { label: "Planning", tags: ["planning"], icon: "📋" }
                                            ]

                                            Rectangle {
                                                width: parent.width
                                                height: 60
                                                color: "#f8f9fa"
                                                radius: 8
                                                border.width: 1
                                                border.color: Material.dividerColor

                                                Row {
                                                    anchors.fill: parent
                                                    anchors.margins: 12
                                                    spacing: 12

                                                    Text {
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        text: modelData.icon
                                                        font.pixelSize: 24
                                                    }

                                                    Text {
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        text: modelData.label
                                                        font.pixelSize: 14
                                                        font.weight: Font.Medium
                                                    }

                                                    Item {
                                                        Layout.fillWidth: true
                                                    }

                                                    Text {
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        text: ">"
                                                        font.pixelSize: 18
                                                        color: Material.secondaryTextColor
                                                    }
                                                }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    onClicked: timew.startTimer(modelData.tags)
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

    // Notifications
    Toast {
        id: timerStartedNotification
        text: "Timer started successfully"
        duration: 2000
    }

    Toast {
        id: timerStoppedNotification
        text: "Timer stopped"
        duration: 2000
    }
}
```

## Build System Integration

### CMake Integration

```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 3.16)
project(MyQsTimewApp VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Quick QuickControls2)

# Add qs-timew as dependency
option(QS_TIMEW_PATH "Path to qs-timew module" "${CMAKE_CURRENT_SOURCE_DIR}/../qs-timew")

# Set QML import path
set(QML_IMPORT_PATH "${QML_IMPORT_PATH}:${QS_TIMEW_DIR}" CACHE STRING "")

qt_standard_project_setup()

qt_add_executable(MyQsTimewApp
    main.cpp
)

qt_add_qml_module(MyQsTimewApp
    URI MyQsTimewApp
    VERSION 1.0
    QML_FILES
        main.qml
        components/
    IMPORT_PATH
        ${QS_TIMEW_PATH}
    SOURCES
        app.h app.cpp
)

# Copy qs-timew module to build directory
add_custom_command(TARGET MyQsTimewApp POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${QS_TIMEW_PATH}/src
        $<TARGET_FILE_DIR:MyQsTimewApp>/qs_timew
)

# Set runtime environment
set_target_properties(MyQsTimewApp PROPERTIES
    QT_QML_IMPORT_PATH ${QS_TIMEW_PATH}
)
```

### QMake Integration

```pro
# MyQsTimewApp.pro
QT += quick quickcontrols2

CONFIG += c++17

SOURCES += \
        main.cpp

RESOURCES += qml.qrc

# qs-timew integration
QS_TIMEW_PATH = ../qs-timew

# Add QML import path
QML_IMPORT_PATH += $$QS_TIMEW_PATH

# Copy qs-timew module to build directory
qs_timew_files.files = $$QS_TIMEW_PATH/src/*
qs_timew_files.path = $$OUT_PWD/qs_timew
INSTALLS += qs_timew_files

# Set environment variable
QMAKE_POST_LINK += export QML2_IMPORT_PATH=$$QML2_IMPORT_PATH:$$QS_TIMEW_PATH

# Additional import path for qmlscene
QMAKE_EXTRA_TARGETS += run_qmlscene
run_qmlscene.target = run_qmlscene
run_qmlscene.commands = qmlscene -I $$QS_TIMEW_PATH $$PWD/main.qml
```

### Conan Integration (C++ Projects)

```python
# conanfile.py
from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, CMakeDeps, cmake_layout

class QsTimewConan(ConanFile):
    name = "my-qstimew-app"
    version = "1.0.0"
    settings = "os", "compiler", "build_type", "arch"

    def requirements(self):
        self.requires("qt/6.5.0")
        # Add qs-timew as local dependency

    def layout(self):
        cmake_layout(self)

    def generate(self):
        deps = CMakeDeps(self)
        deps.generate()

        tc = CMakeToolchain(self)
        tc.variables["QS_TIMEW_PATH"] = self.conf.get("user.qstimew:path")
        tc.generate()

    def build_requirements(self):
        self.tool_requires("cmake/[>=3.16]")
```

## Deployment Strategies

### Static Deployment

Deploy qs-timew as part of your application:

```cmake
# Deployment configuration
install(DIRECTORY ${QS_TIMEW_PATH}/src
        DESTINATION qml/qs_timew
        FILES_MATCHING PATTERN "*.qml"
                         PATTERN "qmldir")

# Create qmldir file
file(WRITE ${CMAKE_BINARY_DIR}/qs_timew/qmldir
     "module qs_timew\nsingleton TimewarriorService 2.0 TimewarriorService.qml\n")
```

### Dynamic Deployment

Deploy qs-timew as a separate module:

```bash
# System-wide installation
sudo cp -r /path/to/qs-timew/src /usr/lib/qt6/qml/qs_timew

# User installation
mkdir -p ~/.local/lib/qt6/qml
cp -r /path/to/qs-timew/src ~/.local/lib/qt6/qml/qs_timew
```

### Container Deployment

Dockerfile for containerized deployment:

```dockerfile
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    qt6-base-dev \
    qt6-declarative-dev \
    timewarrior \
    && rm -rf /var/lib/apt/lists/*

# Copy application and qs-timew
COPY ./app /app
COPY ./qs-timew /opt/qs-timew

# Set environment
ENV QML2_IMPORT_PATH=/opt/qs-timew

# Run application
WORKDIR /app
CMD ["/app/my-qstimew-app"]
```

## Best Practices

### Module Management

1. **Version Control**: Track qs-timew version used in your project
2. **Updates**: Establish update procedures for qs-timew changes
3. **Testing**: Test integration with each qs-timew update

```qml
// Version checking in your application
Component.onCompleted: {
    console.log("qs-timew integration loaded")
    // Verify expected functionality
    if (!TimewarriorService.timewAvailable) {
        console.error("Timewarrior not available")
        // Handle gracefully
    }
}
```

### Error Handling

Implement comprehensive error handling:

```qml
IntegrationComponent {
    id: timew

    onError: function(message) {
        // Log error
        console.error("qs-timew error:", message)

        // Show user-friendly message
        errorDialog.text = "Time tracking error: " + message
        errorDialog.open()

        // Fallback behavior
        fallbackTimer.start()
    }

    // Fallback timer for critical applications
    Timer {
        id: fallbackTimer
        interval: 1000
        repeat: true
        onTriggered: {
            // Implement fallback timing logic
            console.log("Fallback timer running")
        }
    }
}
```

### Performance Optimization

Optimize integration for performance:

```qml
// Use Loader for conditional loading
Loader {
    active: showTimeTracking
    sourceComponent: timeTrackingComponent
}

Component {
    id: timeTrackingComponent

    IntegrationComponent {
        id: timew

        // Optimize property bindings
        property bool isActive: timew.timerActive

        // Use Connections for signal handling
        Connections {
            target: timew
            function onTimerStarted(tags) {
                // Efficient signal handling
            }
        }
    }
}
```

### Resource Management

Manage resources efficiently:

```qml
// Proper cleanup
ApplicationWindow {
    id: window

    IntegrationComponent {
        id: timew
    }

    onClosing: {
        // Cleanup resources
        if (timew.timerActive) {
            // Ask user about stopping timer
            stopTimerDialog.open()
        }
    }
}
```

## Security Considerations

### Input Validation

Always validate user input:

```qml
TextField {
    id: tagInput

    onAccepted: {
        const validation = timew.validateTagInput(text)
        if (!validation.isValid) {
            // Show validation errors
            errorText.text = validation.errors.join(", ")
            return
        }

        // Process valid input
        timew.startTimer(validation.tags)
    }
}
```

### Process Security

Ensure secure process execution:

```qml
// Check timewarrior availability
IntegrationComponent {
    id: timew

    Component.onCompleted: {
        if (!timew.timewAvailable) {
            // Handle missing dependency
            securityAlert.show("Timewarrior not available")
        }
    }
}
```

## Testing Integration

### Unit Testing

Test your integration code:

```qml
// TestIntegration.qml
import QtQuick
import QtTest
import qs_timew 2.0

TestCase {
    name: "IntegrationTest"

    IntegrationComponent {
        id: timew
    }

    function test_timer_start_stop() {
        verify(!timew.timerActive)

        timew.startTimer(["test"])
        wait(100) // Wait for async operation

        verify(timew.timerActive)

        timew.stopTimer()
        wait(100)

        verify(!timew.timerActive)
    }

    function test_tag_validation() {
        const validation = timew.validateTagInput("work project")
        verify(validation.isValid)
        compare(validation.tags, ["work", "project"])
    }
}
```

### Integration Testing

Test complete workflows:

```qml
// WorkflowTest.qml
import QtQuick
import QtTest
import qs_timew 2.0

TestCase {
    name: "WorkflowTest"

    property var timew: null

    function init() {
        timew = Qt.createQmlObject('import qs_timew 2.0; IntegrationComponent {}', this)
    }

    function cleanup() {
        timew.destroy()
    }

    function test_complete_workflow() {
        // Start timer
        timew.startTimer(["work", "test"])
        wait(200)
        verify(timew.timerActive)

        // Update tags
        timew.updateTags(["work", "test", "urgent"])
        wait(200)
        verify(timew.currentTags.includes("urgent"))

        // Stop timer
        timew.stopTimer()
        wait(200)
        verify(!timew.timerActive)
    }
}
```

This integration guide provides comprehensive information for integrating qs-timew into various types of applications and development environments. Choose the integration method that best suits your project requirements and follow the best practices to ensure a robust and maintainable integration.