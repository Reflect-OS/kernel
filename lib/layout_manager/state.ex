defmodule ReflectOS.Kernel.LayoutManager.State do
  @moduledoc """
  Holds the struct which is used as the `ReflectOS.Kernel.LayoutManager` state.
  """

  @type t :: %__MODULE__{
          layout_id: struct(),
          assigns: map()
        }
  defstruct layout_id: nil,
            assigns: %{}
end
