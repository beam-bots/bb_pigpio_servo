# SPDX-FileCopyrightText: 2025 James Harton
#
# SPDX-License-Identifier: Apache-2.0

defmodule BB.PigpioServoTest do
  use ExUnit.Case
  doctest BB.PigpioServo

  test "greets the world" do
    assert BB.PigpioServo.hello() == :world
  end
end
