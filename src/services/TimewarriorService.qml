import QtQuick 2.15
import "qrc:/components"

pragma Singleton
pragma ComponentBehavior: Bound

Singleton {
    id: root

    // Core state properties (8 essential properties)
    readonly property bool active: internal.timerActive
    readonly property string status: internal.errorMessage || (internal.timerActive ? "Active" : "Idle")
    readonly property var tags: internal.currentTags
    readonly property string elapsed: internal.elapsedTime
    readonly property Component currentDisplay: displayComponent
    readonly property bool error: internal.errorMessage.length > 0
    readonly property string errorMessage: internal.errorMessage
    readonly property bool timewAvailable: internal.timewAvailable

    // Internal state
    QtObject {
        id: internal

        property bool timerActive: false
        property var currentTags: []
        property string elapsedTime: "00:00:00"
        property string errorMessage: ""
        property bool timewAvailable: false
        property var activeTimerId: null
        property var lastUsedTags: []

        // Process for timewarrior commands
        property var process: Process {
            running: false

            onFinished: {
                try {
                    const data = JSON.parse(stdout)
                    parseTimerState(data)
                    internal.errorMessage = ""
                } catch (e) {
                    internal.errorMessage = "Failed to parse timewarrior output"
                }
                running = false
            }

            onError: {
                internal.errorMessage = `Timewarrior error: ${exitCode}`
                running = false
            }
        }

        // Polling timer
        Timer {
            interval: 2000
            running: true
            repeat: true
            onTriggered: refreshState()
        }

        function refreshState() {
            if (process.running) return

            process.command = ["timew", "export"]
            process.running = true
        }

        function parseTimerState(data) {
            const active = data.filter(entry => !entry.end)
            internal.timerActive = active.length > 0

            if (active.length > 0) {
                const timer = active[0]
                internal.currentTags = timer.tags || []
                internal.activeTimerId = timer.id
                internal.lastUsedTags = internal.currentTags

                const startTime = new Date(timer.start)
                const now = new Date()
                const elapsed = Math.floor((now - startTime) / 1000)
                internal.elapsedTime = formatTime(elapsed)
            } else {
                internal.currentTags = []
                internal.activeTimerId = null
                internal.elapsedTime = "00:00:00"
            }
        }

        function formatTime(seconds) {
            const hours = Math.floor(seconds / 3600)
            const minutes = Math.floor((seconds % 3600) / 60)
            const secs = seconds % 60
            return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(secs).padStart(2, '0')}`
        }

        function executeCommand(cmd, tags) {
            const command = ["timew", cmd]
            if (tags && tags.length > 0) {
                command.push(...tags)
            }

            const execProcess = Process {
                command: command

                onFinished: {
                    if (exitCode === 0) {
                        internal.refreshState()
                    }
                    destroy()
                }

                onError: {
                    internal.errorMessage = `Command failed: ${exitCode}`
                    destroy()
                }
            }
        }
    }

    // Display component provider
    property Component displayComponent: Component {
        Item {
            anchors.fill: parent

            Column {
                anchors.centerIn: parent
                spacing: 5

                Text {
                    text: root.active ? "⏱" : "⏹"
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.sizes.large * 2
                    color: root.error ? "#BA1A1A" : Appearance.colors.colOnLayer1
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: root.tags.join(" ") || "No tags"
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.sizes.medium
                    color: Appearance.colors.colOnLayer1
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: root.elapsed
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.sizes.medium
                    color: Appearance.colors.colOnLayer1
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    visible: root.error
                    text: root.errorMessage
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.sizes.small
                    color: "#BA1A1A"
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    // Core commands (4 essential methods)
    function toggle() {
        if (internal.timerActive) {
            stop()
        } else {
            if (internal.lastUsedTags.length > 0) {
                start(internal.lastUsedTags)
            } else {
                showInput()
            }
        }
    }

    function start(tags) {
        if (!tags || tags.length === 0) return
        internal.executeCommand("start", tags)
        internal.lastUsedTags = tags
    }

    function stop() {
        internal.executeCommand("stop")
    }

    function updateTags(tags) {
        if (!tags || tags.length === 0) return
        internal.executeCommand("retag", tags)
    }

    // UI helpers (2 essential methods)
    function handleClick() {
        toggle()
    }

    function showInput() {
        PopupManager.showInput(function(tags) {
            start(tags)
        })
    }

    function showEdit() {
        PopupManager.showEdit(internal.currentTags, function(tags) {
            updateTags(tags)
        })
    }

    // Initialize
    Component.onCompleted: {
        internal.refreshState()
    }
}