defmodule ReflectOS.Kernel.LayoutManager.State do
  @type t :: %__MODULE__{
          layout_id: struct(),
          assigns: map()
        }
  defstruct layout_id: nil,
            assigns: %{}
end
