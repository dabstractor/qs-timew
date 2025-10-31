# Contributing Guide

Guide for contributing to the qs-timew module, including development setup, coding standards, and contribution process.

## Table of Contents

- [Contributing Overview](#contributing-overview)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Coding Standards](#coding-standards)
- [Contribution Process](#contribution-process)
- [Testing Guidelines](#testing-guidelines)
- [Documentation Standards](#documentation-standards)
- [Code Review Process](#code-review-process)
- [Release Process](#release-process)
- [Community Guidelines](#community-guidelines)

## Contributing Overview

### Ways to Contribute

We welcome contributions in many forms:

- **Bug Reports**: Report issues with detailed reproduction steps
- **Feature Requests**: Suggest new features and improvements
- **Code Contributions**: Submit pull requests for fixes and features
- **Documentation**: Improve documentation and examples
- **Testing**: Write and improve test coverage
- **Translations**: Help translate UI text and documentation
- **Community Support**: Help other users on GitHub Discussions

### Contribution Types

| Type | Description | Requirements |
|------|-------------|----------------|
| **Bug Fix** | Fix a reported issue | Test case, documentation update |
| **Feature** | Add new functionality | Tests, documentation, API design |
| **Refactoring** | Improve code structure | Tests, compatibility notes |
| **Documentation** | Improve docs/examples | Clear, accurate information |
| **Performance** | Optimize performance | Benchmarks, before/after metrics |
| **Translation** | Add language support | Translation quality, cultural adaptation |

### Committer Expectations

Committers are expected to:

- Follow coding standards and best practices
- Write comprehensive tests for all changes
- Update documentation for API changes
- Participate in code review process
- Maintain backward compatibility when possible
- Respond to community issues and PRs

## Development Setup

### Prerequisites

```bash
# System requirements
- Qt 6.0 or higher
- QML development tools
- timewarrior 1.4 or higher
- Git
- Text editor/IDE with QML support

# Recommended tools
- Qt Creator (QML IDE)
- VS Code with QML extension
- Git client (SourceTree, GitKraken, etc.)
```

### Initial Setup

1. **Fork and Clone Repository:**
```bash
# Fork on GitHub, then clone your fork
git clone https://github.com/YOUR_USERNAME/qs-timew.git
cd qs-timew

# Add upstream remote
git remote add upstream https://github.com/dustin-s/qs-timew.git
```

2. **Install Development Dependencies:**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install qt6-base-dev qt6-declarative-dev qt6-tools-dev
sudo apt install qml6-test-tools timewarrior

# Fedora/CentOS
sudo dnf install qt6-qtbase-devel qt6-qtdeclarative-devel
sudo dnf install timewarrior

# Arch Linux
sudo pacman -S qt6-base qt6-declarative qt6-tools
sudo pacman -S timew
```

3. **Verify Setup:**
```bash
# Run tests to verify setup
qmltestrunner -input tests/TestRunner.qml

# Test basic functionality
qmlscene -I . examples/MinimalExample.qml
```

### Development Environment

#### Qt Creator Setup

1. Open Qt Creator
2. File → Open File or Project
3. Select `qs-timew` directory
4. Configure as "Import Existing Project"
5. Set up build configuration:
   - Build directory: `build/`
   - QML import path: `.` (project root)
   - Kit: Qt 6.x

#### VS Code Setup

1. Install recommended extensions:
   - QML
   - Qt for Python
   - GitLens
   - Better Comments

2. Create `.vscode/settings.json`:
```json
{
    "qml.formatter.style": "qml",
    "qml.importPaths": ["${workspaceFolder}"],
    "files.exclude": {
        "**/.git": true,
        "**/build": true
    },
    "editor.formatOnSave": true,
    "editor.rulers": [80, 120]
}
```

3. Create `.vscode/tasks.json`:
```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Run Tests",
            "type": "shell",
            "command": "qmltestrunner",
            "args": ["-input", "tests/TestRunner.qml"],
            "group": "test",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "Run Example",
            "type": "shell",
            "command": "qmlscene",
            "args": ["-I .", "examples/CompleteExample.qml"],
            "group": "build"
        }
    ]
}
```

## Project Structure

### Directory Organization

```
qs-timew/
├── src/                          # Source code
│   ├── services/                 # Service layer
│   │   └── TimewarriorService.qml
│   ├── widgets/                  # UI components
│   │   └── TimewarriorWidget.qml
│   └── integration/              # High-level API
│       └── IntegrationComponent.qml
├── examples/                     # Usage examples
│   ├── MinimalExample.qml
│   ├── CompleteExample.qml
│   └── CustomIntegration.qml
├── tests/                        # Test suite
│   ├── TestRunner.qml
│   ├── unit/                     # Unit tests
│   ├── integration/              # Integration tests
│   ├── performance/              # Performance tests
│   └── validation/               # Validation tests
├── docs/                         # Documentation
│   ├── api-reference.md
│   ├── installation.md
│   └── usage-examples.md
├── scripts/                      # Build and utility scripts
│   ├── build.sh
│   ├── test.sh
│   └── release.sh
├── package.json                  # Package metadata
├── README.md                     # Main documentation
├── LICENSE                       # License file
└── .gitignore                    # Git ignore rules
```

### File Naming Conventions

- **QML Files**: PascalCase (e.g., `TimewarriorService.qml`)
- **JavaScript Files**: camelCase (e.g., `tagParser.js`)
- **Documentation**: kebab-case (e.g., `api-reference.md`)
- **Test Files**: PascalCase + "Tests" (e.g., `ServiceTests.qml`)

### Module Structure

Each component follows this structure:

```
ComponentName.qml                 # Main component file
ComponentNameTest.qml            # Component tests (if applicable)
ComponentName.md                 # Component documentation
```

## Coding Standards

### QML Style Guide

#### File Header

Every QML file should start with a header:

```qml
/**
 * ComponentName - Brief description of component
 *
 * Detailed description of the component's purpose,
 * usage, and important implementation details.
 *
 * @author Your Name <your.email@example.com>
 * @since 1.0.0
 */

import QtQuick
import QtQuick.Controls
import qs_timew 2.0
```

#### Import Organization

```qml
// Qt imports first, sorted alphabetically
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

// Third-party imports
import some.third.party.library

// Local imports
import qs_timew 2.0
import "./components"
```

#### Property Declaration

```qml
Item {
    id: root

    // Public properties (API)
    property bool timerActive: false
    property var currentTags: []
    property alias backgroundColor: background.color

    // Private properties (internal use)
    property bool _internalState: false
    property var _privateData: null

    // Constants
    readonly property int MAX_TAGS: 100
    readonly property string DEFAULT_TAG: "default"
}
```

#### Signal Declaration

```qml
// Signals with parameter documentation
signal timerStarted(var tags)
signal timerStopped()
signal error(string message)
signal tagsUpdated(var oldTags, var newTags)

// Signal handlers
onTimerStarted: function(tags) {
    console.log("Timer started with tags:", tags)
}
```

#### Function Declaration

```qml
// Public functions
function startTimer(tags) {
    if (!validateTags(tags)) {
        return false
    }

    _executeTimerCommand(tags)
    return true
}

// Private functions (prefix with _)
function _validateTags(tags) {
    return tags && tags.length > 0
}

function _executeTimerCommand(tags) {
    // Implementation details
}
```

#### Component Organization

```qml
Rectangle {
    id: root

    // Properties
    property alias text: label.text

    // Signals
    signal clicked()

    // Components
    Text {
        id: label
        anchors.centerIn: parent
    }

    // Event handlers
    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }

    // States
    states: [
        State {
            name: "pressed"
            when: mouseArea.pressed
        }
    ]

    // Transitions
    transitions: [
        Transition {
            from: "normal"
            to: "pressed"
            ColorAnimation { duration: 100 }
        }
    ]
}
```

### JavaScript Style Guide

#### Variable Declaration

```javascript
// Use const for constants
const MAX_TAGS = 100;

// Use let for variables that will be reassigned
let currentTags = [];

// Use var only when necessary (avoid in new code)
var legacyVariable = null;
```

#### Function Declaration

```javascript
// Arrow functions for callbacks
const callback = (result) => {
    console.log("Result:", result);
};

// Regular functions for methods
function validateTag(tag) {
    return tag && tag.length > 0;
}

// Async functions
async function fetchTags() {
    try {
        const response = await fetch("/api/tags");
        return await response.json();
    } catch (error) {
        console.error("Failed to fetch tags:", error);
        return [];
    }
}
```

#### Error Handling

```javascript
function riskyOperation() {
    try {
        // Risky code
        return result;
    } catch (error) {
        console.error("Operation failed:", error);
        // Fallback behavior
        return defaultValue;
    }
}
```

### Code Quality Rules

1. **Line Length**: Maximum 120 characters
2. **Indentation**: 4 spaces (no tabs)
3. **Spacing**: Space around operators and after commas
4. **Comments**: Comment complex logic, not obvious code
5. **TODOs**: Use `// TODO: description` format with GitHub issue reference
6. **Magic Numbers**: Replace with named constants

## Contribution Process

### Workflow Overview

1. **Create Issue**: Discuss planned changes in an issue
2. **Create Branch**: Create feature branch from `develop`
3. **Develop Code**: Implement changes with tests
4. **Test Thoroughly**: Ensure all tests pass
5. **Submit PR**: Create pull request with description
6. **Code Review**: Address feedback from reviewers
7. **Merge**: PR merged to `develop` branch

### Branch Strategy

```
main                    # Stable releases
├── develop             # Integration branch
├── feature/feature-name # Feature branches
├── bugfix/issue-number  # Bug fix branches
└── release/vX.Y.Z      # Release branches
```

### Creating a Feature Branch

```bash
# Ensure latest develop branch
git checkout develop
git pull upstream develop

# Create feature branch
git checkout -b feature/your-feature-name

# Start development
```

### Commit Guidelines

#### Commit Message Format

```
type(scope): brief description

Detailed explanation of the change,
including motivation and implementation
notes. Wrap at 72 characters.

Fixes #issue-number
```

#### Commit Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring without functional changes
- `test`: Adding or modifying tests
- `chore`: Maintenance tasks, dependency updates
- `perf`: Performance improvements

#### Examples

```
feat(widget): add tag history autocomplete

Implement autocomplete functionality for tag input using
recent tag history. Improve user experience by reducing
typing for frequently used tags.

Fixes #123

fix(service): handle empty tag validation

Add proper validation for empty tag input to prevent
errors when users submit forms without tags.

docs(api): update IntegrationComponent documentation

Add examples for new API methods and clarify parameter
types. Update usage examples to reflect new features.
```

### Pull Request Process

#### PR Template

```markdown
## Description
Brief description of the changes made in this PR.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] All tests pass
- [ ] New tests added for new functionality
- [ ] Manual testing completed

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Breaking changes documented
- [ ] No merge conflicts

## Issues
Closes #issue-number

## Screenshots
Add screenshots for UI changes if applicable.

## Additional Notes
Any additional information reviewers should know.
```

#### Review Guidelines

Reviewers should check:

1. **Functionality**: Does the code work as intended?
2. **Tests**: Are tests comprehensive and passing?
3. **Documentation**: Is documentation updated and accurate?
4. **Style**: Does code follow project standards?
5. **Performance**: Any performance implications?
6. **Security**: Any security concerns?
7. **Compatibility**: Does it maintain backward compatibility?

## Testing Guidelines

### Test Coverage Requirements

- **New Features**: 100% test coverage for new code
- **Bug Fixes**: Test case that reproduces the bug and verifies the fix
- **Refactoring**: All existing tests must continue to pass
- **Critical Paths**: All user-facing functionality must be tested

### Test Structure

#### Unit Tests

```qml
// tests/unit/ComponentNameTests.qml
import QtQuick
import QtTest
import qs_timew 2.0

TestCase {
    name: "ComponentNameTests"

    Component {
        id: componentUnderTest
        ComponentName {}
    }

    function init() {
        // Setup before each test
    }

    function cleanup() {
        // Cleanup after each test
    }

    function test_basic_functionality() {
        // Test implementation
        const component = createObject(componentUnderTest)
        verify(component !== null, "Component should be created")

        // Test specific functionality
        component.someProperty = true
        compare(component.someProperty, true, "Property should be set")

        component.destroy()
    }
}
```

#### Integration Tests

```qml
// tests/integration/WorkflowTests.qml
import QtQuick
import QtTest
import qs_timew 2.0

TestCase {
    name: "WorkflowTests"

    IntegrationComponent {
        id: integration
    }

    function test_complete_workflow() {
        // Test complete user workflow
        integration.startTimer(["test", "workflow"])
        wait(1000) // Wait for async operation

        verify(integration.timerActive, "Timer should be active")

        integration.updateTags(["test", "workflow", "updated"])
        wait(1000)

        verify(integration.currentTags.includes("updated"), "Tags should be updated")

        integration.stopTimer()
        wait(1000)

        verify(!integration.timerActive, "Timer should be stopped")
    }
}
```

#### Performance Tests

```qml
// tests/performance/PerformanceTests.qml
import QtQuick
import QtTest
import qs_timew 2.0

TestCase {
    name: "PerformanceTests"

    function test_tag_parsing_performance() {
        const tags = []
        for (let i = 0; i < 1000; i++) {
            tags.push(`performance_tag_${i}`)
        }

        const startTime = performance.now()
        const result = timew.validateTagInput(tags.join(" "))
        const endTime = performance.now()
        const duration = endTime - startTime

        verify(result.isValid, "Should validate large tag array")
        verify(duration < 100, `Should parse 1000 tags in < 100ms (took ${duration}ms)`)
    }
}
```

### Running Tests

```bash
# Run all tests
qmltestrunner -input tests/TestRunner.qml

# Run specific test categories
qmltestrunner -input tests/unit/
qmltestrunner -input tests/integration/
qmltestrunner -input tests/performance/

# Run with coverage
qmltestrunner -input tests/TestRunner.qml -coverage

# Run in verbose mode
qmltestrunner -input tests/TestRunner.qml -verbose
```

## Documentation Standards

### Documentation Types

1. **API Documentation**: Inline code comments
2. **User Documentation**: README, guides, tutorials
3. **Developer Documentation**: Architecture, contributing guide
4. **Examples**: Working code examples

### API Documentation

#### Component Documentation

```qml
/**
 * ComponentName - Brief description
 *
 * Detailed description of the component's purpose,
 * usage patterns, and important implementation notes.
 *
 * Example usage:
 * ```qml
 * ComponentName {
 *     property: "value"
 * }
 * ```
 *
 * @property type propertyName Property description
 * @signal signalName(string parameter) Signal description
 * @method returnTypeName methodName(type param) Method description
 * @since 1.0.0
 */
Item {
    // Component implementation
}
```

#### Property Documentation

```qml
/**
 * Timer active state
 *
 * @type bool
 * @default false
 */
property bool timerActive: false

/**
 * Current timer tags
 *
 * Array of strings representing the tags associated with
 * the currently active timer. Empty array when no timer
 * is active.
 *
 * @type array<string>
 * @readonly
 */
property var currentTags: []
```

#### Method Documentation

```qml
/**
 * Start a new timer with the specified tags
 *
 * Creates a new timewarrior timer with the provided tags.
 * Returns true if the timer was started successfully,
 * false if there was an error.
 *
 * @param {array<string>} tags - Tags to associate with the timer
 * @returns {bool} True if successful, false otherwise
 * @signal timerStarted(tags) Emitted when timer starts
 *
 * @example
 * ```qml
 * const success = timew.startTimer(["work", "project"])
 * if (success) {
 *     console.log("Timer started successfully")
 * }
 * ```
 */
function startTimer(tags) {
    // Implementation
}
```

### User Documentation

#### README Structure

```markdown
# Project Name

Brief description and overview.

## Quick Start
Simple getting started instructions.

## Installation
Detailed installation instructions.

## Usage
Basic usage examples.

## API Reference
Link to detailed API documentation.

## Contributing
Link to contributing guidelines.

## License
License information.
```

#### Guide Structure

```markdown
# Guide Title

## Overview
Brief introduction to the topic.

## Prerequisites
What users need before starting.

## Step-by-Step Instructions
Detailed steps with code examples.

## Common Issues
Frequently encountered problems and solutions.

## Next Steps
Related topics and further reading.
```

### Example Documentation

#### Example Structure

```qml
/**
 * ExampleTitle - Brief description
 *
 * This example demonstrates how to use specific features
 * of the qs-timew module.
 *
 * Run with: qmlscene -I . examples/ExampleTitle.qml
 *
 * @since 1.0.0
 */
import QtQuick
import QtQuick.Controls
import qs_timew 2.0

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "Example Title"

    // Example implementation
    IntegrationComponent {
        id: timew
    }

    // UI components demonstrating the feature
    // ...
}
```

#### Code Comments

```qml
// Initialize the integration component
IntegrationComponent {
    id: timew

    // Handle timer events
    onTimerStarted: function(tags) {
        // Log the timer start for debugging
        console.log("Timer started:", tags.join(", "))

        // Update UI to show active state
        statusLabel.text = "Timer active: " + tags.join(", ")
    }
}
```

## Code Review Process

### Review Checklist

#### Functionality
- [ ] Code works as intended
- [ ] All edge cases are handled
- [ ] Error handling is appropriate
- [ ] No unintended side effects

#### Code Quality
- [ ] Follows project coding standards
- [ ] Code is readable and maintainable
- [ ] No duplicate code
- [ ] Appropriate use of design patterns

#### Testing
- [ ] Tests are comprehensive
- [ ] All tests pass
- [ ] Tests cover edge cases
- [ ] Performance tests if applicable

#### Documentation
- [ ] API documentation is complete
- [ ] User documentation is updated
- [ ] Examples are provided
- [ ] Comments are clear and useful

#### Security
- [ ] No security vulnerabilities
- [ ] Input validation is appropriate
- [ ] Error messages don't leak sensitive information
- [ ] Dependencies are secure

### Review Process

1. **Self-Review**: Review your own code before submitting
2. **Automated Checks**: CI/CD runs automated tests and checks
3. **Peer Review**: At least one team member reviews the PR
4. **Approval**: Reviewer approves changes
5. **Merge**: Changes are merged to target branch

### Review Feedback

#### Providing Feedback

```markdown
## General Feedback
Great work on this feature! The implementation looks solid.

## Suggestions
1. Consider adding input validation for edge cases
2. The method name could be more descriptive
3. Add unit tests for the new functionality

## Issues
1. Line 45: Potential null reference exception
2. Missing error handling for network failures
3. Performance could be optimized with caching

## Approval
Once the above issues are addressed, this will be ready to merge.
```

#### Addressing Feedback

1. **Acknowledge**: Respond to all feedback points
2. **Explain**: If disagreeing, explain your reasoning
3. **Implement**: Make necessary changes
4. **Verify**: Ensure all tests still pass
5. **Update PR**: Mark issues as resolved

## Release Process

### Version Management

qs-timew follows Semantic Versioning (SemVer):

- **Major (X.0.0)**: Breaking changes
- **Minor (X.Y.0)**: New features (backward compatible)
- **Patch (X.Y.Z)**: Bug fixes (backward compatible)

### Release Checklist

#### Pre-Release

- [ ] All tests passing
- [ ] Documentation updated
- [ ] Version number updated
- [ ] CHANGELOG updated
- [ ] Performance benchmarks met
- [ ] Security review completed

#### Release Steps

1. **Create Release Branch**
```bash
git checkout develop
git pull upstream develop
git checkout -b release/vX.Y.Z
```

2. **Update Version Numbers**
```qml
// Update in package.json and any version constants
```

3. **Update CHANGELOG**
```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New feature description

### Changed
- Modified feature description

### Fixed
- Bug fix description

### Security
- Security fix description
```

4. **Final Testing**
```bash
# Run full test suite
./scripts/test.sh

# Run performance benchmarks
./scripts/benchmark.sh
```

5. **Tag and Push**
```bash
git add .
git commit -m "chore: prepare v.X.Y.Z release"
git tag -a v.X.Y.Z -m "Release v.X.Y.Z"
git push upstream develop
git push upstream v.X.Y.Z
```

6. **Create GitHub Release**
- Go to GitHub Releases page
- Click "Create a new release"
- Select the tag
- Add release notes
- Publish release

#### Post-Release

1. **Merge to Main**
```bash
git checkout main
git pull upstream main
git merge release/vX.Y.Z
git push upstream main
```

2. **Update Development**
```bash
git checkout develop
git merge main
git push upstream develop
```

3. **Announce Release**
- Update documentation website
- Post release notes to community
- Update package managers if applicable

## Community Guidelines

### Code of Conduct

We are committed to providing a welcoming and inclusive environment. Please:

- Be respectful and considerate
- Use inclusive language
- Focus on constructive feedback
- Welcome newcomers and help them learn
- Assume good intent

### Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and discussions
- **Pull Requests**: Code contributions and reviews
- **Email**: Private security concerns only

### Getting Help

1. **Search First**: Check existing issues and documentation
2. **Create Issue**: Provide detailed information and reproduction steps
3. **Be Patient**: Community maintainers volunteer their time
4. **Follow Up**: Provide additional information when requested

### Recognition

Contributors are recognized in several ways:

- **AUTHORS file**: List of all contributors
- **Release Notes**: Acknowledgment of contributors
- **GitHub Contributors**: Visible contributor list
- **Community Posts**: Highlighting significant contributions

Thank you for contributing to qs-timew! Your contributions help make time tracking better for everyone.