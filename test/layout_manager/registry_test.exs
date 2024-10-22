defmodule ReflectOS.Kernel.LayoutManager.RegistryTest do
  use ExUnit.Case
  alias ReflectOS.Kernel.LayoutManager.Registry

  alias ReflectOS.Kernel.TestLayoutManager

  describe "register/1" do
    test "allows registration with a module" do
      assert Registry.register(TestLayoutManager) == :ok
    end

    test "allows registration with a list of module" do
      assert Registry.register([TestLayoutManager]) == :ok
    end
  end

  describe "definitions/0" do
    test "returns a list of layout manager definitions" do
      # Arrange
      Registry.register([TestLayoutManager])

      expected =
        [
          TestLayoutManager.layout_manager_definition()
        ]

      # Act / Assert
      assert ^expected = Registry.definitions()
    end
  end

  describe "list/0" do
    test "returns a list of layout manager modules" do
      # Arrange
      Registry.register([TestLayoutManager])

      expected =
        [
          TestLayoutManager
        ]

      # Act / Assert
      assert ^expected = Registry.list()
    end
  end
end
