defmodule ReflectOS.Kernel.Ecto.Module do
  @moduledoc """

  Custom Type to support storing atom module names in an `Ecto.Changeset`.

  You can use this to persist atoms in your module configuration, which is
  particularly useful if you have multiple providers for a given service
  used to retrieve information for your section.

  For example:

      defmodule MyWeatherSection do
        use ReflectOS.Kernel.Section

        embedded_schema do
          field :weather_service_module, Ecto.Module
        end
      end

  Implements behavior `Ecto.Type`.
  """

  @behaviour Ecto.Type

  def type, do: :string

  def equal?(first, second), do: first == second

  def cast(value) when is_atom(value), do: {:ok, value}

  def cast(value) when is_binary(value) do
    try do
      {:ok, String.to_existing_atom(value)}
    rescue
      ArgumentError -> :error
    end
  end

  def cast(_), do: :error

  def load(value), do: {:ok, String.to_existing_atom(value)}

  def dump(value) when is_atom(value), do: {:ok, Atom.to_string(value)}
  def dump(_), do: :error

  def embed_as(_format), do: :self
end
