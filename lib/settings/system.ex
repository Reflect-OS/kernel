defmodule ReflectOS.Kernel.Settings.System do
  alias ReflectOS.Kernel.Settings

  @system_settings [
    "time_format",
    "viewport_size",
    "timezone",
    "layout_manager",
    "show_instructions"
  ]

  def time_format() do
    get("time_format")
  end

  @doc false
  def time_format(time_format) do
    put("time_format", time_format)
  end

  def viewport_size() do
    get("viewport_size")
  end

  @doc false
  def viewport_size(viewport_size) do
    put("viewport_size", viewport_size)
  end

  def timezone() do
    get("timezone")
  end

  @doc false
  def timezone(timezone) do
    put("timezone", timezone)
  end

  @doc false
  @spec show_instructions?() :: boolean()
  def show_instructions?() do
    get("show_instructions")
  end

  @doc false
  @spec show_instructions?(boolean()) :: :ok | {:error, any()}
  def show_instructions?(show_instructions) do
    put("show_instructions", show_instructions == "true")
  end

  @doc false
  @spec layout_manager() :: binary()
  def layout_manager() do
    get("layout_manager")
  end

  @doc false
  @spec layout_manager(binary()) :: :ok | {:error, any()}
  def layout_manager(layout_manager_id) when is_binary(layout_manager_id) do
    put("layout_manager", layout_manager_id)
  end

  def subscribe(key) when is_binary(key) and key in @system_settings do
    Settings.subscribe(["system", key])
  end

  defp get(key) when is_binary(key) do
    Settings.get(["system", key], default(key))
  end

  defp default(key) do
    key = String.to_atom(key)
    Application.get_env(:reflect_os_kernel, :system)[key]
  end

  defp put(key, value) do
    Settings.put(["system", key], value)
  end
end
