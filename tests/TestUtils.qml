import QtQuick 2.15
import qs_timew 2.0

/**
 * TestUtils - Simple utility functions for testing qs-timew module
 */
QtObject {
    id: root

    // Mock service for testing
    property var mockService: TimewarriorService

    // Test data generators
    function generateValidTags() {
        return ["work", "project", "meeting", "development", "research"]
    }

    function generateInvalidTags() {
        return ["", "   ", "tag with spaces", "tag;with;semicolons", "very-long-tag-name-that-exceeds-the-maximum-allowed-length-for-validation-purposes"]
    }

    function generateTimewarriorOutput() {
        return JSON.stringify([
            {
                "id": "20241029T100000Z",
                "start": "2024-10-29T10:00:00Z",
                "end": null,
                "duration": null,
                "status": "active",
                "tags": ["work", "project"],
                "annotation": "Test timer"
            }
        ])
    }

    // Assertion helpers
    function assertEqual(actual, expected, message) {
        if (actual === expected) {
            return {passed: true, message: message || "Values are equal"}
        } else {
            return {passed: false, message: message || "Expected " + expected + ", got " + actual}
        }
    }

    function assertTrue(condition, message) {
        if (condition) {
            return {passed: true, message: message || "Condition is true"}
        } else {
            return {passed: false, message: message || "Expected true, got false"}
        }
    }

    function assertFalse(condition, message) {
        if (!condition) {
            return {passed: true, message: message || "Condition is false"}
        } else {
            return {passed: false, message: message || "Expected false, got true"}
        }
    }

    // Test scenario runners
    function runTagParsingTests() {
        var results = []

        // Test basic parsing
        var tags = mockService.parseTagInput("work project")
        results.push(assertEqual(tags.length, 2, "Basic tag parsing"))
        results.push(assertEqual(tags[0], "work", "First tag parsed correctly"))
        results.push(assertEqual(tags[1], "project", "Second tag parsed correctly"))

        // Test comma separators
        tags = mockService.parseTagInput("work,project")
        results.push(assertEqual(tags.length, 2, "Comma separator parsing"))

        // Test semicolon separators
        tags = mockService.parseTagInput("work;project")
        results.push(assertEqual(tags.length, 2, "Semicolon separator parsing"))

        // Test empty input
        tags = mockService.parseTagInput("")
        results.push(assertEqual(tags.length, 0, "Empty input handling"))

        return results
    }

    function runTagValidationTests() {
        var results = []

        // Test valid tags
        var validation = mockService.validateTags("work project")
        results.push(assertEqual(validation.isValid, true, "Valid tag validation"))
        results.push(assertEqual(validation.tags.length, 2, "Valid tag count"))

        // Test invalid tags
        validation = mockService.validateTags("tag with spaces")
        results.push(assertEqual(validation.isValid, false, "Invalid tag rejection"))

        // Test empty input
        validation = mockService.validateTags("")
        results.push(assertEqual(validation.isValid, false, "Empty tag rejection"))

        return results
    }

    function runTimeFormattingTests() {
        var results = []

        // Test basic formatting
        var timeStr = mockService.formatElapsedTime(3661)
        results.push(assertEqual(timeStr, "01:01:01", "1 hour 1 minute 1 second formatting"))

        // Test zero time
        timeStr = mockService.formatElapsedTime(0)
        results.push(assertEqual(timeStr, "00:00:00", "Zero time formatting"))

        // Test large values
        timeStr = mockService.formatElapsedTime(86400) // 24 hours
        results.push(assertEqual(timeStr, "24:00:00", "24 hour formatting"))

        return results
    }

    function runBasicFunctionalityTests() {
        var results = []

        // Test service availability
        results.push(assertTrue(mockService !== null, "Service instance available"))

        // Test timer state access
        var timerActive = mockService.timerActive
        results.push(assertTrue(typeof timerActive === "boolean", "Timer state accessible"))

        // Test tag history access
        var tagHistory = mockService.tagHistory
        results.push(assertTrue(Array.isArray(tagHistory), "Tag history accessible"))

        return results
    }
}