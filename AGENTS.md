# CLAUDE.md

This file provides guidance to AI coding assistants when working with code in this repository.

## Project Overview

BB.Servo.Pigpio is an Elixir library that provides Beam Bots (BB) integration for driving RC servos via pigpio on Raspberry Pi. It implements actuator and sensor modules that integrate with the BB robot framework's joint system.

## Build and Development Commands

```bash
# Run all checks (compile, tests, dialyzer, credo, formatting, etc.)
mix check --no-retry

# Run tests
mix test

# Run a single test file
mix test test/bb/servo/pigpio/actuator_test.exs

# Run a specific test by line number
mix test test/bb/servo/pigpio/actuator_test.exs:36

# Format code
mix format

# Generate documentation
mix docs
```

## Architecture

### Core Components

**Actuator** (`lib/bb/servo/pigpio/actuator.ex`)
- GenServer that controls servo position via PWM through pigpiox
- Derives position limits and velocity from BB joint constraints
- Maps joint position range to PWM pulse width range (default 500-2500µs)
- Publishes `PositionCommand` messages after each command for sensor coordination

**Sensor** (`lib/bb/servo/pigpio/sensor.ex`)
- GenServer that provides position feedback by subscribing to actuator commands
- Interpolates position during movement based on velocity and expected arrival time
- Publishes `JointState` messages at configurable rate (default 50Hz)

**PositionCommand Message** (`lib/bb/servo/pigpio/message/position_command.ex`)
- Internal message type for actuator-to-sensor communication
- Contains target position and expected arrival time

### Integration Pattern

The actuator and sensor are designed to be used together within a BB robot joint definition:

```elixir
joint :shoulder, type: :revolute do
  limit lower: ~u(-45 degree), upper: ~u(45 degree), velocity: ~u(60 degree_per_second)

  actuator :servo, {BB.Servo.Pigpio.Actuator, pin: 17}
  sensor :feedback, {BB.Servo.Pigpio.Sensor, actuator: :servo}
end
```

### Key Dependencies

- `bb` - Beam Bots robot framework (provides `BB.Message`, `BB.Robot`, unit handling)
- `Pigpiox.Socket` - Communication with pigpio daemon (mocked in tests)
- `Spark.Options` - Option validation with unit type support

### Test Support

Tests use Mimic for mocking:
- `BB` and `BB.Robot` modules for pub/sub
- `Pigpiox.Socket` for hardware communication

Test support modules in `test/support/` provide stubs and fixtures.
