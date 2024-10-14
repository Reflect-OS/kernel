defmodule ReflectOS.Kernel.Layout do
  alias ReflectOS.Kernel.Settings.SectionStore
  alias Scenic.Scene
  alias Scenic.Graph

  alias ReflectOS.Kernel.Settings.System
  alias ReflectOS.Kernel.Settings.LayoutStore
  alias ReflectOS.Kernel.{Option, OptionGroup}
  alias ReflectOS.Kernel.Layout.Definition
  alias ReflectOS.Kernel.Section

  @type t :: %__MODULE__{
          id: binary(),
          name: binary(),
          module: module(),
          config: map(),
          sections: %{
            optional(atom()) => list(Section.t())
          }
        }
  defstruct id: nil,
            name: nil,
            module: nil,
            config: %{},
            sections: %{}

  @callback layout_definition() :: Definition.t()

  @callback layout_options() :: [Option.t() | OptionGroup.t()]

  @callback changeset(layout :: any(), params :: %{binary() => any()}) :: Ecto.Changeset.t()

  @callback init_layout(scene :: Scenic.Scene.t(), args :: term(), options :: Keyword.t()) ::
              {:ok, scene}
              | :ignore
              | {:stop, reason}
            when scene: Scenic.Scene.t(), reason: term()

  @callback validate_layout(config :: struct()) :: :ok | {:error, error: any()}

  @callback handle_section_update(
              layout :: Scene.t(),
              layout_tracker :: any(),
              section_graph :: Graph.t()
            ) :: Scene.t()

  @callback handle_config_update(scene :: Scene.t(), config :: struct()) :: Scene.t()

  @callback handle_sections_update(scene :: Scene.t(), sections :: map()) :: Scene.t()

  @callback handle_viewport_update(scene :: Scene.t(), viewport_size :: tuple()) :: Scene.t()

  @optional_callbacks validate_layout: 1,
                      handle_config_update: 2,
                      handle_sections_update: 2,
                      handle_viewport_update: 2

  @doc false
  defmacro __using__(opts) do
    quote location: :keep do
      @behaviour unquote(__MODULE__)

      import Ecto.Changeset
      use Ecto.Schema

      use Scenic.Component, unquote(opts)

      def validate(layout_id) do
        layout = LayoutStore.get(layout_id)

        if Kernel.function_exported?(__MODULE__, :validate_layout, 1) do
          case Kernel.apply(__MODULE__, :validate_layout, [layout.config]) do
            :ok -> :ok
            {:error, msg} -> raise msg
          end
        end

        {:ok, layout_id}
      end

      def init(
            %Scenic.Scene{} = scene,
            layout_id,
            opts
          ) do
        layout = LayoutStore.get(layout_id)

        viewport_size = System.viewport_size()

        sections =
          layout.sections
          |> Enum.map(fn {location, section_ids} ->
            {location, section_ids |> Enum.map(fn id -> SectionStore.get(id) end)}
          end)
          |> Enum.into(%{})

        ReflectOS.Kernel.Settings.LayoutStore.subscribe(layout_id)
        ReflectOS.Kernel.Settings.System.subscribe("viewport_size")

        args = %{
          config: layout.config,
          sections: sections,
          viewport_size: viewport_size
        }

        init_layout(scene, args, opts)
      end

      # Handle update to layout config
      def handle_info(
            %PropertyTable.Event{
              property: ["layouts", _layout_id],
              value: layout,
              previous_value: previous
            },
            scene
          )
          when previous.config != layout.config do
        scene =
          if Kernel.function_exported?(__MODULE__, :handle_config_update, 2) do
            config = struct(__MODULE__, layout.config)
            Kernel.apply(__MODULE__, :handle_config_update, [scene, config])
          else
            exit({:shutdown, :config_update})
            scene
          end

        {:noreply, scene}
      end

      # Handle update to layout sections
      def handle_info(
            %PropertyTable.Event{
              property: ["layouts", _layout_id],
              value: layout,
              previous_value: previous
            },
            scene
          )
          when previous.sections != layout.sections do
        scene =
          if Kernel.function_exported?(__MODULE__, :handle_sections_update, 2) do
            Kernel.apply(__MODULE__, :handle_sections_update, [scene, layout.sections])
          else
            exit({:shutdown, :sections_update})
            scene
          end

        {:noreply, scene}
      end

      # Handle update to view port size
      def handle_info(
            %PropertyTable.Event{
              property: ["system", "viewport_size"],
              value: layout_size
            },
            scene
          ) do
        scene =
          if Kernel.function_exported?(__MODULE__, :handle_viewport_update, 2) do
            Kernel.apply(__MODULE__, :handle_viewport_update, [scene, layout_size])
          else
            exit({:shutdown, :viewport_size_update})
            scene
          end

        {:noreply, scene}
      end

      def handle_info(%PropertyTable.Event{} = _event, scene), do: {:noreply, scene}

      def handle_info(
            {:section_graph_updated, layout_tracker, %Scenic.Graph{} = graph},
            %Scenic.Scene{} = layout
          ) do
        layout = handle_section_update(layout, layout_tracker, graph)

        {:noreply, layout}
      end
    end
  end
end
