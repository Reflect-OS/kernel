defmodule ReflectOS.Kernel.LayoutManager.Registry do
  @moduledoc """
  Used to register one or more `ReflectOS.Kernel.LayoutManager`s with the system.

  If you are building an extension library with a new layout manager type,
  the layout manager module must be registered with the ReflectOS system.
  This will ensure that it's available for users to create and configure
  layout managers via the Console UI application.

  The recommended way to accomplish this is to do so by starting a task
  in the root supervisor of your application.

  For example:

      defmodule MyReflectOSExtensions.Application do
        @moduledoc false

        use Application

        alias ReflectOS.Kernel.LayoutManager.Registry, as: LayoutManagerRegistry

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
          LayoutManagerRegistry.register([
            MyReflectOSExtensions.LayoutManagers.MyNewLayoutManager,
          ])
        end
      end
  """

  use Agent

  @doc """
  Starts the Registry.

  As discussed above, typically done in the application callback
  of your library.
  """
  def start_link(_) do
    Agent.start_link(fn -> MapSet.new() end, name: __MODULE__)
  end

  @doc ~S"""
  Registers a module with the LayoutManager registry.

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
  Retrieves a list of definitions for all registered layout managers.
  """
  @spec definitions() :: list(ReflectOS.Kernel.LayoutManager.Definition.t())
  def definitions() do
    list()
    |> Enum.map(& &1.layoutmanager_definition())
  end

  @doc ~S"""
  Retrieves the list of registered layout manager modules.
  """
  @spec list() :: list(module())
  def list() do
    Agent.get(__MODULE__, & &1)
    |> MapSet.to_list()
  end
end
