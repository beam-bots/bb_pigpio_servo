<!--
SPDX-FileCopyrightText: 2025 James Harton

SPDX-License-Identifier: Apache-2.0
-->

# BB.PigpioServo

BB integration for driving RC servos via pigpio on Raspberry Pi.

This library provides actuator and sensor modules for controlling RC servos
directly connected to Raspberry Pi GPIO pins using the pigpio daemon.

## Installation

Add `bb_pigpio_servo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bb_pigpio_servo, "~> 0.1.0"}
  ]
end
```

## Requirements

- Raspberry Pi with pigpio daemon running (`sudo pigpiod`)
- BB framework (`~> 0.2`)

## Usage

Define a joint with a servo actuator in your robot DSL:

```elixir
defmodule MyRobot do
  use BB.Robot

  robot do
    link :base do
      joint :shoulder, type: :revolute do
        limit lower: ~u(-45 degree), upper: ~u(45 degree), velocity: ~u(60 degree/second)

        actuator :servo, {BB.PigpioServo.Actuator, pin: 17}
        sensor :feedback, {BB.PigpioServo.Sensor, actuator: :servo}

        link :arm do
          # ...
        end
      end
    end
  end
end
```

The actuator automatically derives its configuration from the joint limits - no
need to specify servo rotation range or speed separately.

## Components

### Actuator

`BB.PigpioServo.Actuator` controls servo position via PWM.

**Options:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `pin` | integer | required | GPIO pin number |
| `min_pulse` | integer | 500 | Minimum PWM pulse width (µs) |
| `max_pulse` | integer | 2500 | Maximum PWM pulse width (µs) |
| `reverse?` | boolean | false | Reverse rotation direction |
| `update_speed` | unit | 50 Hz | PWM update frequency |

**Behaviour:**

- Maps joint position limits directly to PWM range
- Clamps commanded positions to joint limits
- Publishes `{:position_commanded, angle, expected_arrival}` after each command
- Calculates expected arrival time based on joint velocity limit

### Sensor

`BB.PigpioServo.Sensor` provides position feedback by subscribing to actuator commands.

**Options:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `actuator` | atom | required | Name of the actuator to subscribe to |
| `publish_rate` | unit | 50 Hz | Rate to check for position changes |
| `max_silence` | unit | 5 seconds | Max time between publishes (for sync) |

**Behaviour:**

- Subscribes to actuator position commands
- Publishes `JointState` messages when position changes
- Interpolates position during movement for smooth feedback
- Periodically publishes even when idle to keep subscribers in sync

## How It Works

### Position Mapping

The actuator maps the joint's position limits to the servo's PWM range:

```
Joint lower limit  →  min_pulse (500µs)
Joint upper limit  →  max_pulse (2500µs)
Joint centre       →  mid_pulse (1500µs)
```

For a joint with limits `-45°` to `+45°`:
- `-45°` maps to 500µs
- `0°` maps to 1500µs
- `+45°` maps to 2500µs

### Position Feedback

Since RC servos don't provide position feedback, the sensor estimates position
based on commanded targets and expected arrival times:

1. Actuator sends command and calculates expected arrival time from velocity limit
2. Sensor receives `{:position_commanded, target, arrival_time}`
3. During movement, sensor interpolates between previous and target positions
4. After arrival time, sensor reports the target position

This provides realistic position feedback for trajectory planning and monitoring.

## Documentation

Full documentation is available at [HexDocs](https://hexdocs.pm/bb_pigpio_servo).
