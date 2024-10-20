defmodule ReflectOS.Kernel.Layout do
  @moduledoc """

  Layouts define the arrangment of sections on the screen.

  ## Overview

  Layouts are a type of `Scenic.Scene` (which in turn is a type of GenServer) which defines the arrangement of sections on the users ReflectOS Dashboard.  For example, the `FourCorners` layouts which ships with ReflectOS allows users to place sections in the top left, top right, bottom left, and bottom right corners of the dashboard.  Layouts are passed their configuration, the screen size, and the sections the user has selected to display and are expected to render those sections to the screen.

  Like all extensions to ReflectOS, developers are also required to implement a set of callbacks which are used to allow run time configuration.  If you plan on publishing your extensions for use by others in the community, you can use these callbacks to create a thoughtful and intuitive configuration experience.

  For the runtime UI behavior, Layouts follow many of the same paradigms as `Scenic.Scene` and therefore should be very familiar to for developers experienced building native user interfaces with the [Scenic Framework](https://hexdocs.pm/scenic).  With Scenic, the UI is rendered natively (e.g. not via a webview) - this allows much better performance on the devices typically used for smart mirror projects (i.e. devices with a low-profile form factor and reduced processing power such as the `Raspberry Pi Zero W` and `Zero 2 W`).

  This means that Layouts take on an important responsibility in the ReflecOS
  system since the typical tools available in webviews (e.g. `flexbox`) are not
  available.

  ## Layout Locations

  Layouts define a list of available "locations" in their `ReflectOS.Kernel.Layout.Definition`, which are essentially areas of the screen where users can place one or more sections.  Layouts are responsible for adding each section to the layout's graph and using `Scenic.Primitive.Transform.Translate` to ensure the section is located in the right place on the screen.

  ## Rendering Sections

  Since a `ReflectOS.Kernel.Section` is just a wrapped `Scenic.Component`,
  Layouts can call `c:Scenic.Component.add_to_graph/3` to render them to the
  the layouts graph.  For example, your layout might contain the following
  function:

      def render_section(%Scenic.Graph{} = graph, %Section{} = section, layout_tracker, x, y) do
        %{id: section_id, module: section_module} = section

        graph
        |> section_module.add_to_graph({layout_tracker, section_id}, t: {x, y})
      end

  Note that the `add_to_graph` function must be called with a two-part tuple
  in the format `{layout_tracker, section_id}` as the second argument, where `layout_tracker` is a unique id assigned by the layout used to identify the
  section and `section_id` is the id of the section being rendered.

  Note that you should avoid using the `section_id` as the layout tracker,
  since users are permitted to add the same section multiple times to the same
  layout.

  ## Implementing a Layout

  Layouts are just modules which `use ReflectOS.Kernel.Layout`.  The callbacks and other requirements for a Layout fall into two major categories:

  1. Configuration experience via the [ReflectOS Console](https://github.com/reflect-os/console) web ui.
  2. Runtime native display rendering on the smart mirror/display

  ### Configuration Experience

  In order to drive the ReflectOS console UI, layouts are required to contain an `Ecto.Schema` which represents the available configuration options.  This is typically done using the [`embedded_schema/1`](https://hexdocs.pm/ecto/Ecto.Schema.html#embedded_schema/1) macro, as they are not persisted via `Ecto.Repo`.

  Note that embedding schemas in your root schema (e.g. `Ecto.Schema.embeds_many/4`) is **not currently supported**.

  Additionally, layouts must implement the following callbacks which are used by the console:

  * `c:layout_definition/0`
  * `c:layout_options/0`
  * `c:changeset/2`

  ### Runtime native display

  In order to render the layout ReflectOS dashboard, modules are required to implement the following callbacks:

  * `c:init_layout/3`
  * `c:handle_section_update/3`

  `Layouts` can also optionally implement the following callbacks:

  * `c:validate_layout/1`
  * `c:handle_config_update/2`
  * `c:handle_sections_update/2`
  * `c:handle_viewport_update/2`

  See the documentation for each callback below for more details.

  ## Example

  For a complete example of a ReflectOS Layout, see the `FourCorner` layout
  from [ReflectOS Core](https://github.com/Reflect-OS/core/tree/main/lib/layouts/four_corners.ex), which is shipped with the pre-built system firmware.
  """

  alias ReflectOS.Kernel.Settings.SectionStore
  alias Scenic.Scene
  alias Scenic.Graph

  alias ReflectOS.Kernel.Settings.System
  alias ReflectOS.Kernel.Settings.LayoutStore
  alias ReflectOS.Kernel.{Option, OptionGroup}
  alias ReflectOS.Kernel.Layout.Definition
  alias ReflectOS.Kernel.Section

  @doc false
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

  @doc """
  Provides the `ReflectOS.Kernel.Layout.Definition` struct for the layout.

  This is used to show your layout in the Console UI.  See below for an
  example adapted From the `FourCorner` layout, which ships with
  the pre-built ReflectOS system:

      @doc false
      @impl ReflectOS.Kernel.Layout
      def layout_definition(),
        do: %Definition{
          name: "Four Corner",
          description: fn assigns ->
            ~H\"\"\"
            Allows placing sections in each of the four corners of the screen, with options for
            stacking (vertical vs. horizontal) and spacing.
            \"\"\"
          end,
          icon: \"\"\"
            <svg class="text-gray-800 dark:text-white" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="currentColor" viewBox="0 0 24 24">
              <path fill-rule="evenodd" d="M4.857 3A1.857 1.857 0 0 0 3 4.857v4.286C3 10.169 3.831 11 4.857 11h4.286A1.857 1.857 0 0 0 11 9.143V4.857A1.857 1.857 0 0 0 9.143 3H4.857Zm10 0A1.857 1.857 0 0 0 13 4.857v4.286c0 1.026.831 1.857 1.857 1.857h4.286A1.857 1.857 0 0 0 21 9.143V4.857A1.857 1.857 0 0 0 19.143 3h-4.286Zm-10 10A1.857 1.857 0 0 0 3 14.857v4.286C3 20.169 3.831 21 4.857 21h4.286A1.857 1.857 0 0 0 11 19.143v-4.286A1.857 1.857 0 0 0 9.143 13H4.857Zm10 0A1.857 1.857 0 0 0 13 14.857v4.286c0 1.026.831 1.857 1.857 1.857h4.286A1.857 1.857 0 0 0 21 19.143v-4.286A1.857 1.857 0 0 0 19.143 13h-4.286Z" clip-rule="evenodd"/>
            </svg>
          \"\"\",
          locations: [
            %{key: :top_left, label: "Top Left"},
            %{key: :top_right, label: "Top Right"},
            %{key: :bottom_left, label: "Bottom Left"},
            %{key: :bottom_right, label: "Bottom Right"}
          ]
        }

  Note that the `icon` property is passed in as simple string, while the `description` property takes a function which can be passed to `Phoenix.LiveView`.  This allows you to use html tags in your description.  Additionally,
  note that the argument must be called `assigns`.

  The `locations` property must be a list of maps with a `key` and a `label` property.

  See `ReflectOS.Kernel.Layout.Definition` for more details.
  """
  @callback layout_definition() :: Definition.t()

  @doc """
  Provides the list of options which can be configured through the ReflectOS console.

  General guidelines are to use `ReflectOS.Kernel.OptionGroup` to present
  configuration related to a specific layout location together.
  """
  @callback layout_options() :: [Option.t() | OptionGroup.t()]

  @doc """
  Used to cast and validate input from the user via the ReflectOS console web ui.

  Can be used like a standard `Ecto.Changeset`.  If we had a layout called `SimpleLayout` which defined an `Ecto.Schema` with a `:spacing` field, the
  changeset callback might look like this:

      @impl true
      def changeset(%SimpleLayout{} = section, params \\\\ %{}) do
        section
        |> cast(params, [:spacing])
        |> validate_required([:spacing])
        |> validate_number(:spacing, greater_than: 0)
      end
  """
  @callback changeset(
              layout_config :: Ecto.Schema.embedded_schema(),
              params :: %{binary() => any()}
            ) :: Ecto.Changeset.t()

  @doc """
  Callback invoked during initialization of the layout.

  Wraps the `c:Scenic.Scene.init/3` callback, and allows the same return values.

  The first argument is the `Scenic.Scene`.

  The second argument is a map containing three fields:
  * `config`: The `Ecto.Schema` struct defined in your layout module populated with the user's configuration.
  * `sections`: A `Map` where each key corresponds to a one of the locations
  defined in `c:layout_definition/0` and values are a list of the `ReflectOS.Kernel.Section` struct.
  * `viewport_size`: A tuple representing the screen size in `{width, height}`
  format.  The ReflectOS default is `{1080, 1920}` but can be adjusted by user.

  The last argument is a list of options which maybe passed into the layout by the system.  These are not currently used but are included to ensure
  consistency with `Scenic.Scene`.
  """
  @callback init_layout(
              scene :: Scenic.Scene.t(),
              args :: %{
                config: Ecto.Schema.embedded_schema(),
                sections: %{required(atom()) => list(Section.t())},
                viewport_size: {integer(), integer()}
              },
              options :: Keyword.t()
            ) ::
              {:ok, scene}
              | {:ok, scene, timeout :: non_neg_integer}
              | {:ok, scene, :hibernate}
              | {:ok, scene, opts :: Scenic.Scene.response_opts()}
              | :ignore
              | {:stop, reason}
            when scene: Scene.t(), reason: term()

  @doc """
  Optional callback to validate the layout config at runtime.

  This is likely to be rarely used, as layouts use the `c:changeset/2` callback to validate the configuration from the user, but is provided as it can be useful during development to ensure the configuration your layout is receiving matches what you expect.
  """
  @callback validate_layout(config :: Ecto.Schema.embedded_schema()) ::
              :ok | {:error, error: any()}

  @doc """
  Required callback to handle updates to sections rendered by the layout.

  Layouts must implement this function to handle updates to a section's graph.
  If a section's dimensions change, it may impact where it or other sections
  in the layout should be located (remember that all elements in `Scenic.Scene` are located on at fixed `x,y` location).  This callback allows layouts to
  adjust the positioning of their sections based on the new section size.

  The `layout_tracker` argument is the unique id assigned to the section by the
  layout when it calls `c:Scenic.Component.add_to_graph/3`, see the docs on [rendering sections](#module-rendering-sections) above.
  """
  @callback handle_section_update(
              layout :: Scene.t(),
              layout_tracker :: any(),
              section_graph :: Graph.t()
            ) :: Scene.t()

  @doc """
  Optional callback for when a user updates a layouts's configuration while it's displayed on the ReflectOS dashboard.

  The default behavior when layout configuration changes is to restart the layout process with the new configuration.  This will likely work in most circumstances, but you can override this behavior if it is desirable to do so.
  """
  @callback handle_config_update(scene :: Scene.t(), config :: struct()) :: Scene.t()

  @doc """
  Optional callback for when a user updates the arrangement of sections in the
  layout locations.

  The default behavior when this changes is to restart the layout process with the new section arrangement.  This will likely work in most circumstances, but you can override this behavior if it is desirable to do so.
  """
  @callback handle_sections_update(scene :: Scene.t(), sections :: map()) :: Scene.t()

  @doc """
  Optional callback for when a user updates the screen size in the ReflectOS
  system settings.

  The default behavior when this changes is to restart the layout process with the new viewport size.  This will likely work in most circumstances, but you can override this behavior if it is desirable to do so.
  """
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
