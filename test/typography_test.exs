defmodule ReflectOS.Kernel.TypographyTest do
  use ExUnit.Case, async: true
  import ReflectOS.Kernel.Typography

  doctest ReflectOS.Kernel.Typography

  describe "wrap/3" do
    test "wraps long text" do
      # Arrange
      text =
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."

      expected =
        """
        Lorem ipsum dolor sit amet, consectetur
        adipiscing elit, sed do eiusmod tempor
        incididunt ut labore et dolore magna aliqua. Ut
        enim ad minim veniam, quis nostrud
        exercitation ullamco laboris nisi ut aliquip ex
        ea commodo consequat.
        """
        |> String.trim()

      # Act/Assert
      assert wrap(text, 500, font_size: 24) == expected
    end
  end
end
