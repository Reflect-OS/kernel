defmodule ReflectOS.Kernel.LayoutManager.ChangesetTest do
  use ExUnit.Case

  import ReflectOS.Kernel.TestChangesetHelpers

  alias ReflectOS.Kernel.LayoutManager
  alias ReflectOS.Kernel.TestLayoutManager
  alias ReflectOS.Kernel.LayoutManager.Changeset

  describe "name" do
    test "is required" do
      changeset = Changeset.change(%LayoutManager{}, %{module: TestLayoutManager})
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "must be at least 3 characters" do
      changeset = Changeset.change(%LayoutManager{}, %{name: "hi", module: TestLayoutManager})
      assert %{name: ["should be at least 3 character(s)"]} = errors_on(changeset)
    end
  end

  describe "module" do
    test "is required" do
      changeset = Changeset.change(%LayoutManager{}, %{name: "test"})
      assert %{module: ["can't be blank"]} = errors_on(changeset)
    end

    test "must be at a valid module" do
      changeset = Changeset.change(%LayoutManager{}, %{name: "test", module: 12345})
      assert %{module: ["is invalid"]} = errors_on(changeset)
    end
  end

  describe "config" do
    test "is properly cast" do
      config = %TestLayoutManager{layout: "test-layout-id"}

      changeset =
        Changeset.change(%LayoutManager{}, %{
          name: "test",
          module: TestLayoutManager,
          config: config
        })

      assert {:ok, %{config: ^config}} = Ecto.Changeset.apply_action(changeset, :update)
    end
  end
end
