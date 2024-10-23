defmodule ReflectOS.Kernel.OptionTest do
  alias ReflectOS.Kernel.Option
  use ExUnit.Case

  test "struct defaults are correct" do
    default = %Option{
      key: :test,
      label: "Test"
    }

    assert default.key == :test
    assert default.label == "Test"
    assert default.hidden == nil
    assert default.config == %{}

    assert %Option{} = default
  end
end
