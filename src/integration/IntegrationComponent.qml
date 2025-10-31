import QtQuick 2.15
import qs_timew 2.0

/**
 * IntegrationComponent - High-level interface for qs-timew module
 *
 * This component provides a simplified API for integrating timewarrior
 * functionality into any Qt Quick application.
 */
QtObject {
    id: root

    // Reference to the service singleton
    readonly property var service: TimewarriorService

    // Basic API properties
    readonly property bool timerActive: TimewarriorService.timerActive
    readonly property var currentTags: TimewarriorService.currentTags
    readonly property string elapsedTime: TimewarriorService.formatElapsedTime(TimewarriorService.elapsedSeconds)
    readonly property bool timewAvailable: TimewarriorService.timewAvailable
    readonly property string errorMessage: TimewarriorService.errorMessage

    // Signals for external applications
    signal timerStarted(var tags)
    signal timerStopped()
    signal tagsUpdated(var oldTags, var newTags)
    signal error(string message)

    // Public API methods
    function startTimer(tags) {
        if (!tags || tags.length === 0) {
            root.error("Cannot start timer without tags");
            return false;
        }

        TimewarriorService.startTimer(tags);
        root.timerStarted(tags);
        return true;
    }

    function stopTimer() {
        if (!TimewarriorService.timerActive) {
            root.error("No active timer to stop");
            return false;
        }

        const tags = [...TimewarriorService.currentTags];
        TimewarriorService.stopTimer();
        root.timerStopped();
        return true;
    }

    function updateTags(newTags) {
        if (!TimewarriorService.timerActive) {
            root.error("No active timer to modify");
            return false;
        }

        const timerId = TimewarriorService.getCurrentTimerId();
        const oldTags = [...TimewarriorService.currentTags];

        return TimewarriorService.modifyTimerTags(timerId, newTags);
    }

    function getActiveTimer() {
        return TimewarriorService.getActiveTimer();
    }

    function validateTagInput(input) {
        return TimewarriorService.validateTags(input);
    }

    // Convenience methods for common operations
    function toggleTimer() {
        if (TimewarriorService.timerActive) {
            return stopTimer();
        } else {
            // For toggle, we'll need to get tags from somewhere
            // This is a placeholder - integration should handle tag input
            root.error("Toggle timer requires tags - use startTimer() with specific tags");
            return false;
        }
    }

    // Connections to service for signal forwarding
    Connections {
        target: TimewarriorService

        function onTagsUpdated(oldTags, newTags) {
            root.tagsUpdated(oldTags, newTags);
        }

        function onTagUpdateFailed(error) {
            root.error(error);
        }
    }
}