import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import qs_timew 2.0

/**
 * CompleteExample - Full-featured demonstration of qs-timew capabilities
 *
 * This example shows advanced usage including:
 * - Integration with custom UI components
 * - Manual tag input and management
 * - Status monitoring and error handling
 * - Custom styling and theming
 */
ApplicationWindow {
    id: window

    visible: true
    width: 800
    height: 600
    title: "qs-timew Complete Example"

    // Material theme setup
    Material.theme: Material.System
    Material.accent: Material.Purple

    // Integration component for high-level API
    IntegrationComponent {
        id: integration

        onTimerStarted: function(tags) {
            statusText.text = "Timer started with: " + tags.join(", ")
            console.log("Timer started:", tags)
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

    // Main layout
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Header
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "qs-timew Complete Example"
                font.pixelSize: 24
                font.weight: Font.Bold
                Layout.fillWidth: true
            }

            // The main widget in the header
            Rectangle {
                Layout.preferredWidth: 220
                Layout.preferredHeight: 40
                color: Material.backgroundColor
                radius: 8
                border.color: Material.accent
                border.width: 1

                TimewarriorWidget {
                    id: mainWidget
                    anchors.fill: parent
                    anchors.margins: 4
                    enableGlobalShortcuts: true
                    enableIpcHandler: false
                }
            }
        }

        // Status bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: Material.backgroundColor
            radius: 4
            border.color: Material.dividerColor
            border.width: 1

            Text {
                id: statusText
                anchors.centerIn: parent
                anchors.margins: 8
                text: "Ready"
                font.pixelSize: 14
            }
        }

        // Main content area
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 20

            // Left panel - Manual controls
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
                        text: "Manual Controls"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                    }

                    // Tag input
                    TextField {
                        id: tagInput
                        Layout.fillWidth: true
                        placeholderText: "Enter tags (e.g., work project)"

                        Keys.onReturnPressed: startTimerButton.clicked()
                    }

                    // Start timer button
                    Button {
                        id: startTimerButton
                        Layout.fillWidth: true
                        text: "Start Timer"
                        enabled: tagInput.text.trim().length > 0 && !integration.timerActive

                        onClicked: {
                            const tags = tagInput.text.trim().split(/\s+/)
                            if (integration.startTimer(tags)) {
                                tagInput.text = ""
                            }
                        }
                    }

                    // Stop timer button
                    Button {
                        Layout.fillWidth: true
                        text: "Stop Timer"
                        enabled: integration.timerActive
                        highlighted: true

                        onClicked: {
                            integration.stopTimer()
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
                                text: "Active: " + (integration.timerActive ? "Yes" : "No")
                            }

                            Text {
                                text: "Tags: " + (integration.currentTags.length > 0 ? integration.currentTags.join(", ") : "None")
                            }

                            Text {
                                text: "Elapsed: " + integration.elapsedTime
                            }
                        }
                    }

                    // Tag editing
                    GroupBox {
                        Layout.fillWidth: true
                        title: "Edit Tags"
                        enabled: integration.timerActive

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 8

                            TextField {
                                id: tagEditInput
                                Layout.fillWidth: true
                                placeholderText: "New tags..."
                                text: integration.currentTags.join(" ")

                                Keys.onReturnPressed: updateTagsButton.clicked()
                            }

                            Button {
                                id: updateTagsButton
                                Layout.fillWidth: true
                                text: "Update Tags"

                                onClicked: {
                                    const validation = integration.validateTagInput(tagEditInput.text)
                                    if (validation.isValid) {
                                        integration.updateTags(validation.tags)
                                    } else {
                                        statusText.text = "Invalid tags: " + validation.errors.join(", ")
                                    }
                                }
                            }
                        }
                    }

                    Layout.fillHeight: true
                }
            }

            // Right panel - Information and examples
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    width: parent.width
                    spacing: 20

                    // Service status
                    GroupBox {
                        Layout.fillWidth: true
                        title: "Service Status"

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 8

                            Text {
                                text: "Timewarrior Available: " + (integration.timewAvailable ? "Yes" : "No")
                                color: integration.timewAvailable ? "green" : "red"
                            }

                            Text {
                                text: "Error Message: " + (integration.errorMessage || "None")
                                visible: integration.errorMessage.length > 0
                                color: "red"
                            }
                        }
                    }

                    // Usage examples
                    GroupBox {
                        Layout.fillWidth: true
                        title: "Usage Examples"

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 12

                            Text {
                                text: "1. Basic Timer Control:"
                                font.weight: Font.Bold
                            }

                            Text {
                                text: "• Use the widget in the header for quick access
• Click 'Start' and enter tags like 'work project'
• Click the timer display to stop it
• Hover and click edit icon to modify tags"
                                wrapMode: Text.WordWrap
                            }

                            Text {
                                text: "2. Manual Controls:"
                                font.weight: Font.Bold
                            }

                            Text {
                                text: "• Use the left panel for detailed control
• Enter tags manually and click 'Start Timer'
• Update tags while timer is running
• View current timer information"
                                wrapMode: Text.WordWrap
                            }

                            Text {
                                text: "3. Keyboard Shortcuts:"
                                font.weight: Font.Bold
                            }

                            Text {
                                text: "• Ctrl+Shift+T: Toggle timer start/stop
• Ctrl+Shift+I: Open input dialog
• Ctrl+Shift+E: Edit current tags
• Ctrl+Q: Quit application"
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    // API information
                    GroupBox {
                        Layout.fillWidth: true
                        title: "API Information"

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 8

                            Text {
                                text: "Module: qs_timew 2.0"
                                font.family: "monospace"
                            }

                            Text {
                                text: "Service: TimewarriorService (singleton)"
                                font.family: "monospace"
                            }

                            Text {
                                text: "Widget: TimewarriorComponent"
                                font.family: "monospace"
                            }

                            Text {
                                text: "Integration: IntegrationComponent"
                                font.family: "monospace"
                            }
                        }
                    }
                }
            }
        }
    }
}