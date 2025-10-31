# qs-timew Test Suite

Test suite for the standalone qs-timew module (v2.0), providing comprehensive testing of timewarrior functionality.

## Overview

This test suite validates all aspects of the qs-timew module:

- **Module Import Tests**: Verify module loading and component availability
- **Unit Tests**: Test individual TimewarriorService functions
- **Integration Tests**: Test complete tag editing workflows
- **Performance Tests**: Validate performance characteristics and benchmarks
- **Data Integrity Tests**: Ensure data safety and corruption detection
- **Standalone Widget Tests**: Test widget functionality in isolation

## Test Structure

```
tests/
├── README.md                     # This file
├── test-config.json              # Test configuration and benchmarks
├── TestUtils.qml                 # Common test utilities and helpers
├── TestRunner.qml                # Main test runner application
├── module/
│   └── ModuleImportTests.qml     # Module import and availability tests
├── unit/
│   └── TimewarriorServiceTagEditTests.qml  # Core functionality tests
├── integration/
│   └── TagEditWorkflowTests.qml  # End-to-end workflow tests
├── performance/
│   └── TagUpdatePerformanceTests.qml       # Performance and load tests
└── validation/
    ├── DataIntegrityTests.qml   # Data integrity and corruption tests
    └── StandaloneWidgetTest.qml # Standalone widget tests
```

## Running Tests

### Using the Test Runner

The main test runner provides a graphical interface for executing all tests:

```bash
qmlscene tests/TestRunner.qml
```

### Running Individual Test Suites

You can run individual test suites using Qt's test framework:

```bash
# Run unit tests only
qmltestrunner -input tests/unit/TimewarriorServiceTagEditTests.qml

# Run integration tests only
qmltestrunner -input tests/integration/TagEditWorkflowTests.qml

# Run performance tests only
qmltestrunner -input tests/performance/TagUpdatePerformanceTests.qml

# Run validation tests only
qmltestrunner -input tests/validation/DataIntegrityTests.qml
```

## Test Categories

### Module Import Tests
- Verify the qs-timew module can be imported correctly
- Test TimewarriorService singleton availability
- Test TimewarriorWidget component availability
- Test QmlIntegration component availability
- Validate module versioning (2.0)
- Test component instantiation and API surface

### Unit Tests
- **Tag Parsing**: Test various input formats and separators
- **Timer State Preservation**: Ensure elapsed time is preserved during tag updates
- **Tag Validation**: Test tag format validation and error handling
- **Performance**: Validate performance of core operations
- **Helper Functions**: Test utility functions like getActiveTimer(), getCurrentTimerId()

### Integration Tests
- **Complete Workflow**: Test full tag edit workflow from start to finish
- **Concurrent State Changes**: Test handling of external timer state changes
- **Error Recovery**: Test graceful handling of invalid tags and errors
- **State Consistency**: Verify state transitions are consistent throughout workflows

### Performance Tests
- **Tag Parsing Latency**: Measure and validate tag parsing performance
- **Tag Validation Latency**: Measure and validate tag validation performance
- **Timer State Update Latency**: Measure and validate timer update performance
- **UI Update Latency**: Measure and validate UI update performance
- **Memory Usage**: Test memory efficiency and detect potential leaks
- **End-to-End Performance**: Test complete workflow performance
- **Load Testing**: Test performance under concurrent operations
- **Regression Detection**: Establish performance baselines and detect regressions

### Data Integrity Tests
- **Corruption Detection**: Test detection of various types of data corruption
- **Atomic Operations**: Test that tag updates are atomic (either complete or not at all)
- **Database Integrity**: Test timewarrior database integrity validation
- **Recovery Mechanisms**: Test recovery from corrupted states
- **Continuous Monitoring**: Test continuous integrity monitoring

### Standalone Widget Tests
- **Basic Properties**: Test widget configuration and properties
- **State Transitions**: Test widget state changes (start/stop timer)
- **Tag Validation**: Test widget-level tag validation
- **Tag Editing**: Test widget tag editing functionality
- **Time Formatting**: Test time display formatting
- **Signal Handling**: Test widget signal emission and handling

## Test Configuration

The test suite is configured via `test-config.json`, which includes:

- **Performance Benchmarks**: Maximum acceptable times for various operations
- **Memory Limits**: Acceptable memory usage limits
- **Test Scenarios**: Predefined test scenarios for common use cases
- **Success Criteria**: Clear criteria for test success
- **Edge Cases**: Specific edge cases to test

## Performance Benchmarks

The test suite validates the following performance benchmarks:

| Operation | Small Input | Medium Input | Large Input |
|-----------|-------------|--------------|-------------|
| Tag Parsing | < 10ms | < 20ms | < 50ms |
| Tag Validation | < 5ms (2 tags) | < 20ms (50 tags) | < 10ms (3 tags) |
| Timer Update | < 100ms (simple) | < 200ms (complex) | - |
| UI Update | < 50ms (2 tags) | < 100ms (20 tags) | - |
| End-to-End Workflow | < 500ms average | < 1000ms max | - |

## Success Criteria

All tests must meet these success criteria:

- **Module Tests**: 100% pass rate - Module must import correctly
- **Unit Tests**: 100% pass rate - All core functionality must work
- **Integration Tests**: 100% pass rate - Complete workflows must work
- **Performance Tests**: All benchmarks met - Performance requirements satisfied
- **Data Integrity**: Zero data corruption - Data safety verified

## RED-GREEN Testing

The test suite follows RED-GREEN methodology:

1. **RED Phase**: Tests fail initially during development
2. **GREEN Phase**: Implementation makes tests pass
3. Loop continues until ALL tests pass

The test runner provides clear feedback on which tests are failing and why.

## Test Utilities

The `TestUtils.qml` component provides common testing utilities:

- **Mock Objects**: Timer, database, and service mocks
- **Data Generators**: Generate test data (valid/invalid tags, scenarios)
- **Performance Measurement**: Measure execution times and statistics
- **Assertion Helpers**: Custom assertions for common test cases
- **Scenario Runner**: Run multiple test scenarios and summarize results
- **Signal Testing**: Capture and verify signal emissions
- **Error Simulation**: Simulate various error conditions
- **Cleanup Utilities**: Ensure test isolation and cleanup

## Mock Services

Since this is a standalone module, tests use comprehensive mock services:

- **MockTimerService**: Simulates timewarrior timer operations
- **MockDatabase**: Simulates timewarrior database operations
- **MockEnvironment**: Simulates complete testing environment

## Continuous Integration

These tests are designed to run in CI/CD environments:

- No external dependencies required
- All mock services are self-contained
- Clear pass/fail criteria
- Performance regression detection
- Comprehensive logging

## Contributing

When adding new tests:

1. Follow the existing test structure and naming conventions
2. Use `TestUtils.qml` for common operations
3. Add appropriate test scenarios to `test-config.json`
4. Update this README if adding new test categories
5. Ensure tests are deterministic and don't leave side effects

## Troubleshooting

### Tests Fail to Import Module
- Ensure the qmldir file is properly configured
- Check that module registration is working
- Verify component paths in qmldir

### Performance Tests Fail
- Check system load during test execution
- Verify benchmarks are appropriate for your environment
- Consider adjusting timeout values in test-config.json

### Integration Tests Fail
- Ensure mock services are properly initialized
- Check test scenario data for consistency
- Verify state cleanup between tests

### Memory Tests Fail
- Check for memory leaks in test code
- Ensure proper cleanup in test teardown
- Verify mock service memory management

## License

This test suite is part of the qs-timew module and follows the same license terms.