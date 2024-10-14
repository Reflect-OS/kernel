defmodule ReflectOS.Kernel.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias ReflectOS.Kernel.LayoutManager
  alias ReflectOS.Kernel.Layout
  alias ReflectOS.Kernel.Section

  @impl true
  def start(_type, _args) do
    settings_config = Application.get_env(:reflect_os_kernel, :settings)

    children =
      [
        # Section, Layout, Layout Manager, and System Settings Store
        {PropertyTable,
         name: ReflectOS.Settings,
         properties: settings_properties(),
         persist_data_path: settings_config[:data_directory]},

        # Active Layout Store - in memory only
        {PropertyTable, name: ReflectOS.ActiveLayout},

        # Start Registries
        ReflectOS.Kernel.Section.Registry,
        ReflectOS.Kernel.Layout.Registry,
        ReflectOS.Kernel.LayoutManager.Registry
      ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ReflectOS.Kernel.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Loads default seettings from configuration
  defp settings_properties() do
    dashboard_config = Application.get_env(:reflect_os_kernel, :dashboard, [])

    []
    |> section_properties(dashboard_config)
    |> layout_properties(dashboard_config)
    |> layout_manager_properties(dashboard_config)
    |> layout_manager_property(dashboard_config)
  end

  defp section_properties(properties, dashboard_config) do
    Keyword.get(dashboard_config, :sections, [])
    |> Enum.reduce(properties, fn {id, value}, acc ->
      [{["sections", id], struct(Section, value)} | acc]
    end)
  end

  defp layout_properties(properties, dashboard_config) do
    Keyword.get(dashboard_config, :layouts, [])
    |> Enum.reduce(properties, fn {id, value}, acc ->
      # Add info
      acc = [{["layouts", id], struct(Layout, value)} | acc]

      acc
    end)
  end

  defp layout_manager_properties(properties, dashboard_config) do
    Keyword.get(dashboard_config, :layout_managers, [])
    |> Enum.reduce(properties, fn {id, value}, acc ->
      # Add info
      acc = [{["layout_managers", id], struct(LayoutManager, value)} | acc]

      acc
    end)
  end

  defp layout_manager_property(properties, dashboard_config) do
    case Keyword.get(dashboard_config, :layout_manager) do
      nil ->
        properties

      layout_manager ->
        [{["system", "layout_manager"], layout_manager} | properties]
    end
  end
end
