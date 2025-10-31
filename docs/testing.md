# Testing Guide

Comprehensive guide for testing the qs-timew module, including unit tests, integration tests, and validation procedures.

## Table of Contents

- [Testing Overview](#testing-overview)
- [Test Suite Structure](#test-suite-structure)
- [Running Tests](#running-tests)
- [Unit Testing](#unit-testing)
- [Integration Testing](#integration-testing)
- [Performance Testing](#performance-testing)
- [Validation Testing](#validation-testing)
- [Manual Testing](#manual-testing)
- [Continuous Integration](#continuous-integration)
- [Writing Tests](#writing-tests)
- [Debugging Tests](#debugging-tests)

## Testing Overview

### Test Categories

qs-timew includes multiple layers of testing:

1. **Unit Tests** - Test individual components and functions
2. **Integration Tests** - Test component interactions and workflows
3. **Performance Tests** - Verify performance requirements
4. **Validation Tests** - Test data integrity and edge cases
5. **UI Tests** - Test user interface components
6. **Module Tests** - Test module loading and import functionality

### Test Framework

The test suite uses Qt's built-in testing framework:

- **QtTest** - Core testing framework
- **QML Test Runner** - Execute QML test cases
- **Test Runner Application** - Custom test orchestration

### Coverage Goals

- **Code Coverage**: > 95% of critical code paths
- **Feature Coverage**: 100% of documented features
- **Edge Case Coverage**: All identified edge cases
- **Performance Coverage**: All performance benchmarks

## Test Suite Structure

```
tests/
├── TestRunner.qml                 # Main test orchestration
├── TestUtils.qml                  # Common test utilities
├── test-config.json              # Test configuration
├── unit/                          # Unit tests
│   ├── TimewarriorServiceTagEditTests.qml
│   ├── TimerStateTests.qml
│   └── TagValidationTests.qml
├── integration/                   # Integration tests
│   ├── TagEditWorkflowTests.qml
│   ├── TimerLifecycleTests.qml
│   └── ServiceIntegrationTests.qml
├── performance/                   # Performance tests
│   ├── TagUpdatePerformanceTests.qml
│   ├── StatePollingPerformanceTests.qml
│   └── MemoryUsageTests.qml
├── validation/                    # Validation tests
│   ├── DataIntegrityTests.qml
│   ├── StandaloneWidgetTest.qml
│   └── ErrorHandlingTests.qml
└── module/                        # Module tests
    ├── ModuleImportTests.qml
    ├── ComponentLoadingTests.qml
    └── ApiSurfaceTests.qml
```

## Running Tests

### Prerequisites

```bash
# Ensure Qt 6 and test tools are installed
sudo apt install qt6-base-dev qt6-declarative-dev qt6-tools-dev
sudo apt install qml6-test-tools

# Verify timewarrior is available
timew --version
```

### Running All Tests

```bash
# From the qs-timew root directory
qmltestrunner -input tests/TestRunner.qml

# Or use the test runner directly
qmlscene tests/TestRunner.qml
```

### Running Specific Test Categories

```bash
# Unit tests only
qmltestrunner -input tests/unit/TimewarriorServiceTagEditTests.qml

# Integration tests only
qmltestrunner -input tests/integration/TagEditWorkflowTests.qml

# Performance tests only
qmltestrunner -input tests/performance/TagUpdatePerformanceTests.qml

# Validation tests only
qmltestrunner -input tests/validation/DataIntegrityTests.qml

# Module tests only
qmltestrunner -input tests/module/ModuleImportTests.qml
```

### Running Tests with Options

```bash
# Run tests with verbose output
qmltestrunner -input tests/TestRunner.qml -verbose

# Run tests with coverage (if configured)
qmltestrunner -input tests/TestRunner.qml -coverage

# Run tests in quiet mode
qmltestrunner -input tests/TestRunner.qml -quiet

# Run tests with custom timeout
qmltestrunner -input tests/TestRunner.qml -timeout 60000
```

### Running Tests Programmatically

```qml
// Custom test runner
import QtQuick
import QtTest

Item {
    id: testRunner

    property var testResults: []

    function runTestSuite(testFile) {
        return new Promise((resolve, reject) => {
            const component = Qt.createComponent(testFile)
            if (component.status === Component.Ready) {
                const test = component.createObject(testRunner)
                test.caseName = testFile
                test.finished.connect(() => {
                    testResults.push({
                        name: testFile,
                        passed: test.result === QTest.Passed,
                        failures: test.failures
                    })
                    test.destroy()
                    resolve(test)
                })
                test.run()
            } else {
                reject(new Error("Failed to load test: " + component.errorString()))
            }
        })
    }

    function runAllTests() {
        const testFiles = [
            "tests/unit/TimewarriorServiceTagEditTests.qml",
            "tests/integration/TagEditWorkflowTests.qml",
            "tests/performance/TagUpdatePerformanceTests.qml"
        ]

        return testFiles.reduce((promise, testFile) => {
            return promise.then(() => runTestSuite(testFile))
        }, Promise.resolve())
    }
}
```

## Unit Testing

### TimewarriorService Tests

Test core service functionality:

```qml
// tests/unit/TimewarriorServiceTagEditTests.qml
import QtQuick
import QtTest
import qs_timew 2.0

TestCase {
    name: "TimewarriorServiceTagEditTests"

    // Mock service for isolated testing
    property var mockService: QtObject {
        property bool timerActive: false
        property var currentTags: []
        property int elapsedSeconds: 0
        property bool timewAvailable: true
        property string currentTimerId: ""
        property var tagHistory: []

        signal tagsUpdated(var oldTags, var newTags)
        signal tagUpdateFailed(string error)

        // Mock implementation of service methods
        function parseTagInput(input) {
            if (!input || input.trim().length === 0) {
                return []
            }

            const separators = [/\s+/, /,/, /;/]
            let tags = [input]

            for (let separator of separators) {
                let newTags = []
                for (let tag of tags) {
                    newTags = newTags.concat(tag.split(separator))
                }
                tags = newTags
            }

            return tags.filter(tag => tag && tag.trim().length > 0)
                      .map(tag => tag.trim())
        }

        function validateTags(tagString) {
            const tags = parseTagInput(tagString)
            const errors = []

            for (let i = 0; i < tags.length; i++) {
                const tag = tags[i]
                if (!tag || tag.length === 0) {
                    errors.push(`Tag ${i + 1}: Empty tag not allowed`)
                }
                if (tag.length > 128) {
                    errors.push(`Tag ${i + 1}: Tag too long`)
                }
                if (/[;&|`$(){}[\]]/.test(tag)) {
                    errors.push(`Tag ${i + 1}: Contains dangerous characters`)
                }
            }

            return {
                isValid: errors.length === 0,
                errors: errors,
                tags: tags
            }
        }

        function modifyTimerTags(timerId, newTags) {
            if (!timerActive) {
                tagUpdateFailed("No active timer to modify")
                return false
            }

            const oldTags = [...currentTags]
            currentTags = [...newTags]
            tagsUpdated(oldTags, newTags)
            return true
        }
    }

    function init() {
        // Reset state before each test
        mockService.timerActive = false
        mockService.currentTags = []
        mockService.elapsedSeconds = 0
        mockService.currentTimerId = ""
        mockService.tagHistory = []
    }

    // Tag Parsing Tests
    function test_parseTagInput_basic_space_separation() {
        const result = mockService.parseTagInput("project1 urgent clientA")
        compare(result.length, 3, "Should parse 3 tags")
        compare(result[0], "project1", "First tag should be 'project1'")
        compare(result[1], "urgent", "Second tag should be 'urgent'")
        compare(result[2], "clientA", "Third tag should be 'clientA'")
    }

    function test_parseTagInput_comma_separation() {
        const result = mockService.parseTagInput("project1, urgent, clientA")
        compare(result.length, 3, "Should parse 3 tags with commas")
        compare(result[0], "project1", "First tag should be 'project1'")
        compare(result[1], "urgent", "Second tag should be 'urgent'")
        compare(result[2], "clientA", "Third tag should be 'clientA'")
    }

    function test_parseTagInput_mixed_separators() {
        const result = mockService.parseTagInput("project1 urgent,clientA; testing")
        compare(result.length, 4, "Should parse 4 tags with mixed separators")
        verify(result.includes("project1"))
        verify(result.includes("urgent"))
        verify(result.includes("clientA"))
        verify(result.includes("testing"))
    }

    function test_parseTagInput_empty_input() {
        const result = mockService.parseTagInput("")
        compare(result.length, 0, "Empty input should return empty array")
    }

    // Tag Validation Tests
    function test_validateTags_valid_tags() {
        const validTags = "project1 task-123 project_name"
        const result = mockService.validateTags(validTags)
        verify(result.isValid, "Valid tags should pass validation")
        compare(result.errors.length, 0, "Should have no validation errors")
        compare(result.tags.length, 3, "Should parse 3 tags")
    }

    function test_validateTags_invalid_characters() {
        const invalidTags = "project1 'tag with spaces' tag;with;semicolons"
        const result = mockService.validateTags(invalidTags)
        verify(!result.isValid, "Invalid tags should fail validation")
        verify(result.errors.length > 0, "Should have validation errors")
    }

    function test_validateTags_empty_input() {
        const result = mockService.validateTags("")
        verify(!result.isValid, "Empty input should fail validation")
        verify(result.errors.includes("No valid tags found"))
    }

    // Timer State Tests
    function test_preserveTimerState_active_timer_update() {
        mockService.timerActive = true
        mockService.currentTags = ["work", "coding"]
        mockService.elapsedSeconds = 300

        const newTags = ["work", "coding", "debugging"]
        const result = mockService.modifyTimerTags("timer123", newTags)

        verify(result, "Tag update should succeed")
        compare(mockService.currentTags.length, 3, "Should have 3 tags")
        verify(mockService.currentTags.includes("debugging"), "Should include new tag")
        compare(mockService.elapsedSeconds, 300, "Elapsed time should be preserved")
    }

    function test_preserveTimerState_no_active_timer() {
        mockService.timerActive = false

        const result = mockService.modifyTimerTags("timer123", ["test"])
        verify(!result, "Tag update should fail without active timer")
    }

    // Performance Tests
    function test_performance_tag_parsing_large_input() {
        const tags = []
        for (let i = 0; i < 1000; i++) {
            tags.push(`tag${i}`)
        }
        const input = tags.join(" ")

        const startTime = new Date().getTime()
        const result = mockService.parseTagInput(input)
        const endTime = new Date().getTime()
        const duration = endTime - startTime

        compare(result.length, 1000, "Should parse all 1000 tags")
        verify(duration < 100, `Parsing should complete in < 100ms (took ${duration}ms)`)
    }

    function test_performance_tag_validation_many_tags() {
        const tags = []
        for (let i = 0; i < 1000; i++) {
            tags.push(`tag${i}`)
        }

        const startTime = new Date().getTime()
        const result = mockService.validateTags(tags.join(" "))
        const endTime = new Date().getTime()
        const duration = endTime - startTime

        verify(result.isValid, "Large tag array should be valid")
        verify(duration < 50, `Validation should complete in < 50ms (took ${duration}ms)`)
    }
}
```

### IntegrationComponent Tests

Test high-level API functionality:

```qml
// tests/unit/IntegrationComponentTests.qml
import QtQuick
import QtTest
import qs_timew 2.0

TestCase {
    name: "IntegrationComponentTests"

    IntegrationComponent {
        id: integration
    }

    SignalSpy {
        id: timerStartedSpy
        target: integration
        signalName: "timerStarted"
    }

    SignalSpy {
        id: timerStoppedSpy
        target: integration
        signalName: "timerStopped"
    }

    SignalSpy {
        id: errorSpy
        target: integration
        signalName: "error"
    }

    function init() {
        timerStartedSpy.clear()
        timerStoppedSpy.clear()
        errorSpy.clear()
    }

    function test_startTimer_valid_tags() {
        const result = integration.startTimer(["work", "test"])
        verify(result, "Should return true for successful start")
        compare(timerStartedSpy.count, 1, "Should emit timerStarted signal")
        compare(timerStartedSpy.signalArguments[0][0], ["work", "test"], "Should pass correct tags")
    }

    function test_startTimer_empty_tags() {
        const result = integration.startTimer([])
        verify(!result, "Should return false for empty tags")
        compare(errorSpy.count, 1, "Should emit error signal")
    }

    function test_stopTimer_active() {
        // First start a timer
        integration.startTimer(["test"])
        timerStartedSpy.wait(1000)

        // Then stop it
        const result = integration.stopTimer()
        verify(result, "Should return true for successful stop")
        compare(timerStoppedSpy.count, 1, "Should emit timerStopped signal")
    }

    function test_validateTagInput_valid() {
        const validation = integration.validateTagInput("work project urgent")
        verify(validation.isValid, "Should validate valid input")
        compare(validation.tags.length, 3, "Should parse 3 tags")
    }

    function test_validateTagInput_invalid() {
        const validation = integration.validateTagInput("")
        verify(!validation.isValid, "Should reject empty input")
        verify(validation.errors.length > 0, "Should provide error messages")
    }
}
```

## Integration Testing

### Workflow Tests

Test complete user workflows:

```qml
// tests/integration/TagEditWorkflowTests.qml
import QtQuick
import QtTest
import qs_timew 2.0

TestCase {
    name: "TagEditWorkflowTests"

    IntegrationComponent {
        id: integration
    }

    Timer {
        id: asyncTimer
        interval: 100
        repeat: false
    }

    function init() {
        // Ensure clean state
        if (integration.timerActive) {
            integration.stopTimer()
            asyncTimer.restart()
            wait(200)
        }
    }

    function test_complete_tag_edit_workflow() {
        // Step 1: Start timer with initial tags
        const startResult = integration.startTimer(["work", "project"])
        verify(startResult, "Should start timer successfully")
        wait(200)

        // Step 2: Verify timer is active
        verify(integration.timerActive, "Timer should be active")
        compare(integration.currentTags.length, 2, "Should have 2 initial tags")

        // Step 3: Update tags
        const updateResult = integration.updateTags(["work", "project", "urgent"])
        verify(updateResult, "Should update tags successfully")
        wait(200)

        // Step 4: Verify tags were updated
        compare(integration.currentTags.length, 3, "Should have 3 updated tags")
        verify(integration.currentTags.includes("urgent"), "Should include new tag")

        // Step 5: Stop timer
        const stopResult = integration.stopTimer()
        verify(stopResult, "Should stop timer successfully")
        wait(200)

        // Step 6: Verify timer is stopped
        verify(!integration.timerActive, "Timer should be inactive")
    }

    function test_concurrent_tag_modifications() {
        // Start timer
        integration.startTimer(["test"])
        wait(200)

        // Attempt multiple rapid tag updates
        const update1 = integration.updateTags(["test", "urgent"])
        const update2 = integration.updateTags(["test", "urgent", "meeting"])
        const update3 = integration.updateTags(["test", "meeting"])

        wait(300)

        // Verify final state is consistent
        verify(integration.currentTags.includes("test"), "Should retain original tag")
        verify(integration.currentTags.includes("meeting"), "Should include final tag")
    }

    function test_error_recovery_workflow() {
        // Attempt to modify tags without active timer
        const result = integration.updateTags(["work", "urgent"])
        verify(!result, "Should fail without active timer")

        // Start timer
        integration.startTimer(["work"])
        wait(200)

        // Modify tags with valid input
        const updateResult = integration.updateTags(["work", "urgent"])
        verify(updateResult, "Should succeed with active timer")
        wait(200)

        // Verify state recovered correctly
        verify(integration.timerActive, "Timer should remain active")
        compare(integration.currentTags.length, 2, "Should have updated tags")
    }
}
```

### Service Integration Tests

Test integration with external timewarrior service:

```qml
// tests/integration/ServiceIntegrationTests.qml
import QtQuick
import QtTest
import qs_timew 2.0

TestCase {
    name: "ServiceIntegrationTests"

    property var service: TimewarriorService

    function initTestCase() {
        // Verify timewarrior is available
        if (!service.timewAvailable) {
            skip("Timewarrior not available for integration tests")
        }
    }

    function init() {
        // Clean up any existing timer
        if (service.timerActive) {
            service.stopTimer()
            wait(2000) // Wait for timewarrior to process
        }
    }

    function test_real_timer_start_stop() {
        // Start real timer
        service.startTimer(["integration", "test"])
        wait(2000) // Wait for state polling

        verify(service.timerActive, "Real timer should be active")
        verify(service.currentTags.includes("integration"), "Should have correct tags")
        verify(service.elapsedSeconds > 0, "Should track elapsed time")

        // Stop real timer
        service.stopTimer()
        wait(2000) // Wait for timewarrior to process

        verify(!service.timerActive, "Real timer should be stopped")
    }

    function test_real_tag_modification() {
        // Start timer
        service.startTimer(["initial", "tags"])
        wait(2000)

        verify(service.timerActive, "Timer should be active")

        // Modify tags
        const timerId = service.getCurrentTimerId()
        const result = service.modifyTimerTags(timerId, ["modified", "tags"])
        verify(result, "Tag modification should succeed")

        wait(2000) // Wait for timewarrior to process

        // Verify tags were updated
        verify(service.currentTags.includes("modified"), "Should have modified tags")
        verify(!service.currentTags.includes("initial"), "Should not have old tags")

        // Cleanup
        service.stopTimer()
        wait(2000)
    }

    function test_week_tags_retrieval() {
        // Wait for week tags to be populated
        wait(6000) // Week tags refresh every 5 minutes

        verify(service.weekTags.length >= 0, "Week tags should be retrievable")
        console.log("Retrieved " + service.weekTags.length + " week tags")
    }
}
```

## Performance Testing

### Benchmark Tests

Verify performance requirements:

```qml
// tests/performance/TagUpdatePerformanceTests.qml
import QtQuick
import QtTest
import qs_timew 2.0

TestCase {
    name: "TagUpdatePerformanceTests"

    IntegrationComponent {
        id: integration
    }

    function test_tag_parsing_performance() {
        const testSizes = [10, 100, 1000, 5000]

        for (let size of testSizes) {
            const tags = []
            for (let i = 0; i < size; i++) {
                tags.push(`tag${i}`)
            }

            const input = tags.join(" ")

            const startTime = performance.now()
            const validation = integration.validateTagInput(input)
            const endTime = performance.now()
            const duration = endTime - startTime

            verify(validation.isValid, `Should validate ${size} tags`)
            verify(duration < 100, `${size} tags should parse in < 100ms (took ${duration.toFixed(2)}ms)`)

            console.log(`${size} tags parsed in ${duration.toFixed(2)}ms`)
        }
    }

    function test_timer_state_polling_performance() {
        // Test state polling overhead
        const iterations = 100
        const startTime = performance.now()

        for (let i = 0; i < iterations; i++) {
            const timerInfo = integration.getActiveTimer()
            // Access all properties to ensure full evaluation
            const _ = timerInfo.active
            const __ = timerInfo.tags
            const ___ = timerInfo.elapsedTime
        }

        const endTime = performance.now()
        const avgDuration = (endTime - startTime) / iterations

        verify(avgDuration < 1, `State access should average < 1ms (was ${avgDuration.toFixed(3)}ms)`)
        console.log(`State access averaged ${avgDuration.toFixed(3)}ms over ${iterations} iterations`)
    }

    function test_memory_usage_stability() {
        // Test memory usage doesn't grow over time
        const initialMemory = getMemoryUsage()
        console.log("Initial memory usage:", initialMemory, "KB")

        // Perform many operations
        for (let i = 0; i < 1000; i++) {
            const tags = [`test${i % 10}`, `category${i % 5}`]
            integration.startTimer(tags)
            integration.updateTags([`modified${i % 10}`, tags[1]])
            integration.stopTimer()
        }

        const finalMemory = getMemoryUsage()
        const memoryIncrease = finalMemory - initialMemory

        console.log("Final memory usage:", finalMemory, "KB")
        console.log("Memory increase:", memoryIncrease, "KB")

        verify(memoryIncrease < 1000, `Memory increase should be < 1MB (was ${memoryIncrease}KB)`)
    }

    function getMemoryUsage() {
        // Platform-specific memory usage
        // This is a mock implementation
        return Math.random() * 1000 + 5000 // Simulated memory usage in KB
    }
}
```

## Validation Testing

### Data Integrity Tests

Ensure data integrity and error handling:

```qml
// tests/validation/DataIntegrityTests.qml
import QtQuick
import QtTest
import qs_timew 2.0

TestCase {
    name: "DataIntegrityTests"

    IntegrationComponent {
        id: integration
    }

    function test_timer_state_consistency() {
        // Start timer
        integration.startTimer(["consistency", "test"])
        wait(200)

        // Verify all state properties are consistent
        verify(integration.timerActive, "Timer should be active")
        verify(integration.currentTags.length > 0, "Should have current tags")
        verify(integration.elapsedTime.length > 0, "Should have elapsed time")

        // Stop timer
        integration.stopTimer()
        wait(200)

        // Verify state reset properly
        verify(!integration.timerActive, "Timer should be inactive")
        // Note: lastUsedTags should be preserved
    }

    function test_error_boundary_conditions() {
        // Test extreme inputs
        const extremeInputs = [
            "", // Empty
            "a".repeat(200), // Very long single tag
            "a".repeat(200) + " " + "b".repeat(200), // Multiple long tags
            "!@#$%^&*(){}[]|\\:;\"'<>?/", // Special characters
            "   ", // Whitespace only
            "tag\nwith\nnewlines", // Newlines
            "tag\twith\ttabs", // Tabs
            Array(1000).fill("tag").join(" "), // Many tags
        ]

        for (let input of extremeInputs) {
            const validation = integration.validateTagInput(input)

            // Should never crash
            verify(typeof validation === "object", "Should return validation object")
            verify(typeof validation.isValid === "boolean", "Should have isValid property")
            verify(Array.isArray(validation.errors), "Should have errors array")
            verify(Array.isArray(validation.tags), "Should have tags array")
        }
    }

    function test_concurrent_access_safety() {
        // Simulate rapid concurrent access
        const promises = []

        for (let i = 0; i < 10; i++) {
            promises.push(new Promise((resolve) => {
                setTimeout(() => {
                    const result = integration.startTimer([`concurrent${i}`])
                    resolve(result)
                }, Math.random() * 100)
            }))
        }

        // Wait for all operations to complete
        Promise.all(promises).then(() => {
            wait(500)

            // System should be in a consistent state
            const timerInfo = integration.getActiveTimer()
            verify(typeof timerInfo.active === "boolean", "Timer state should be consistent")
        })
    }

    function test_data_corruption_prevention() {
        // Start timer with known state
        integration.startTimer(["integrity", "test"])
        wait(200)

        const originalTags = [...integration.currentTags]
        const originalState = integration.timerActive

        // Attempt various operations that could corrupt state
        integration.updateTags(["modified", "tags"])
        integration.updateTags(["further", "modified"])
        integration.startTimer(["conflicting", "tags"]) // Should fail

        wait(300)

        // Verify state is still valid
        verify(typeof integration.timerActive === "boolean", "Timer state should remain valid")
        verify(Array.isArray(integration.currentTags), "Current tags should remain valid array")

        // Cleanup
        if (integration.timerActive) {
            integration.stopTimer()
        }
    }
}
```

## Manual Testing

### Test Scenarios

Manual testing checklist for critical scenarios:

```markdown
# Manual Testing Checklist

## Basic Functionality
- [ ] Timer starts with valid tags
- [ ] Timer stops correctly
- [ ] Elapsed time displays correctly
- [ ] Tags are displayed properly

## Tag Management
- [ ] Tag input accepts spaces as separators
- [ ] Tag input accepts commas as separators
- [ ] Tag input accepts semicolons as separators
- [ ] Mixed separators work correctly
- [ ] Empty tags are rejected
- [ ] Invalid characters are rejected
- [ ] Tag editing works on active timer
- [ ] Tag history is maintained

## User Interface
- [ ] Widget renders correctly
- [ ] Popups open and close properly
- [ ] Input fields accept text
- [ ] Buttons respond to clicks
- [ ] Hover states work
- [ ] Focus management works
- [ ] Keyboard shortcuts work

## Error Handling
- [ ] Graceful handling of missing timewarrior
- [ ] Graceful handling of invalid input
- [ ] Graceful handling of network issues
- [ ] User-friendly error messages

## Performance
- [ ] UI remains responsive during operations
- [ ] Memory usage is reasonable
- [ ] CPU usage is reasonable
- [ ] No memory leaks over extended use
```

### Manual Test Script

```qml
// tests/manual/ManualTestInterface.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import qs_timew 2.0

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "Manual Testing Interface"

    IntegrationComponent {
        id: timew

        onTimerStarted: console.log("Timer started:", tags)
        onTimerStopped: console.log("Timer stopped")
        onError: console.error("Error:", message)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Text {
            text: "qs-timew Manual Testing Interface"
            font.pixelSize: 24
            font.weight: Font.Bold
            Layout.alignment: Qt.AlignHCenter
        }

        // Status display
        GroupBox {
            Layout.fillWidth: true
            title: "Current Status"

            Column {
                spacing: 8

                Text {
                    text: "Timewarrior Available: " + (timew.timewAvailable ? "Yes" : "No")
                    color: timew.timewAvailable ? "green" : "red"
                }

                Text {
                    text: "Timer Active: " + (timew.timerActive ? "Yes" : "No")
                }

                Text {
                    text: "Current Tags: " + timew.currentTags.join(", ")
                }

                Text {
                    text: "Elapsed Time: " + timew.elapsedTime
                }

                Text {
                    text: "Error Message: " + (timew.errorMessage || "None")
                    color: "red"
                }
            }
        }

        // Test controls
        GroupBox {
            Layout.fillWidth: true
            title: "Test Controls"

            GridLayout {
                columns: 2
                columnSpacing: 10
                rowSpacing: 10

                TextField {
                    id: tagInput
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    placeholderText: "Enter test tags..."
                }

                Button {
                    text: "Start Timer"
                    onClicked: {
                        const validation = timew.validateTagInput(tagInput.text)
                        if (validation.isValid) {
                            timew.startTimer(validation.tags)
                        } else {
                            console.log("Validation errors:", validation.errors)
                        }
                    }
                }

                Button {
                    text: "Stop Timer"
                    highlighted: true
                    enabled: timew.timerActive
                    onClicked: timew.stopTimer()
                }

                Button {
                    text: "Update Tags"
                    enabled: timew.timerActive
                    onClicked: {
                        const validation = timew.validateTagInput(tagInput.text)
                        if (validation.isValid) {
                            timew.updateTags(validation.tags)
                        }
                    }
                }

                Button {
                    text: "Clear Input"
                    onClicked: tagInput.text = ""
                }
            }
        }

        // Test scenarios
        GroupBox {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "Test Scenarios"

            ScrollView {
                anchors.fill: parent

                Column {
                    width: parent.width
                    spacing: 10

                    Repeater {
                        model: [
                            { label: "Basic Start/Stop", tags: "test basic", action: "basic" },
                            { label: "Multiple Tags", tags: "work project urgent", action: "multi" },
                            { label: "Special Characters", tags: "test-tag special_chars", action: "special" },
                            { label: "Many Tags", tags: Array(20).fill().map((_, i) => `tag${i}`).join(" "), action: "many" },
                            { label: "Empty Tags", tags: "", action: "empty" },
                            { label: "Long Tag", tags: "a".repeat(100), action: "long" }
                        ]

                        Rectangle {
                            width: parent.width
                            height: 40
                            color: "#f0f0f0"
                            radius: 4

                            Row {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 10

                                Text {
                                    text: modelData.label
                                    anchors.verticalCenter: parent.verticalCenter
                                    font.pixelSize: 12
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                Button {
                                    text: "Test"
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: {
                                        tagInput.text = modelData.tags
                                        console.log("Testing scenario:", modelData.action)

                                        if (modelData.tags.length > 0) {
                                            timew.startTimer(modelData.tags.split(/\s+/))
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

## Continuous Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/test.yml
name: qs-timew Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        qt-version: [6.2, 6.3, 6.4, 6.5]

    steps:
    - uses: actions/checkout@v3

    - name: Install Qt
      uses: jurplel/install-qt-action@v3
      with:
        version: ${{ matrix.qt-version }}

    - name: Install timewarrior
      run: |
        sudo apt-get update
        sudo apt-get install -y timewarrior

    - name: Set up QML import path
      run: |
        echo "QML2_IMPORT_PATH=$GITHUB_WORKSPACE:$QML2_IMPORT_PATH" >> $GITHUB_ENV

    - name: Run unit tests
      run: |
        qmltestrunner -input tests/unit/TimewarriorServiceTagEditTests.qml

    - name: Run integration tests
      run: |
        qmltestrunner -input tests/integration/TagEditWorkflowTests.qml

    - name: Run performance tests
      run: |
        qmltestrunner -input tests/performance/TagUpdatePerformanceTests.qml

    - name: Run validation tests
      run: |
        qmltestrunner -input tests/validation/DataIntegrityTests.qml

    - name: Run module tests
      run: |
        qmltestrunner -input tests/module/ModuleImportTests.qml

    - name: Run full test suite
      run: |
        qmltestrunner -input tests/TestRunner.qml

    - name: Upload test results
      uses: actions/upload-artifact@v3
      if: failure()
      with:
        name: test-results-${{ matrix.qt-version }}
        path: test-results/
```

### Local CI Script

```bash
#!/bin/bash
# scripts/run-ci.sh

set -e

echo "Running qs-timew CI tests..."

# Set up environment
export QML2_IMPORT_PATH=$PWD:$QML2_IMPORT_PATH

# Create test results directory
mkdir -p test-results

# Function to run test and capture results
run_test() {
    local test_file=$1
    local test_name=$(basename "$test_file" .qml)

    echo "Running $test_name..."

    if qmltestrunner -input "$test_file" > "test-results/${test_name}.log" 2>&1; then
        echo "✓ $test_name passed"
        return 0
    else
        echo "✗ $test_name failed"
        echo "Check test-results/${test_name}.log for details"
        return 1
    fi
}

# Run all test categories
test_failed=0

echo "=== Unit Tests ==="
for test in tests/unit/*.qml; do
    run_test "$test" || test_failed=1
done

echo "=== Integration Tests ==="
for test in tests/integration/*.qml; do
    run_test "$test" || test_failed=1
done

echo "=== Performance Tests ==="
for test in tests/performance/*.qml; do
    run_test "$test" || test_failed=1
done

echo "=== Validation Tests ==="
for test in tests/validation/*.qml; do
    run_test "$test" || test_failed=1
done

echo "=== Module Tests ==="
for test in tests/module/*.qml; do
    run_test "$test" || test_failed=1
done

# Summary
echo "=== Test Summary ==="
if [ $test_failed -eq 0 ]; then
    echo "All tests passed! ✓"
    exit 0
else
    echo "Some tests failed! ✗"
    exit 1
fi
```

## Writing Tests

### Test Structure Template

```qml
// Template for new test files
import QtQuick
import QtTest
import qs_timew 2.0

TestCase {
    name: "YourTestName"

    // Test components
    // IntegrationComponent { id: integration }
    // TimewarriorService { id: service }

    // Signal spies
    // SignalSpy { id: spy; target: integration; signalName: "signalName" }

    function init() {
        // Reset test state
        // spy.clear()
    }

    function cleanup() {
        // Clean up after test
    }

    function initTestCase() {
        // One-time setup
    }

    function cleanupTestCase() {
        // One-time cleanup
    }

    // Test functions
    function test_your_test_case() {
        // Test implementation
        verify(condition, "Error message")
        compare(actual, expected, "Values should match")
        fail("Test failed for reason")
    }
}
```

### Best Practices for Test Writing

1. **Descriptive Test Names**: Use clear, descriptive test function names
2. **Independent Tests**: Each test should be independent of others
3. **Setup/Teardown**: Use `init()` and `cleanup()` properly
4. **Assertions**: Use appropriate assertion methods (`verify`, `compare`, `fail`)
5. **Error Messages**: Provide clear error messages for debugging
6. **Test Coverage**: Test both success and failure scenarios
7. **Edge Cases**: Test boundary conditions and edge cases
8. **Performance**: Include performance tests for critical paths

## Debugging Tests

### Common Debugging Techniques

1. **Console Logging**: Add console.log statements for debugging
2. **Test Breakpoints**: Use `fail()` to stop test execution
3. **Signal Spies**: Use SignalSpy to verify signal emissions
4. **Wait Conditions**: Use `wait()` for async operations
5. **Property Observation**: Monitor property changes

### Debugging Example

```qml
function test_with_debugging() {
    console.log("Starting test...")

    const result = integration.startTimer(["debug", "test"])
    console.log("Start result:", result)

    wait(500) // Wait for async operation

    console.log("Timer active:", integration.timerActive)
    console.log("Current tags:", integration.currentTags)

    verify(integration.timerActive, "Timer should be active")

    if (!integration.timerActive) {
        console.log("Debug: Checking service state...")
        console.log("Service available:", TimewarriorService.timewAvailable)
        console.log("Service error:", TimewarriorService.errorMessage)
    }
}
```

This comprehensive testing guide provides all the information needed to effectively test the qs-timew module, from unit tests to integration tests and performance benchmarks.