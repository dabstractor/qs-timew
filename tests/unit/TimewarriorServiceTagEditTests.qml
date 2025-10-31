import QtQuick 2.15
import QtTest
import qs_timew

TestCase {
    name: "TimewarriorServiceTagEditTests"

    // Mock TimewarriorService for isolated testing
    property var mockService: QtObject {
        // Existing properties
        property bool timerActive: false
        property var currentTags: []
        property int elapsedSeconds: 0
        property bool timewAvailable: true

        // New properties for tag editing
        property string currentTimerId: ""
        property var tagHistory: []

        // Mock signals
        signal tagsUpdated(var oldTags, var newTags)
        signal tagUpdateFailed(string error)

        function parseTagInput(input) {
            if (!input || input.trim().length === 0) {
                return [];
            }

            // Handle various separators: spaces, commas, semicolons
            const separators = [/\s+/, /,/, /;/];
            let tags = [input];

            for (let separator of separators) {
                let newTags = [];
                for (let tag of tags) {
                    newTags = newTags.concat(tag.split(separator));
                }
                tags = newTags;
            }

            // Filter out empty strings and trim whitespace
            return tags.filter(tag => tag && tag.trim().length > 0)
                      .map(tag => tag.trim());
        }

        function validateTagFormat(tags) {
            const errors = [];
            const validTagPattern = /^[^\s\n\r]+$/;

            for (let i = 0; i < tags.length; i++) {
                const tag = tags[i];

                if (!tag || tag.length === 0) {
                    errors.push(`Tag ${i + 1}: Empty tag not allowed`);
                    continue;
                }

                if (tag.length > 128) {
                    errors.push(`Tag ${i + 1}: Tag too long (max 128 characters)`);
                }

                if (!validTagPattern.test(tag)) {
                    errors.push(`Tag ${i + 1}: Invalid characters in tag '${tag}'`);
                }
            }

            return {
                isValid: errors.length === 0,
                errors: errors
            };
        }

        function simulateTagUpdate(newTags) {
            if (!timerActive) {
                return {
                    success: false,
                    error: "No active timer to update"
                };
            }

            const validation = validateTagFormat(newTags);
            if (!validation.isValid) {
                return {
                    success: false,
                    error: validation.errors.join("; ")
                };
            }

            // Simulate successful update
            const oldTags = [...currentTags];
            currentTags = [...newTags];

            return {
                success: true,
                oldTags: oldTags,
                newTags: currentTags
            };
        }

        // New methods for tag editing functionality
        function getActiveTimer() {
            if (!mockService.timerActive) {
                return {
                    active: false,
                    timerId: null,
                    tags: [],
                    startTime: null,
                    elapsedSeconds: 0
                };
            }

            return {
                active: true,
                timerId: mockService.currentTimerId,
                tags: [...mockService.currentTags],
                startTime: "2024-10-16T10:00:00Z", // Mock start time
                elapsedSeconds: mockService.elapsedSeconds
            };
        }

        function getCurrentTimerId() {
            return mockService.currentTimerId;
        }

        function updateTagHistory(newTags) {
            for (let tag of newTags) {
                if (!mockService.tagHistory.includes(tag)) {
                    mockService.tagHistory.push(tag);
                }
            }

            // Keep history size manageable
            if (mockService.tagHistory.length > 100) {
                mockService.tagHistory = mockService.tagHistory.slice(-100);
            }
        }

        function mockModifyTimerTags(timerId, newTags) {
            if (!mockService.timerActive) {
                const error = "No active timer to modify";
                mockService.tagUpdateFailed(error);
                return false;
            }

            if (!timerId || timerId.trim().length === 0) {
                const error = "Invalid timer ID";
                mockService.tagUpdateFailed(error);
                return false;
            }

            if (!newTags || !Array.isArray(newTags) || newTags.length === 0) {
                const error = "Invalid new tags array";
                mockService.tagUpdateFailed(error);
                return false;
            }

            // Store old tags for signal emission
            const oldTags = [...mockService.currentTags];

            // Update tag history
            mockService.updateTagHistory(newTags);

            // Simulate successful tag modification
            mockService.currentTags = [...newTags];
            mockService.tagsUpdated(oldTags, newTags);

            return true;
        }
    }

    function init() {
        // Reset mock service state before each test
        mockService.timerActive = false;
        mockService.currentTags = [];
        mockService.elapsedSeconds = 0;
        mockService.currentTimerId = "";
        mockService.tagHistory = [];
    }

    // UT-001: Tag Parsing Function Tests
    function test_parseTagInput_basic_space_separation() {
        const result = mockService.parseTagInput("project1 urgent clientA");
        compare(result.length, 3, "Should parse 3 tags");
        compare(result[0], "project1", "First tag should be 'project1'");
        compare(result[1], "urgent", "Second tag should be 'urgent'");
        compare(result[2], "clientA", "Third tag should be 'clientA'");
    }

    function test_parseTagInput_comma_separation() {
        const result = mockService.parseTagInput("project1, urgent, clientA");
        compare(result.length, 3, "Should parse 3 tags with commas");
        compare(result[0], "project1", "First tag should be 'project1'");
        compare(result[1], "urgent", "Second tag should be 'urgent'");
        compare(result[2], "clientA", "Third tag should be 'clientA'");
    }

    function test_parseTagInput_semicolon_separation() {
        const result = mockService.parseTagInput("project1; urgent; clientA");
        compare(result.length, 3, "Should parse 3 tags with semicolons");
        compare(result[0], "project1", "First tag should be 'project1'");
        compare(result[1], "urgent", "Second tag should be 'urgent'");
        compare(result[2], "clientA", "Third tag should be 'clientA'");
    }

    function test_parseTagInput_mixed_separators() {
        const result = mockService.parseTagInput("project1 urgent,clientA; testing");
        compare(result.length, 4, "Should parse 4 tags with mixed separators");
        compare(result[0], "project1", "First tag should be 'project1'");
        compare(result[1], "urgent", "Second tag should be 'urgent'");
        compare(result[2], "clientA", "Third tag should be 'clientA'");
        compare(result[3], "testing", "Fourth tag should be 'testing'");
    }

    function test_parseTagInput_special_characters() {
        const result = mockService.parseTagInput("project-name task-123 special$chars");
        compare(result.length, 3, "Should parse 3 tags with special characters");
        compare(result[0], "project-name", "First tag should be 'project-name'");
        compare(result[1], "task-123", "Second tag should be 'task-123'");
        compare(result[2], "special$chars", "Third tag should be 'special$chars'");
    }

    function test_parseTagInput_empty_input() {
        const result = mockService.parseTagInput("");
        compare(result.length, 0, "Empty input should return empty array");
    }

    function test_parseTagInput_whitespace_only() {
        const result = mockService.parseTagInput("   ");
        compare(result.length, 0, "Whitespace-only input should return empty array");
    }

    function test_parseTagInput_extra_whitespace() {
        const result = mockService.parseTagInput("  project1   urgent   clientA  ");
        compare(result.length, 3, "Should handle extra whitespace");
        compare(result[0], "project1", "Should trim leading/trailing whitespace");
        compare(result[1], "urgent", "Should trim intermediate whitespace");
        compare(result[2], "clientA", "Should handle trailing whitespace");
    }

    // UT-002: Timer State Preservation Tests
    function test_preserveTimerState_active_timer_update() {
        // Setup initial state
        mockService.timerActive = true;
        mockService.currentTags = ["work", "coding"];
        mockService.elapsedSeconds = 300;

        // Perform tag update
        const newTags = ["work", "coding", "debugging"];
        const result = mockService.simulateTagUpdate(newTags);

        // Verify success
        verify(result.success, "Tag update should succeed");
        compare(result.newTags.length, 3, "Should have 3 new tags");
        verify(result.newTags.includes("debugging"), "Should include new tag 'debugging'");

        // Verify timer state preservation
        compare(mockService.timerActive, true, "Timer should remain active");
        compare(mockService.elapsedSeconds, 300, "Elapsed time should be preserved");
    }

    function test_preserveTimerState_no_active_timer() {
        // Setup no active timer
        mockService.timerActive = false;

        // Attempt tag update
        const result = mockService.simulateTagUpdate(["test"]);

        // Verify failure
        verify(!result.success, "Tag update should fail without active timer");
        compare(result.error, "No active timer to update", "Should return appropriate error");
    }

    // UT-003: Tag Validation Tests
    function test_validateTagFormat_valid_tags() {
        const validTags = ["project1", "task-123", "project_name", "special$chars"];
        const result = mockService.validateTagFormat(validTags);

        verify(result.isValid, "Valid tags should pass validation");
        compare(result.errors.length, 0, "Should have no validation errors");
    }

    function test_validateTagFormat_empty_tag() {
        const invalidTags = ["project1", "", "project2"];
        const result = mockService.validateTagFormat(invalidTags);

        verify(!result.isValid, "Empty tag should fail validation");
        verify(result.errors.length > 0, "Should have validation errors");
        verify(result.errors[0].includes("Empty tag"), "Error should mention empty tag");
    }

    function test_validateTagFormat_too_long_tag() {
        const longTag = "a".repeat(129); // 129 characters
        const invalidTags = ["project1", longTag];
        const result = mockService.validateTagFormat(invalidTags);

        verify(!result.isValid, "Too long tag should fail validation");
        verify(result.errors.length > 0, "Should have validation errors");
        verify(result.errors[0].includes("too long"), "Error should mention tag length");
    }

    function test_validateTagFormat_invalid_characters() {
        const invalidTags = ["project1", "tag with spaces", "tag\nwith\nnewlines"];
        const result = mockService.validateTagFormat(invalidTags);

        verify(!result.isValid, "Tags with invalid characters should fail validation");
        verify(result.errors.length > 0, "Should have validation errors");
    }

    function test_validateTagFormat_empty_array() {
        const result = mockService.validateTagFormat([]);

        verify(result.isValid, "Empty tag array should be valid");
        compare(result.errors.length, 0, "Should have no validation errors");
    }

    // Performance Tests
    function test_performance_tag_parsing_large_input() {
        // Create input with many tags
        const tags = [];
        for (let i = 0; i < 1000; i++) {
            tags.push(`tag${i}`);
        }
        const input = tags.join(" ");

        const startTime = new Date().getTime();
        const result = mockService.parseTagInput(input);
        const endTime = new Date().getTime();
        const duration = endTime - startTime;

        compare(result.length, 1000, "Should parse all 1000 tags");
        verify(duration < 100, `Parsing should complete in < 100ms (took ${duration}ms)`);
    }

    function test_performance_tag_validation_many_tags() {
        // Create array with many valid tags
        const tags = [];
        for (let i = 0; i < 1000; i++) {
            tags.push(`tag${i}`);
        }

        const startTime = new Date().getTime();
        const result = mockService.validateTagFormat(tags);
        const endTime = new Date().getTime();
        const duration = endTime - startTime;

        verify(result.isValid, "Large tag array should be valid");
        verify(duration < 50, `Validation should complete in < 50ms (took ${duration}ms)`);
    }

    // UT-004: getActiveTimer() Tests
    function test_getActiveTimer_no_active_timer() {
        const result = mockService.getActiveTimer();

        compare(result.active, false, "Should return inactive timer");
        compare(result.timerId, null, "Timer ID should be null");
        compare(result.tags.length, 0, "Tags should be empty");
        compare(result.elapsedSeconds, 0, "Elapsed seconds should be 0");
    }

    function test_getActiveTimer_with_active_timer() {
        // Setup active timer state
        mockService.timerActive = true;
        mockService.currentTags = ["project", "urgent"];
        mockService.currentTimerId = "20241016T100000Z";
        mockService.elapsedSeconds = 300;

        const result = mockService.getActiveTimer();

        compare(result.active, true, "Should return active timer");
        compare(result.timerId, "20241016T100000Z", "Should return correct timer ID");
        compare(result.tags.length, 2, "Should return 2 tags");
        verify(result.tags.includes("project"), "Should include 'project' tag");
        verify(result.tags.includes("urgent"), "Should include 'urgent' tag");
        compare(result.elapsedSeconds, 300, "Should return correct elapsed time");
        compare(result.startTime, "2024-10-16T10:00:00Z", "Should return mock start time");
    }

    // UT-005: getCurrentTimerId() Tests
    function test_getCurrentTimerId_no_timer() {
        const result = mockService.getCurrentTimerId();
        compare(result, "", "Should return empty string when no timer");
    }

    function test_getCurrentTimerId_with_timer() {
        mockService.currentTimerId = "20241016T100000Z";
        const result = mockService.getCurrentTimerId();
        compare(result, "20241016T100000Z", "Should return correct timer ID");
    }

    // UT-006: updateTagHistory() Tests
    function test_updateTagHistory_new_tags() {
        const newTags = ["project", "urgent", "clientA"];
        mockService.updateTagHistory(newTags);

        compare(mockService.tagHistory.length, 3, "Should have 3 tags in history");
        verify(mockService.tagHistory.includes("project"), "Should include 'project'");
        verify(mockService.tagHistory.includes("urgent"), "Should include 'urgent'");
        verify(mockService.tagHistory.includes("clientA"), "Should include 'clientA'");
    }

    function test_updateTagHistory_duplicate_tags() {
        // Add initial tags
        mockService.tagHistory = ["project", "urgent"];

        // Add some duplicate and new tags
        const newTags = ["project", "clientA", "urgent"];
        mockService.updateTagHistory(newTags);

        compare(mockService.tagHistory.length, 3, "Should have 3 unique tags");
        verify(mockService.tagHistory.includes("project"), "Should include 'project'");
        verify(mockService.tagHistory.includes("urgent"), "Should include 'urgent'");
        verify(mockService.tagHistory.includes("clientA"), "Should include 'clientA'");
    }

    function test_updateTagHistory_size_limit() {
        // Add 105 tags
        const manyTags = [];
        for (let i = 0; i < 105; i++) {
            manyTags.push(`tag${i}`);
        }
        mockService.updateTagHistory(manyTags);

        compare(mockService.tagHistory.length, 100, "Should limit history to 100 tags");
        verify(!mockService.tagHistory.includes("tag0"), "Should drop oldest tags");
        verify(mockService.tagHistory.includes("tag104"), "Should keep newest tags");
    }

    // UT-007: mockModifyTimerTags() Tests
    function test_mockModifyTimerTags_success() {
        // Setup active timer
        mockService.timerActive = true;
        mockService.currentTags = ["project", "urgent"];
        mockService.currentTimerId = "20241016T100000Z";

        const newTags = ["project", "urgent", "debugging"];
        const result = mockService.mockModifyTimerTags("20241016T100000Z", newTags);

        verify(result, "Should return true on success");
        compare(mockService.currentTags.length, 3, "Should have 3 tags");
        verify(mockService.currentTags.includes("debugging"), "Should include new tag");
    }

    function test_mockModifyTimerTags_no_active_timer() {
        const result = mockService.mockModifyTimerTags("20241016T100000Z", ["test"]);
        verify(!result, "Should return false when no active timer");
    }

    function test_mockModifyTimerTags_invalid_timer_id() {
        mockService.timerActive = true;
        const result = mockService.mockModifyTimerTags("", ["test"]);
        verify(!result, "Should return false with invalid timer ID");
    }

    function test_mockModifyTimerTags_invalid_tags_array() {
        mockService.timerActive = true;
        const result = mockService.mockModifyTimerTags("20241016T100000Z", []);
        verify(!result, "Should return false with empty tags array");
    }
}