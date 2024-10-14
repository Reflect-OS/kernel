defmodule ReflectOS.Kernel.Layout.Definition do
  @enforce_keys [:name, :icon]

  @type t :: %__MODULE__{
          name: binary(),
          description: binary(),
          icon: binary(),
          locations: list()
        }

  defstruct name: nil,
            description: nil,
            icon: nil,
            locations: []
end
