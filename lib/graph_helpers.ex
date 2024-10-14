defmodule ReflectOS.Kernel.GraphHelpers do
  alias Scenic.Graph

  @spec get_top_bound(Scenic.Graph.t()) :: number()
  def get_top_bound(%Graph{} = graph) do
    case Graph.bounds(graph) do
      nil -> 0
      bounds -> elem(bounds, 1)
    end
  end

  @spec get_bottom_bound(Scenic.Graph.t()) :: number()
  def get_bottom_bound(%Graph{} = graph) do
    case Graph.bounds(graph) do
      nil -> 0
      bounds -> elem(bounds, 3)
    end
  end
end
