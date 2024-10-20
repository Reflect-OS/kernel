defmodule ReflectOS.Kernel.Layout.Registry do
  @moduledoc """
  Used to register one or more `ReflectOS.Kernel.Layout` with the system.

  If you are building an extension library with a new layout type,
  the layout module must be registered with the ReflectOS system.
  This will ensure that it's available for users to create and configure
  layouts via the Console UI application.

  The recommended way to accomplish this is to do so by starting a task
  in the root supervisor of your application.

  For example:

      defmodule MyReflectOSExtensions.Application do
        @moduledoc false

        use Application

        alias ReflectOS.Kernel.Layout.Registry, as: LayoutRegistry

        @impl true
        def start(_type, _args) do
          children = [
            # Start a task to register ReflectOS extensions
            {Task, fn -> reflect_os_register() end}
          ]

          opts = [strategy: :one_for_one, name: MyReflectOSExtensions.Supervisor]
          Supervisor.start_link(children, opts)
        end

        defp reflect_os_register() do
          LayoutRegistry.register([
            MyReflectOSExtensions.Layouts.MyNewLayout,
          ])
        end
      end
  """

  use Agent

  @doc false
  def start_link(_) do
    Agent.start_link(fn -> MapSet.new() end, name: __MODULE__)
  end

  @doc ~S"""
  Registers a module with the Layout registry.

  Accepts either a single module or a list of modules.
  """
  @spec register(module() | list(module())) :: :ok
  def register(module) when is_atom(module) do
    register([module])
  end

  def register(modules) when is_list(modules) do
    Agent.update(__MODULE__, fn set ->
      modules
      |> Enum.reduce(set, fn m, acc ->
        MapSet.put(acc, m)
      end)
    end)
  end

  @doc ~S"""
  Retrieves a list of definitions for all registered layouts.
  """
  @spec definitions() :: list(ReflectOS.Kernel.Layout.Definition.t())
  def definitions() do
    list()
    |> Enum.map(& &1.layout_definition())
  end

  @doc ~S"""
  Retrieves the list of registered layout modules.
  """
  @spec list() :: list(module())
  def list() do
    Agent.get(__MODULE__, & &1)
    |> MapSet.to_list()
  end
end
