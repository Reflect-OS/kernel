defmodule ReflectOS.Kernel.Layout.RegistryTest do
  use ExUnit.Case
  alias ReflectOS.Kernel.Layout.Registry

  alias ReflectOS.Kernel.TestLayout

  describe "register/1" do
    test "allows registration with a module" do
      assert Registry.register(TestLayout) == :ok
    end

    test "allows registration with a list of module" do
      assert Registry.register([TestLayout]) == :ok
    end
  end

  describe "definitions/0" do
    test "returns a list of layout definitions" do
      # Arrange
      Registry.register([TestLayout])

      expected =
        [
          TestLayout.layout_definition()
        ]

      # Act / Assert
      assert ^expected = Registry.definitions()
    end
  end

  describe "list/0" do
    test "returns a list of layout modules" do
      # Arrange
      Registry.register([TestLayout])

      expected =
        [
          TestLayout
        ]

      # Act / Assert
      assert ^expected = Registry.list()
    end
  end
end
