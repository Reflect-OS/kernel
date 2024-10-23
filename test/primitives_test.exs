defmodule ReflectOS.Kernel.PrimitivesTest do
  use ExUnit.Case

  alias Scenic.Graph

  alias ReflectOS.Kernel.Primitives

  @graph Graph.build()
         |> Scenic.Primitives.rect({300, 300})

  describe "render_section_label/3" do
    test "adds label when show_label? is true" do
      g = Primitives.render_section_label(@graph, %{show_label?: true, label: "Label"})

      text = g.primitives[2]
      line = g.primitives[3]

      assert text.module == Scenic.Primitive.Text
      assert text.data == "Label"

      assert line.module == Scenic.Primitive.Line
    end

    test "does not add label when show_label? is false" do
      g = Primitives.render_section_label(@graph, %{show_label?: false})

      assert Enum.count(g.primitives) == 2
    end
  end

  describe "section_label/3" do
    test "renders a label for a section" do
      g = Primitives.section_label(@graph, "Label")

      text = g.primitives[2]
      line = g.primitives[3]

      assert text.module == Scenic.Primitive.Text
      assert text.data == "Label"

      assert line.module == Scenic.Primitive.Line
      assert line.data == {{0, -16}, {300, -16}}
    end

    test "renders a label for the given width" do
      g = Primitives.section_label(@graph, "Label", width: 500)

      line = g.primitives[3]

      assert line.data == {{0, -16}, {500, -16}}
    end

    test "renders a label for the given alignment" do
      g = Primitives.section_label(@graph, "Label", align: :right)

      text = g.primitives[2]

      assert text.transforms == %{translate: {0.0, -20.0}}
    end
  end

  describe "qr_code/3" do
    test "renders correctly" do
      {:ok, svc} = Scenic.Assets.Stream.start_link(nil)

      g = Primitives.qr_code(Graph.build(), "QR Code Content", width: 300)

      rect = g.primitives[1]

      assert rect.data == {300, 300}

      # Clean up
      Process.exit(svc, :normal)
      Process.sleep(4)
    end
  end
end
