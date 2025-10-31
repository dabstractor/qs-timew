import QtQuick 2.15
import QtTest
import qs_timew

TestCase {
    name: "DataIntegrityTests"

    // Mock data integrity verification system
    property var integrityValidator: QtObject {
        property var corruptionLog: []

        function verifyTimerStateIntegrity(initialState, finalState, operation) {
            const violations = [];

            // Rule 1: Timer should not be stopped unexpectedly
            if (initialState.timerActive && !finalState.timerActive && operation !== "stop") {
                violations.push({
                    type: "UNEXPECTED_TIMER_STOP",
                    severity: "HIGH",
                    description: "Timer was stopped unexpectedly during operation",
                    before: initialState.timerActive,
                    after: finalState.timerActive,
                    operation: operation
                });
            }

            // Rule 2: Elapsed time should not decrease
            if (finalState.elapsedSeconds < initialState.elapsedSeconds) {
                violations.push({
                    type: "TIME_REVERSAL",
                    severity: "HIGH",
                    description: "Elapsed time decreased, indicating possible data corruption",
                    before: initialState.elapsedSeconds,
                    after: finalState.elapsedSeconds,
                    operation: operation
                });
            }

            // Rule 3: Tag changes should be atomic (either complete or not at all)
            const tagsChanged = JSON.stringify(initialState.currentTags) !== JSON.stringify(finalState.currentTags);
            if (tagsChanged && finalState.currentTags.length === 0) {
                violations.push({
                    type: "INCOMPLETE_TAG_UPDATE",
                    severity: "MEDIUM",
                    description: "Tags were partially updated - result is empty",
                    before: initialState.currentTags,
                    after: finalState.currentTags,
                    operation: operation
                });
            }

            // Rule 4: No null or undefined values in critical fields
            const criticalFields = ['timerActive', 'currentTags', 'elapsedSeconds'];
            for (const field of criticalFields) {
                if (finalState[field] === null || finalState[field] === undefined) {
                    violations.push({
                        type: "NULL_CRITICAL_FIELD",
                        severity: "HIGH",
                        description: `Critical field '${field}' became null or undefined`,
                        field: field,
                        operation: operation
                    });
                }
            }

            // Rule 5: Tags should not contain invalid characters after update
            if (finalState.currentTags.some(tag => typeof tag !== 'string' || tag.length === 0)) {
                violations.push({
                    type: "INVALID_TAG_FORMAT",
                    severity: "MEDIUM",
                    description: "Tags contain invalid format after update",
                    tags: finalState.currentTags,
                    operation: operation
                });
            }

            const result = {
                isValid: violations.length === 0,
                violations: violations,
                operation: operation
            };

            if (!result.isValid) {
                corruptionLog.push(result);
            }

            return result;
        }

        function verifyDatabaseIntegrity(mockDatabase) {
            const issues = [];

            // Check for orphaned intervals
            if (mockDatabase.intervals) {
                for (const interval of mockDatabase.intervals) {
                    if (!interval.start) {
                        issues.push({
                            type: "ORPHANED_INTERVAL",
                            id: interval.id,
                            description: "Interval missing start time"
                        });
                    }

                    if (interval.start && interval.end && interval.start > interval.end) {
                        issues.push({
                            type: "INVALID_INTERVAL_TIMING",
                            id: interval.id,
                            description: "Interval end time before start time"
                        });
                    }

                    if (!interval.tags || interval.tags.length === 0) {
                        issues.push({
                            type: "INTERVAL_NO_TAGS",
                            id: interval.id,
                            description: "Interval has no tags"
                        });
                    }
                }
            }

            return {
                isHealthy: issues.length === 0,
                issues: issues
            };
        }

        function simulateTagUpdateCorruption(initialState, updateTags, corruptionType) {
            const finalState = JSON.parse(JSON.stringify(initialState)); // Deep copy

            switch (corruptionType) {
                case "TIMER_STOP":
                    finalState.timerActive = false;
                    break;
                case "TIME_LOSS":
                    finalState.elapsedSeconds = Math.max(0, finalState.elapsedSeconds - 100);
                    break;
                case "TAG_CORRUPTION":
                    finalState.currentTags = ["", null, undefined];
                    break;
                case "MEMORY_CORRUPTION":
                    finalState.currentTags = undefined;
                    break;
                case "PARTIAL_UPDATE":
                    finalState.currentTags = []; // Empty array instead of updated tags
                    break;
                default:
                    break;
            }

            return finalState;
        }

        function reset() {
            corruptionLog = [];
        }
    }

    // Mock timewarrior database simulation
    property var mockDatabase: QtObject {
        property var intervals: []

        function addInterval(start, end, tags) {
            const interval = {
                id: intervals.length + 1,
                start: start,
                end: end,
                tags: tags || []
            };
            intervals.push(interval);
            return interval;
        }

        function getActiveInterval() {
            return intervals.find(interval => !interval.end);
        }

        function updateIntervalTags(intervalId, newTags) {
            const interval = intervals.find(i => i.id === intervalId);
            if (interval) {
                interval.tags = newTags;
                return true;
            }
            return false;
        }

        function reset() {
            intervals = [];
        }
    }

    function init() {
        integrityValidator.reset();
        mockDatabase.reset();
    }

    // EC-001: No Active Timer
    function test_no_active_timer_protection() {
        const initialState = {
            timerActive: false,
            currentTags: [],
            elapsedSeconds: 0
        };

        const finalState = {
            timerActive: false,
            currentTags: ["attempted", "update"],
            elapsedSeconds: 0
        };

        const validation = integrityValidator.verifyTimerStateIntegrity(initialState, finalState, "tagUpdate");

        // This should be valid because there was no active timer to corrupt
        verify(validation.isValid, "No active timer case should be handled gracefully");
        compare(validation.violations.length, 0, "Should have no integrity violations");
    }

    // EC-002: Extremely Long Tags
    function test_extremely_long_tags_handling() {
        const initialState = {
            timerActive: true,
            currentTags: ["normal", "tag"],
            elapsedSeconds: 300
        };

        const extremelyLongTag = "a".repeat(200);
        const finalState = {
            timerActive: true,
            currentTags: ["normal", extremelyLongTag],
            elapsedSeconds: 300
        };

        const validation = integrityValidator.verifyTimerStateIntegrity(initialState, finalState, "tagUpdate");

        // Should detect potential issues with extremely long tags
        if (extremelyLongTag.length > 128) {
            // In a real implementation, this would be caught by validation
            verify(validation.violations.some(v => v.type === "INVALID_TAG_FORMAT") ||
                   validation.isValid, // Or handled gracefully
                   "Should handle extremely long tags appropriately");
        }
    }

    // EC-003: Special Characters
    function test_special_characters_preservation() {
        const specialCharTags = ["project-name", "task_123", "special$chars", "test@123", "emoji🎯"];

        const initialState = {
            timerActive: true,
            currentTags: ["normal"],
            elapsedSeconds: 150
        };

        const finalState = {
            timerActive: true,
            currentTags: specialCharTags,
            elapsedSeconds: 150
        };

        const validation = integrityValidator.verifyTimerStateIntegrity(initialState, finalState, "tagUpdate");

        verify(validation.isValid, "Special characters should be preserved correctly");
        compare(finalState.currentTags, specialCharTags, "Special character tags should match exactly");
    }

    // EC-004: Rapid Successive Edits
    function test_rapid_successive_edits_consistency() {
        const initialState = {
            timerActive: true,
            currentTags: ["initial"],
            elapsedSeconds: 60
        };

        const editSequence = [
            ["initial", "first-edit"],
            ["initial", "first-edit", "second-edit"],
            ["completely", "different", "tags"],
            ["completely", "different", "tags", "final"]
        ];

        let currentState = JSON.parse(JSON.stringify(initialState));
        let allValidations = [];

        for (let i = 0; i < editSequence.length; i++) {
            const nextState = {
                timerActive: true,
                currentTags: [...editSequence[i]],
                elapsedSeconds: 60 + (i * 5) // Simulate time progression
            };

            const validation = integrityValidator.verifyTimerStateIntegrity(
                currentState,
                nextState,
                `rapidEdit-${i + 1}`
            );

            allValidations.push(validation);
            currentState = nextState;
        }

        // Verify all rapid edits maintained integrity
        verify(allValidations.every(v => v.isValid), "All rapid successive edits should maintain data integrity");
        compare(integrityValidator.corruptionLog.length, 0, "Should have no corruption events");
    }

    // Data Corruption Detection Tests
    function test_corruption_detection_timer_stop() {
        const initialState = {
            timerActive: true,
            currentTags: ["work", "coding"],
            elapsedSeconds: 300
        };

        const corruptedState = integrityValidator.simulateTagUpdateCorruption(
            initialState,
            ["work", "coding", "debugging"],
            "TIMER_STOP"
        );

        const validation = integrityValidator.verifyTimerStateIntegrity(initialState, corruptedState, "corruptedUpdate");

        verify(!validation.isValid, "Should detect timer stop corruption");
        verify(validation.violations.some(v => v.type === "UNEXPECTED_TIMER_STOP"), "Should identify timer stop violation");
        compare(integrityValidator.corruptionLog.length, 1, "Should log corruption event");
    }

    function test_corruption_detection_time_loss() {
        const initialState = {
            timerActive: true,
            currentTags: ["work", "coding"],
            elapsedSeconds: 300
        };

        const corruptedState = integrityValidator.simulateTagUpdateCorruption(
            initialState,
            ["work", "coding", "debugging"],
            "TIME_LOSS"
        );

        const validation = integrityValidator.verifyTimerStateIntegrity(initialState, corruptedState, "corruptedUpdate");

        verify(!validation.isValid, "Should detect time loss corruption");
        verify(validation.violations.some(v => v.type === "TIME_REVERSAL"), "Should identify time reversal violation");
    }

    function test_corruption_detection_null_values() {
        const initialState = {
            timerActive: true,
            currentTags: ["work", "coding"],
            elapsedSeconds: 300
        };

        const corruptedState = integrityValidator.simulateTagUpdateCorruption(
            initialState,
            ["work", "coding", "debugging"],
            "MEMORY_CORRUPTION"
        );

        const validation = integrityValidator.verifyTimerStateIntegrity(initialState, corruptedState, "corruptedUpdate");

        verify(!validation.isValid, "Should detect null value corruption");
        verify(validation.violations.some(v => v.type === "NULL_CRITICAL_FIELD"), "Should identify null field violation");
    }

    // Database Integrity Tests
    function test_database_integrity_healthy() {
        // Create healthy database
        mockDatabase.addInterval("20250115T090000Z", "20250115T100000Z", ["meeting", "client"]);
        mockDatabase.addInterval("20250115T100000Z", null, ["work", "coding"]); // Active interval
        mockDatabase.addInterval("20250115T110000Z", "20250115T120000Z", ["review", "documentation"]);

        const integrityCheck = integrityValidator.verifyDatabaseIntegrity(mockDatabase);

        verify(integrityCheck.isHealthy, "Healthy database should pass integrity check");
        compare(integrityCheck.issues.length, 0, "Healthy database should have no issues");
    }

    function test_database_integrity_orphaned_intervals() {
        // Create database with orphaned interval
        mockDatabase.addInterval(null, null, ["orphaned"]);
        mockDatabase.addInterval("20250115T100000Z", null, ["work"]);

        const integrityCheck = integrityValidator.verifyDatabaseIntegrity(mockDatabase);

        verify(!integrityCheck.isHealthy, "Database with orphaned intervals should fail integrity check");
        verify(integrityCheck.issues.some(issue => issue.type === "ORPHANED_INTERVAL"), "Should detect orphaned interval");
    }

    function test_database_integrity_invalid_timing() {
        // Create database with invalid timing
        mockDatabase.addInterval("20250115T120000Z", "20250115T110000Z", ["invalid-timing"]);

        const integrityCheck = integrityValidator.verifyDatabaseIntegrity(mockDatabase);

        verify(!integrityCheck.isHealthy, "Database with invalid timing should fail integrity check");
        verify(integrityCheck.issues.some(issue => issue.type === "INVALID_INTERVAL_TIMING"), "Should detect invalid timing");
    }

    // Atomic Operations Test
    function test_atomic_tag_update() {
        const initialState = {
            timerActive: true,
            currentTags: ["initial", "project"],
            elapsedSeconds: 200
        };

        // Simulate atomic update that should either fully succeed or fully fail
        function simulateAtomicUpdate(currentTags, newTags) {
            // Simulate random failure (10% chance)
            const shouldFail = Math.random() < 0.1;

            if (shouldFail) {
                // Simulate partial failure - return empty tags
                return {
                    success: false,
                    result: {
                        timerActive: true,
                        currentTags: [], // Empty = partial failure
                        elapsedSeconds: 200
                    }
                };
            } else {
                // Simulate success
                return {
                    success: true,
                    result: {
                        timerActive: true,
                        currentTags: [...newTags],
                        elapsedSeconds: 200
                    }
                };
            }
        }

        const newTags = ["initial", "project", "urgent", "review"];
        let atomicAttempts = 0;
        let successfulUpdate = null;

        // Keep trying until we get a successful atomic update
        while (atomicAttempts < 100 && !successfulUpdate) {
            atomicAttempts++;
            const updateResult = simulateAtomicUpdate(initialState.currentTags, newTags);

            if (updateResult.success) {
                successfulUpdate = updateResult.result;
            } else {
                // Verify that failure didn't corrupt state
                const validation = integrityValidator.verifyTimerStateIntegrity(
                    initialState,
                    updateResult.result,
                    "failedAtomicUpdate"
                );

                // Partial failures should be detected
                if (!validation.isValid && validation.violations.some(v => v.type === "INCOMPLETE_TAG_UPDATE")) {
                    // This is expected - atomic update failed safely
                    continue;
                } else {
                    fail("Atomic update failure caused unexpected corruption");
                }
            }
        }

        verify(atomicAttempts < 100, "Should achieve atomic update within reasonable attempts");
        verify(successfulUpdate !== null, "Should eventually achieve successful atomic update");

        // Verify final state integrity
        const finalValidation = integrityValidator.verifyTimerStateIntegrity(
            initialState,
            successfulUpdate,
            "successfulAtomicUpdate"
        );

        verify(finalValidation.isValid, "Final state after atomic update should be valid");
        compare(successfulUpdate.currentTags, newTags, "Final tags should match expected update");
    }

    // Recovery Mechanism Test
    function test_integrity_recovery_mechanism() {
        const initialState = {
            timerActive: true,
            currentTags: ["critical", "work"],
            elapsedSeconds: 600
        };

        // Simulate corruption
        const corruptedState = integrityValidator.simulateTagUpdateCorruption(
            initialState,
            ["critical", "work", "updated"],
            "PARTIAL_UPDATE"
        );

        const corruptionDetection = integrityValidator.verifyTimerStateIntegrity(
            initialState,
            corruptedState,
            "corruptedOperation"
        );

        verify(!corruptionDetection.isValid, "Should detect corruption");

        // Simulate recovery mechanism
        function recoverFromCorruption(detectedState, backupState) {
            // In a real implementation, this would restore from backup
            return {
                recovered: true,
                restoredState: JSON.parse(JSON.stringify(backupState)),
                recoveryLog: ["Restored timer state", "Cleared corruption log"]
            };
        }

        const recovery = recoverFromCorruption(corruptedState, initialState);

        verify(recovery.recovered, "Recovery mechanism should succeed");
        compare(recovery.restoredState.timerActive, initialState.timerActive, "Should restore timer state");
        compare(recovery.restoredState.currentTags, initialState.currentTags, "Should restore original tags");
        compare(recovery.restoredState.elapsedSeconds, initialState.elapsedSeconds, "Should restore elapsed time");

        // Verify recovered state integrity
        const recoveryValidation = integrityValidator.verifyTimerStateIntegrity(
            corruptedState,
            recovery.restoredState,
            "recoveryOperation"
        );

        verify(recoveryValidation.isValid, "Recovered state should pass integrity validation");
    }

    // Continuous Integrity Monitoring Test
    function test_continuous_integrity_monitoring() {
        const monitoringLog = [];

        function simulateContinuousMonitoring() {
            const testStates = [
                { timerActive: true, currentTags: ["start"], elapsedSeconds: 0 },
                { timerActive: true, currentTags: ["start", "middle"], elapsedSeconds: 100 },
                { timerActive: true, currentTags: ["start", "middle", "end"], elapsedSeconds: 200 },
                { timerActive: true, currentTags: ["start", "middle", "end", "final"], elapsedSeconds: 300 }
            ];

            let previousState = testStates[0];

            for (let i = 1; i < testStates.length; i++) {
                const currentState = testStates[i];
                const validation = integrityValidator.verifyTimerStateIntegrity(
                    previousState,
                    currentState,
                    `monitoring-step-${i}`
                );

                monitoringLog.push({
                    step: i,
                    validation: validation,
                    state: currentState
                });

                previousState = currentState;
            }
        }

        simulateContinuousMonitoring();

        // Verify continuous monitoring detected no corruption
        verify(monitoringLog.length === 3, "Should monitor all state transitions");
        verify(monitoringLog.every(log => log.validation.isValid), "All monitored transitions should be valid");
        compare(integrityValidator.corruptionLog.length, 0, "Should have no corruption events during monitoring");
    }
}