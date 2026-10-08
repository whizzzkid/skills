# Test Runner Examples

Run the project's test suite to establish a baseline before starting takeover work.
Adjust for the project's test command:

```bash
bundle exec rspec --format progress 2>&1 | tail -20   # Ruby
pytest -x -q 2>&1 | tail -20                          # Python
go test ./... 2>&1 | tail -20                         # Go
npm test -- --passWithNoTests 2>&1 | tail -20         # JS/TS
```

Record passing / failing / skipped. Failure from original author's work = a
**pre-existing failure** → document it, do not treat it as yours.
