# SPDX-FileCopyrightText: 2025 James Harton
#
# SPDX-License-Identifier: Apache-2.0

defmodule Pigpiox.Socket do
  @moduledoc """
  Stub module for Pigpiox.Socket to enable testing without hardware.
  """

  def command(_command, _pin, _value) do
    {:ok, 0}
  end
end
