defmodule ReflectOS.Kernel.GraphHelpers do
  @moduledoc """
  Helper functions for working with `Scenic.Graph`
  """
  alias Scenic.Graph

  @doc """
  Gets the left boundary of the graph.  Note that this could be negative.
  """
  @spec get_left_bound(Scenic.Graph.t()) :: number()
  def get_left_bound(%Graph{} = graph) do
    case Graph.bounds(graph) do
      nil -> 0
      bounds -> elem(bounds, 0)
    end
  end

  @doc """
  Gets the top boundary of the graph.  Note that this could be negative.
  """
  @spec get_top_bound(Scenic.Graph.t()) :: number()
  def get_top_bound(%Graph{} = graph) do
    case Graph.bounds(graph) do
      nil -> 0
      bounds -> elem(bounds, 1)
    end
  end

  @doc """
  Gets the right boundary of the graph.  Note that this could be negative.
  """
  @spec get_right_bound(Scenic.Graph.t()) :: number()
  def get_right_bound(%Graph{} = graph) do
    case Graph.bounds(graph) do
      nil -> 0
      bounds -> elem(bounds, 2)
    end
  end

  @doc """
  Gets the bottom boundary of the graph.   Note that this could be negative.
  """
  @spec get_bottom_bound(Scenic.Graph.t()) :: number()
  def get_bottom_bound(%Graph{} = graph) do
    case Graph.bounds(graph) do
      nil -> 0
      bounds -> elem(bounds, 3)
    end
  end
end
