defmodule ReflectOS.Kernel.LayoutManager do
  @moduledoc """

  Layout Managers are responsible for determining which layout should be
  rendered to the dashboard.

  ## Overview

  Layout Managers are specialized GenServers which control which layout should be shown on the dashboard at any given time.  Layout Managers are
  a unique feature of ReflectOS, allowing developers to build managers
  which can change the layout in response to just about anything (e.g. a
  fixed schedule, weather conditions, etc).  Using Layout Managers, users
  can ensure their ReflectOS dashhboard shows just what they need, when
  they need it.

  Layouts Managers follow the same pattern of `Scenic.Scene`, and utilize
  a dedicated struct (see `ReflectOS.Kernel.LayoutManager.State`) with an
  `assigns` property as their state.  You can use the `assigns` property to
  hold any data in state that you need.  Layout Managers are passed their
  configuration as an init argument.

  There are few requirements for LayoutManagers, which allows a high degree
  of flexibility for building custom logic around which layout is displayed.
  `LayoutManagers` simple use the `push_layout/2` function to notify the
  ReflectOS system that a new layout should be displayed.

  Like all extensions to ReflectOS, developers are also required to implement a set of callbacks which are used to allow run time configuration.  If you plan on publishing your extensions for use by others in the community, you can use these callbacks to create a thoughtful and intuitive configuration experience.

  ## Implementing a Layout Manager

  Layouts are just modules which `use ReflectOS.Kernel.LayoutManager` and implement it's behavior.  The callbacks and other requirements for a Layout fall into two major categories:

  1. Configuration experience via the [ReflectOS Console](https://github.com/reflect-os/console) web ui.
  2. Managing the logic around which layout should be displayed

  ### Configuration Experience

  In order to drive the ReflectOS console UI, layout managers are required to contain an `Ecto.Schema` which represents the available configuration options.  This is typically done using the [`embedded_schema/1`](https://hexdocs.pm/ecto/Ecto.Schema.html#embedded_schema/1) macro, as they are not persisted via `Ecto.Repo`.

  Note that embedding schemas in your root schema (e.g. `Ecto.Schema.embeds_many/4`) is **not currently supported**.

  Additionally, layouts must implement the following callbacks which are used by the console:

  * `c:layout_manager_definition/0`
  * `c:layout_manager_options/0`
  * `c:changeset/2`

  ### Layout Display Logic

  In order to determine which layout renders to the ReflectOS dashboard, modules are on required to implement a single callback:

  * `c:init_layout_manager/2`

  Sections can also optionally implement the following callbacks:

  * `c:handle_config_update/2`

  See the documentation for each callback below for more details.

  ## Example

  Here is the `Static` layout manager which ships with the pre-built
  ReflectOS firmware.  It simply allows the user the select a single
  layout via the console UI and sets it as the active layout.

      defmodule ReflectOS.Core.LayoutManagers.Static do
        use ReflectOS.Kernel.LayoutManager

        import Phoenix.Component, only: [sigil_H: 2]

        alias ReflectOS.Kernel.Option
        alias ReflectOS.Kernel.LayoutManager
        alias ReflectOS.Kernel.LayoutManager.Definition
        alias ReflectOS.Kernel.LayoutManager.State
        alias ReflectOS.Kernel.Settings.LayoutStore

        @impl true
        def layout_manager_definition() do
          %Definition{
            name: "Static Layout",
            icon: \"\"\"
              <svg class="text-gray-800 dark:text-white" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24">
                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7.757 12h8.486M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"/>
              </svg>
            \"\"\",
            description: fn assigns ->
              ~H\"\"\"
              Allows selecting a single, static layout.
              \"\"\"
            end
          }
        end

        embedded_schema do
          field(:layout, :string)
        end

        @impl true
        def changeset(%__MODULE__{} = layout_manager, params \\ %{}) do
          layout_manager
          |> cast(params, [:layout])
          |> validate_required([:layout])
        end

        @impl true
        def layout_manager_options(),
          do: [
            %Option{
              key: :layout,
              label: "Layout",
              config: %{
                type: "select",
                prompt: "--Select Layout--",
                options:
                  LayoutStore.list()
                  |> Enum.map(fn %{name: name, id: id} ->
                    {name, id}
                  end)
              }
            }
          ]

        @impl LayoutManager
        def init_layout_manager(%State{} = state, %{layout: layout_id}) do
          state =
            state
            |> push_layout(layout_id)

          {:ok, state}
        end
      end
  """

  alias ReflectOS.Kernel.Settings.LayoutManagerStore
  alias __MODULE__
  alias ReflectOS.Kernel.{Option, OptionGroup}
  alias ReflectOS.Kernel.LayoutManager.Definition
  alias ReflectOS.Kernel.LayoutManager.State
  alias ReflectOS.Kernel.ActiveLayout

  ######
  # Types
  ######

  @doc false
  @type t :: %LayoutManager{
          id: binary(),
          name: binary(),
          module: module(),
          config: map()
        }
  defstruct id: nil,
            name: nil,
            module: nil,
            config: %{}

  @type response_opts ::
          list(
            timeout()
            | :hibernate
            | {:continue, term}
          )

  ######
  # Callbacks
  ######
  @doc """
  Provides the `ReflectOS.Kernel.LayoutManager.Definition` struct for the layout.

  This is used to show your layout manager in the Console UI.
  Here is the callback from the example above:

      @impl true
      def layout_manager_definition() do
        %Definition{
          name: "Static Layout",
          icon: \"\"\"
            <svg class="text-gray-800 dark:text-white" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24">
              <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7.757 12h8.486M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"/>
            </svg>
          \"\"\",
          description: fn assigns ->
            ~H\"\"\"
            Allows selecting a single, static layout.
            \"\"\"
          end
        }
      end

  Note that the `icon` property is passed in as simple string, while the `description` property takes a function which can be passed to `Phoenix.LiveView`.  This allows you to use html tags in your description.  Additionally, note that the argument must be called `assigns`.

  See `ReflectOS.Kernel.LayoutManager.Definition` for more details.
  """
  @callback layout_manager_definition() :: Definition.t()

  @doc """
  Provides the list of options which can be configured through the ReflectOS console.

  From the example above:

      @impl true
      def layout_manager_options(),
        do: [
          %Option{
            key: :layout,
            label: "Layout",
            config: %{
              type: "select",
              prompt: "--Select Layout--",
              options:
                LayoutStore.list()
                |> Enum.map(fn %{name: name, id: id} ->
                  {name, id}
                end)
            }
          }
        ]

  Note that any properties in the `config` map will be passed directly to the HTML input in the Console UI configuration form.

  See `ReflectOS.Kernel.Option` and `ReflectOS.Kernel.OptionGroup` for more information.
  """
  @callback layout_manager_options() :: [Option.t() | OptionGroup.t()]

  @doc """
  Used to cast and validate input from the user via the ReflectOS Console UI.

  Can be used like a standard `Ecto.Changeset`.  Here is the callback from the example given above:

      @impl true
      def changeset(%__MODULE__{} = layout_manager, params \\ %{}) do
        layout_manager
        |> cast(params, [:layout])
        |> validate_required([:layout])
      end
  """
  @callback changeset(layout_manager :: any(), params :: %{binary() => any()}) ::
              Ecto.Changeset.t()

  @doc """
  Callback invoked during initialization of the layout manager.

  Wraps the `c:GenServer.init/1` callback, and allows the same return values.  The `config` argument will be the populated `Ecto.Schema` defined in your section module.

  From the `Static` example above:

      @impl LayoutManager
      def init_layout_manager(%State{} = state, %{layout: layout_id}) do
        state =
          state
          |> push_layout(layout_id)

        {:ok, state}
      end
  """
  @callback init_layout_manager(state :: State.t(), config :: term()) ::
              {:ok, state}
              | {:ok, state, timeout() | :hibernate | {:continue, continue_arg :: term()}}
              | :ignore
              | {:stop, reason :: any()}
            when state: State.t()

  @doc """
  Optional callback for when users update a layout manager's configuration.

  The default behavior when the layout manager's configuration changes is
  to restart the layout manager process with the new configuration.
  This will likely work in most circumstances, but you can override this behavior if it is desirable (e.g. your layout manager has a lengthy start
  up time).
  """
  @callback handle_config_update(scene :: State.t(), config :: struct()) :: State.t()

  @optional_callbacks handle_config_update: 2

  ######
  # State Management API
  ######

  @doc """
  Pushes the layout with the provided id to the dashboard.
  """
  @spec push_layout(layout_manager :: State.t(), new_layout_id :: binary()) ::
          State.t()
  def push_layout(
        %State{layout_id: current_layout_id} = layout_manager,
        new_layout_id
      )
      when current_layout_id != new_layout_id and is_binary(new_layout_id) do
    ActiveLayout.put(new_layout_id)
    %{layout_manager | layout_id: new_layout_id}
  end

  def push_layout(
        %State{} = layout_manager,
        _layout_id
      ) do
    layout_manager
  end

  ######
  # GenServer
  ######

  # Working with GenServer State
  @doc """
  Convenience function to get an assigned value out of a `ReflectOS.Kernel.LayoutManager.State` struct.
  """
  @spec get(state :: State.t(), key :: any, default :: any) :: any
  def get(%State{assigns: assigns}, key, default \\ nil) do
    Map.get(assigns, key, default)
  end

  @doc """
  Convenience function to fetch an assigned value out of a `ReflectOS.Kernel.LayoutManager.State` struct.
  """
  @spec fetch(state :: State.t(), key :: any) :: {:ok, any} | :error
  def fetch(%State{assigns: assigns}, key) do
    Map.fetch(assigns, key)
  end

  @doc """
  Convenience function to assign a list or map of values into a `ReflectOS.Kernel.LayoutManager.State` struct.
  """
  @spec assign(state :: State.t(), assigns :: Keyword.t() | map()) :: State.t()
  def assign(%State{} = state, assigns) when is_list(assigns) do
    Enum.reduce(assigns, state, fn {k, v}, acc -> assign(acc, k, v) end)
  end

  def assign(%State{} = state, assigns) when is_map(assigns) do
    %State{state | assigns: Map.merge(state.assigns, assigns)}
  end

  @doc """
  Convenience function to assign a value into a `ReflectOS.Kernel.LayoutManager.State` struct.
  """
  @spec assign(state :: State.t(), key :: any, value :: any) :: State.t()
  def assign(%State{assigns: assigns} = state, key, value) do
    %{state | assigns: Map.put(assigns, key, value)}
  end

  @doc """
  Convenience function to assign a list of new values into a `ReflectOS.Kernel.LayoutManager.State` struct.

  Only values that do not already exist will be assigned.
  """
  @spec assign_new(state :: State.t(), key_list :: Keyword.t() | map) :: State.t()
  def assign_new(%State{} = state, key_list) when is_list(key_list) do
    Enum.reduce(key_list, state, fn {k, v}, acc -> assign_new(acc, k, v) end)
  end

  def assign_new(%State{assigns: assigns} = state, key_map) when is_map(key_map) do
    %{state | assigns: Map.merge(key_map, assigns)}
  end

  @doc """
  Convenience function to assign a new values into a `ReflectOS.Kernel.LayoutManager.State` struct.

  The value will only be assigned if it does not already exist in the struct.
  """
  @spec assign_new(state :: State.t(), key :: any, value :: any) :: State.t()
  def assign_new(%State{assigns: assigns} = state, key, value) do
    %{state | assigns: Map.put_new(assigns, key, value)}
  end

  @doc false
  defmacro __using__(opts) do
    quote location: :keep do
      use GenServer, unquote(opts)
      @behaviour unquote(__MODULE__)

      import Ecto.Changeset
      use Ecto.Schema

      import unquote(__MODULE__),
        only: [
          get: 2,
          get: 3,
          fetch: 2,
          assign: 2,
          assign: 3,
          assign_new: 2,
          assign_new: 3,
          push_layout: 2
        ]

      def start_link(layout_manager_id)
          when is_binary(layout_manager_id) do
        GenServer.start_link(__MODULE__, layout_manager_id, name: ReflectOS.ActiveLayoutManager)
      end

      # Callbacks
      @impl true
      def init(layout_manager_id) do
        layout_manager = LayoutManagerStore.get(layout_manager_id)
        LayoutManagerStore.subscribe(layout_manager_id)

        # Give the module a chance to initialize
        case __MODULE__.init_layout_manager(%State{}, layout_manager.config) do
          {:ok, %State{} = state} ->
            {:ok, state}

          {:ok, _other} ->
            raise "Invalid response from #{__MODULE__}.init/3 State must be a %LayoutManager{}"

          {:ok, %State{} = state, opt} ->
            {:ok, state, opt}

          {:ok, _other, _opt} ->
            raise "Invalid response from #{__MODULE__}.init/3 State must be a %LayoutManager{}"

          other ->
            other
        end
      end

      # Handle update to section, but only if the config changes
      @impl true
      def handle_info(
            %PropertyTable.Event{
              property: ["layout_managers", _id],
              value: layout_manager,
              previous_value: previous
            },
            state
          )
          when previous.config != layout_manager.config do
        state =
          if Kernel.function_exported?(__MODULE__, :handle_config_update, 2) do
            config = struct(__MODULE__, layout_manager.config)
            Kernel.apply(__MODULE__, :handle_config_update, [state, config])
          else
            exit({:shutdown, :config_update})
            state
          end

        {:noreply, state}
      end
    end
  end
end
