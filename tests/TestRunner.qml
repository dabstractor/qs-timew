import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import qs_timew 2.0

/**
 * TestRunner - Simple test execution interface for qs-timew module
 *
 * This provides a basic GUI for running tests and viewing results.
 */
ApplicationWindow {
    id: window
    visible: true
    width: 800
    height: 600
    title: "qs-timew Test Runner"

    property var testResults: []
    property bool testRunning: false

    function runBasicTest() {
        testRunning = true
        testResults = []

        // Test 1: Module import
        try {
            var service = TimewarriorService
            testResults.push({name: "Module Import", status: "PASS", message: "Successfully imported TimewarriorService"})
        } catch (e) {
            testResults.push({name: "Module Import", status: "FAIL", message: e.toString()})
        }

        // Test 2: Service availability
        try {
            var available = TimewarriorService.timewAvailable
            testResults.push({name: "Service Availability", status: "PASS", message: "Service accessible: " + available})
        } catch (e) {
            testResults.push({name: "Service Availability", status: "FAIL", message: e.toString()})
        }

        // Test 3: Basic functions
        try {
            var tags = TimewarriorService.parseTagInput("work project,meeting")
            testResults.push({name: "Tag Parsing", status: "PASS", message: "Parsed tags: " + tags.join(", ")})
        } catch (e) {
            testResults.push({name: "Tag Parsing", status: "FAIL", message: e.toString()})
        }

        // Test 4: Time formatting
        try {
            var timeStr = TimewarriorService.formatElapsedTime(3661)
            testResults.push({name: "Time Formatting", status: "PASS", message: "Formatted time: " + timeStr})
        } catch (e) {
            testResults.push({name: "Time Formatting", status: "FAIL", message: e.toString()})
        }

        // Test 5: Validation
        try {
            var validation = TimewarriorService.validateTags("work project")
            testResults.push({name: "Tag Validation", status: "PASS", message: "Validation result: " + validation.isValid})
        } catch (e) {
            testResults.push({name: "Tag Validation", status: "FAIL", message: e.toString()})
        }

        testRunning = false
        console.log("Basic test execution completed")
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Text {
            text: "qs-timew Test Runner"
            font.pixelSize: 24
            font.weight: Font.Bold
            Layout.alignment: Qt.AlignHCenter
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Button {
                text: testRunning ? "Running..." : "Run Basic Tests"
                enabled: !testRunning
                onClicked: runBasicTest()
            }

            Button {
                text: "Clear Results"
                enabled: !testRunning
                onClicked: testResults = []
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                width: parent.width
                spacing: 5

                Repeater {
                    model: testResults

                    Rectangle {
                        Layout.fillWidth: true
                        height: 40
                        color: modelData.status === "PASS" ? "#e8f5e8" : "#ffe8e8"
                        border.color: modelData.status === "PASS" ? "#4caf50" : "#f44336"
                        border.width: 1
                        radius: 4

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 10

                            Text {
                                text: modelData.name
                                font.weight: Font.Bold
                                Layout.preferredWidth: 150
                            }

                            Rectangle {
                                width: 60
                                height: 20
                                color: modelData.status === "PASS" ? "#4caf50" : "#f44336"
                                radius: 3

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.status
                                    color: "white"
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                }
                            }

                            Text {
                                text: modelData.message
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }

        Text {
            text: "Tests: " + testResults.length + " | Passed: " + testResults.filter(r => r.status === "PASS").length + " | Failed: " + testResults.filter(r => r.status === "FAIL").length
            Layout.alignment: Qt.AlignHCenter
        }
    }
}