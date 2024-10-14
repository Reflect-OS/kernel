defmodule ReflectOS.Kernel.Option do
  @enforce_keys [:key, :label]

  defstruct key: nil,
            label: nil,
            hidden: nil,
            config: %{}

  @type t :: %__MODULE__{
          key: atom(),
          label: String.t(),
          hidden: function(),
          config: map()
        }
end
