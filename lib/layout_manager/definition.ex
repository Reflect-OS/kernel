defmodule ReflectOS.Kernel.LayoutManager.Definition do
  @enforce_keys [:name, :icon]

  @type t :: %__MODULE__{
          name: binary(),
          icon: binary(),
          description: binary()
        }
  defstruct name: nil,
            icon: nil,
            description: nil
end
