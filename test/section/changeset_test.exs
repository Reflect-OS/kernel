defmodule ReflectOS.Kernel.Section.ChangesetTest do
  use ExUnit.Case

  import ReflectOS.Kernel.TestChangesetHelpers

  alias ReflectOS.Kernel.Section
  alias ReflectOS.Kernel.TestSection
  alias ReflectOS.Kernel.Section.Changeset

  describe "name" do
    test "is required" do
      changeset = Changeset.change(%Section{}, %{module: TestSection})
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "must be at least 3 characters" do
      changeset = Changeset.change(%Section{}, %{name: "hi", module: TestSection})
      assert %{name: ["should be at least 3 character(s)"]} = errors_on(changeset)
    end
  end

  describe "module" do
    test "is required" do
      changeset = Changeset.change(%Section{}, %{name: "test"})
      assert %{module: ["can't be blank"]} = errors_on(changeset)
    end

    test "must be at a valid module" do
      changeset = Changeset.change(%Section{}, %{name: "test", module: 12345})
      assert %{module: ["is invalid"]} = errors_on(changeset)
    end
  end

  describe "config" do
    test "is properly cast" do
      config = %TestSection{label: "Test Section"}

      changeset =
        Changeset.change(%Section{}, %{
          name: "test",
          module: TestSection,
          config: config
        })

      assert {:ok, %{config: ^config}} = Ecto.Changeset.apply_action(changeset, :update)
    end
  end
end
