defmodule ReflectOS.Kernel.LayoutManager do
  alias ReflectOS.Kernel.Settings.LayoutManagerStore
  alias __MODULE__
  alias ReflectOS.Kernel.{Option, OptionGroup}
  alias ReflectOS.Kernel.LayoutManager.Definition
  alias ReflectOS.Kernel.LayoutManager.State
  alias ReflectOS.Kernel.ActiveLayout

  ######
  # Types
  ######

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
  @callback layout_manager_definition() :: Definition.t()

  @callback layout_manager_options() :: [Option.t() | OptionGroup.t()]

  @callback changeset(layout_manager :: any(), params :: %{binary() => any()}) ::
              Ecto.Changeset.t()

  @callback init_layout_manager(state :: State.t(), config :: term()) ::
              {:ok, state}
              | {:ok, state, timeout :: non_neg_integer}
              | {:ok, state, :hibernate}
              | {:ok, state, opts :: response_opts()}
              | :ignore
              | {:stop, reason}
            when state: State.t(), reason: term()

  @callback handle_config_update(scene :: State.t(), config :: struct()) :: State.t()

  @optional_callbacks handle_config_update: 2

  ######
  # State Management API
  ######

  @doc """
  Pushes a new layout to the dashboard
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
  Convenience function to get an assigned value out of a ReflectOS.Kernel.LayoutManager.State struct.
  """
  @spec get(state :: State.t(), key :: any, default :: any) :: any
  def get(%State{assigns: assigns}, key, default \\ nil) do
    Map.get(assigns, key, default)
  end

  @doc """
  Convenience function to fetch an assigned value out of a ReflectOS.Kernel.LayoutManager.State struct.
  """
  @spec fetch(state :: State.t(), key :: any) :: {:ok, any} | :error
  def fetch(%State{assigns: assigns}, key) do
    Map.fetch(assigns, key)
  end

  @doc """
  Convenience function to assign a list or map of values into a ReflectOS.Kernel.LayoutManager.State struct.
  """
  @spec assign(state :: State.t(), assigns :: Keyword.t() | map()) :: State.t()
  def assign(%State{} = state, assigns) when is_list(assigns) do
    Enum.reduce(assigns, state, fn {k, v}, acc -> assign(acc, k, v) end)
  end

  def assign(%State{} = state, assigns) when is_map(assigns) do
    %State{state | assigns: Map.merge(state.assigns, assigns)}
  end

  @doc """
  Convenience function to assign a value into a ReflectOS.Kernel.LayoutManager.State struct.
  """
  @spec assign(state :: State.t(), key :: any, value :: any) :: State.t()
  def assign(%State{assigns: assigns} = state, key, value) do
    %{state | assigns: Map.put(assigns, key, value)}
  end

  @doc """
  Convenience function to assign a list of new values into a ReflectOS.Kernel.LayoutManager.State struct.

  Only values that do not already exist will be assigned
  """
  @spec assign_new(state :: State.t(), key_list :: Keyword.t() | map) :: State.t()
  def assign_new(%State{} = state, key_list) when is_list(key_list) do
    Enum.reduce(key_list, state, fn {k, v}, acc -> assign_new(acc, k, v) end)
  end

  def assign_new(%State{assigns: assigns} = state, key_map) when is_map(key_map) do
    %{state | assigns: Map.merge(key_map, assigns)}
  end

  @doc """
  Convenience function to assign a new values into a ReflectOS.Kernel.LayoutManager.State struct.

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
