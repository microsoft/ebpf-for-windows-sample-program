# Testing Guide

## Overview

All sample programs should include tests to verify functionality and demonstrate proper eBPF usage.

## Test Structure

Organize tests in a `tests/` directory:

```
sample-program/
├── src/
│   └── program.c
├── tests/
│   ├── test_basic.c
│   └── validate.ps1
└── README.md
```

## Test Requirements

Each sample should include:

1. **Basic functionality tests** - Verify the program loads and runs
2. **Input validation** - Test with various inputs and edge cases
3. **Error handling** - Verify proper error handling and cleanup
4. **Documentation validation** - Ensure examples work as described

## Test Types

### Unit Tests
Test individual components using simple assertions:

```c
void test_map_operations() {
    assert(create_test_map() == 0);
    assert(insert_test_data() == 0);
    assert(cleanup_test_map() == 0);
}
```

### Integration Tests
Test complete workflows with scripts:

```powershell
# Basic integration test
$result = & ./sample_program.exe --test-mode
if ($LASTEXITCODE -ne 0) {
    Write-Error "Sample program failed"
    exit 1
}
```

### Load Tests
Verify eBPF program loading:

```c
int test_program_load() {
    int prog_fd = load_ebpf_program("program.o");
    if (prog_fd < 0) return -1;
    
    close(prog_fd);
    return 0;
}
```

## Best Practices

- **Keep tests simple** - Focus on clarity over complexity
- **Test error paths** - Include negative test cases
- **Clean up resources** - Always detach programs and free memory
- **Document expected behavior** - Include expected outputs in comments
- **Test on supported platforms** - Windows 10 1909+, Server 2019+

## Running Tests

Include test instructions in each sample's README.md:

```powershell
# Build and run tests
cd sample-name/tests
msbuild test.vcxproj
./test.exe
```

## Test Documentation

Document test cases with:
- Purpose and scope
- Setup requirements
- Expected results
- Cleanup procedures

For testing questions, create an issue or refer to the main eBPF for Windows documentation.