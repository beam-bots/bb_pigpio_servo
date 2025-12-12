# SPDX-FileCopyrightText: 2025 James Harton
#
# SPDX-License-Identifier: Apache-2.0

defmodule BB.Servo.Pigpio do
  @moduledoc """
  BB integration for driving RC servos via pigpio on Raspberry Pi.

  This library provides actuator and sensor modules for controlling RC servos
  directly connected to Raspberry Pi GPIO pins using the pigpio daemon.

  ## Components

  - `BB.Servo.Pigpio.Actuator` - Controls servo position via PWM
  - `BB.Servo.Pigpio.Sensor` - Provides position feedback by subscribing to actuator commands

  ## Requirements

  - Raspberry Pi with pigpio daemon running (`sudo pigpiod`)
  - The `pigpiox` library for communication with pigpiod

  ## Quick Start

  Define a joint with servo actuator in your robot DSL:

      joint :shoulder, type: :revolute do
        limit lower: ~u(-45 degree), upper: ~u(45 degree), velocity: ~u(60 degree_per_second)

        actuator :servo, {BB.Servo.Pigpio.Actuator, pin: 17}
        sensor :feedback, {BB.Servo.Pigpio.Sensor, actuator: :servo}
      end

  The actuator automatically derives its configuration from the joint limits - no need
  to specify servo rotation range or speed separately.

  ## How It Works

  ### Actuator

  The actuator maps the joint's position limits directly to the servo's PWM range:
  - Joint lower limit → minimum pulse width (default 500µs)
  - Joint upper limit → maximum pulse width (default 2500µs)
  - Centre position calculated as midpoint of limits

  When commanded to a position, the actuator:
  1. Clamps the position to joint limits
  2. Converts to PWM pulse width
  3. Sends command to pigpiod
  4. Publishes `{:position_commanded, angle, expected_arrival}` for sensors

  ### Sensor

  The sensor subscribes to actuator position commands and publishes `JointState`
  messages. It provides:
  - Position interpolation during movement
  - Configurable publish rate (default 50Hz)
  - Periodic sync publishing even when idle (default every 5 seconds)
  """
end
