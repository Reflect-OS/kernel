defmodule ReflectOS.Kernel.GraphHelpersTest do
  use ExUnit.Case, async: true

  alias Scenic.Graph
  import Scenic.Primitives

  alias ReflectOS.Kernel.GraphHelpers

  describe "get_left_bound/1" do
    test "returns the correct bounds" do
      # Arrange
      graph =
        Graph.build()
        |> rectangle({50, 100}, t: {-25, -50})

      # Act
      result = GraphHelpers.get_left_bound(graph)

      # Assert
      assert result == -25
    end

    test "properly handles an empty graph" do
      # Arrange
      graph =
        Graph.build()

      # Act
      result = GraphHelpers.get_left_bound(graph)

      # Assert
      assert result == 0
    end
  end

  describe "get_top_bound/1" do
    test "returns the correct bounds" do
      # Arrange
      graph =
        Graph.build()
        |> rectangle({50, 100}, t: {-25, -50})

      # Act
      result = GraphHelpers.get_top_bound(graph)

      # Assert
      assert result == -50
    end

    test "properly handles an empty graph" do
      # Arrange
      graph =
        Graph.build()

      # Act
      result = GraphHelpers.get_top_bound(graph)

      # Assert
      assert result == 0
    end
  end

  describe "get_right_bound/1" do
    test "returns the correct bounds" do
      # Arrange
      graph =
        Graph.build()
        |> rectangle({50, 100}, t: {-25, -50})

      # Act
      result = GraphHelpers.get_right_bound(graph)

      # Assert
      assert result == 25
    end

    test "properly handles an empty graph" do
      # Arrange
      graph =
        Graph.build()

      # Act
      result = GraphHelpers.get_right_bound(graph)

      # Assert
      assert result == 0
    end
  end

  describe "get_bottom_bound/1" do
    test "returns the correct bounds" do
      # Arrange
      graph =
        Graph.build()
        |> rectangle({50, 100}, t: {-25, -50})

      # Act
      result = GraphHelpers.get_bottom_bound(graph)

      # Assert
      assert result == 50
    end

    test "properly handles an empty graph" do
      # Arrange
      graph =
        Graph.build()

      # Act
      result = GraphHelpers.get_bottom_bound(graph)

      # Assert
      assert result == 0
    end
  end
end
