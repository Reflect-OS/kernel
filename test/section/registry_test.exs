defmodule ReflectOS.Kernel.Section.RegistryTest do
  use ExUnit.Case
  alias ReflectOS.Kernel.Section.Registry

  alias ReflectOS.Kernel.{TestSection1, TestSection2}

  describe "register/1" do
    test "allows registration with a module" do
      assert Registry.register(TestSection1) == :ok
    end

    test "allows registration with a list of module" do
      assert Registry.register([TestSection1, TestSection2]) == :ok
    end
  end

  describe "definitions/0" do
    test "returns a list of section definitions" do
      # Arrange
      Registry.register([TestSection1, TestSection2])

      expected =
        [
          TestSection1.section_definition(),
          TestSection2.section_definition()
        ]

      # Act / Assert
      assert ^expected = Registry.definitions()
    end
  end

  describe "list/0" do
    test "returns a list of section modules" do
      # Arrange
      Registry.register([TestSection1, TestSection2])

      expected =
        [
          TestSection1,
          TestSection2
        ]

      # Act / Assert
      assert ^expected = Registry.list()
    end
  end
end
