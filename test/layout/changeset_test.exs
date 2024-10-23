defmodule ReflectOS.Kernel.Layout.ChangesetTest do
  use ExUnit.Case

  import ReflectOS.Kernel.TestChangesetHelpers

  alias ReflectOS.Kernel.Layout
  alias ReflectOS.Kernel.TestLayout
  alias ReflectOS.Kernel.Layout.Changeset

  test "takes default params" do
    changeset = Changeset.change(%Layout{})
    assert %Ecto.Changeset{} = changeset
  end

  describe "name" do
    test "is required" do
      changeset = Changeset.change(%Layout{}, %{module: TestLayout})
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "must be at least 3 characters" do
      changeset = Changeset.change(%Layout{}, %{name: "hi", module: TestLayout})
      assert %{name: ["should be at least 3 character(s)"]} = errors_on(changeset)
    end
  end

  describe "module" do
    test "is required" do
      changeset = Changeset.change(%Layout{}, %{name: "test"})
      assert %{module: ["can't be blank"]} = errors_on(changeset)
    end

    test "must be at a valid module" do
      changeset = Changeset.change(%Layout{}, %{name: "test", module: 12345})
      assert %{module: ["is invalid"]} = errors_on(changeset)
    end
  end

  describe "sections" do
    test "is properly cast" do
      sections = %{
        top: ["test-section-id"]
      }

      changeset =
        Changeset.change(%Layout{}, %{name: "test", module: TestLayout, sections: sections})

      assert {:ok, %{sections: ^sections}} = Ecto.Changeset.apply_action(changeset, :update)
    end
  end

  describe "config" do
    test "is properly cast" do
      config = %TestLayout{spacing: 42}

      changeset =
        Changeset.change(%Layout{}, %{
          name: "test",
          module: TestLayout,
          config: config
        })

      assert {:ok, %{config: ^config}} = Ecto.Changeset.apply_action(changeset, :update)
    end
  end
end
