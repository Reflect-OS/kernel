defmodule ReflectOS.Kernel.OptionGroup do
  alias ReflectOS.Kernel.Option

  @enforce_keys [:label]

  defstruct label: nil,
            description: nil,
            options: []

  @type t :: %__MODULE__{
          label: String.t(),
          description: function(),
          options: list(Option.t())
        }
end
