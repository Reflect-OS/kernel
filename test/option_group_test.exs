defmodule ReflectOS.Kernel.OptionGroupTest do
  alias ReflectOS.Kernel.OptionGroup
  use ExUnit.Case

  test "struct defaults are correct" do
    default = %OptionGroup{
      label: "Test"
    }

    assert default.label == "Test"
    assert default.description == nil
    assert default.options == []

    assert %OptionGroup{} = default
  end
end
