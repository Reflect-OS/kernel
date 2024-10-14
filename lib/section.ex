defmodule ReflectOS.Kernel.Section do
  @moduledoc """

  Sections are the widgets which appear your ReflectOS screen, showing information to user.

  ## Overview

  Sections are a type of `Scenic.Scene` (which in turn is a type of GenServer) which renders a widget on the users ReflectOS Dashboard.  Like all extensions to ReflectOS, developers are also required to implement a set of callbacks which are used to allow run time configuration.  If you plan on publishing your extensions for use by others in the community, you can use these callbacks to create a thoughtful and intuitive configuration experience.

  For the runtime UI behavior, Sections follow many of the same paradigms as `Scenic.Scene` and therefore should be very familiar to for developers experienced building native user interfaces with the [Scenic Framework](https://hexdocs.pm/scenic).  With Scenic, the UI is rendered natively (e.g. not via a webview) - this allows much better performance on the devices typically used for smart mirror projects (i.e. devices with a low-profile form factor and reduced processing power such as the `Raspberry Pi Zero W` and `Zero 2 W`).

  This documentation will cover the basics, but it is highly recommended you refer to Scenic documentation for more details on using the framework to building native user interfaces.

  ## Implementing a Section

  Sections are just modules which `use ReflectOS.Kernel.Section`.  The callbacks and other requirements for a Section fall into two major categories:

  1. Configuration experience via the [ReflectOS Console](https://github.com/reflect-os) web ui.
  2. Runtime native display rendering on the smart mirror/display

  ### Configuration Experience

  In order to drive the ReflectOS console UI, sections are required to contain an `Ecto.Schema` which represents the available configuration options.  This is typically done using the [`embedded_schema/1`](https://hexdocs.pm/ecto/Ecto.Schema.html#embedded_schema/1) macro, as they are not persisted via `Ecto.Repo`.

  Note that embedding schemas in your root schema (e.g. `Ecto.Schema.embeds_many/4`) is **not currently supported**.

  Additionally, sections must implement the following callbacks which are used by the console:

  * `c:section_definition/0`
  * `c:section_options/0`
  * `c:changeset/2`

  ### Runtime native display

  In order to render the section to the ReflectOS dashboard on the device screen,
  sections are only required to implement a single callback: `c:init_section/3`.

  Sections can also optionally implement the `c:validate_section/1` and `c:handle_config_update/2` callbacks, which define section runtime functionality.

  ## By Example

  See below for an example Section which renders a simple timer on the user's
  smart mirror/display:

      defmodule ReflectOS.Core.Sections.Timer do
        # Note that section passes along any options to the underlying `Scenic.Scene`
        use ReflectOS.Kernel.Section, has_children: false

        alias ReflectOS.Core.Sections.Timer

        alias Scenic.Graph
        import Scenic.Primitives, only: [{:text, 3}]

        import Phoenix.Component, only: [sigil_H: 2]

        import ReflectOS.Kernel.Typography
        alias ReflectOS.Kernel.Section.Definition
        alias ReflectOS.Kernel.{OptionGroup, Option}
        import ReflectOS.Kernel.Components, only: [render_section_label: 2]

        #####################################################
        # Section Configuration
        #####################################################

        # This schema represents the avaible configuration options
        # for this section.
        embedded_schema do
          field(:show_label?, :boolean, default: false)
          field(:label, :string)
          field(:timer_seconds, :integer)
        end

        # This changeset will be called by the Console UI as users
        # create and update instances of the section.  Since the schema
        # above is what will be passed to your section at runtime, this is
        # a great opportunity to ensure the configuration provided will be valid.
        @impl true
        def changeset(%Timer{} = section, params \\ %{}) do
          # Standard `Ecto.Changeset`, we can cast and validate input as usual.
          section
          |> cast(params, [:show_label?, :label, :timer_seconds])
          |> validate_required([:timer_seconds])
          |> validate_number(:timer_seconds, greater_than: 0)
        end

        # This is also used by the ConsoleUI.  It provides the name, icon, and
        # description of the section. See `ReflectOS.Kernel.Section.Definition`
        # for more details.
        @impl true
        def section_definition(),
          do: %Definition{
            name: "Timer",
            icon: \"\"\"
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512">
              <!--!Font Awesome Free 6.6.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2024 Fonticons, Inc.-->
              <path d="M176 0c-17.7 0-32 14.3-32 32s14.3 32 32 32l16 0 0 34.4C92.3 113.8 16 200 16 304c0 114.9 93.1 208 208 208s208-93.1 208-208c0-41.8-12.3-80.7-33.5-113.2l24.1-24.1c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0L355.7 143c-28.1-23-62.2-38.8-99.7-44.6L256 64l16 0c17.7 0 32-14.3 32-32s-14.3-32-32-32L224 0 176 0zm72 192l0 128c0 13.3-10.7 24-24 24s-24-10.7-24-24l0-128c0-13.3 10.7-24 24-24s24 10.7 24 24z"/>
            </svg>
          \"\"\",
          description: fn assigns ->
            ~H\"\"\"
            This section allows you to configure a timer for your ReflectOS dashboard, which will count down to zero.
            <br />
            <br />
            To start a new time after it reaches zero, simply update the sections configuration with a new timer.
            \"\"\"
          end
        }

        # These are the options which will be displayed to the user in the
        # section configuration form in the Console UI.  Note that the `key`
        # property must match the field in your Ecto schema.
        # See the `ReflectOS.Kernel.Option` documentation for more details.
        @impl true
        def section_options(),
          do: [
            # Option groups allow you to visually group fields together
            # in the Console UI.  They have no effect on the structure of the
            # the data in your schema.
            %OptionGroup{
              label: "Label",
              options: [
                %Option{
                  key: :show_label?,
                  label: "Show Label",
                  config: %{
                    type: "checkbox"
                  }
                },
                %Option{
                  key: :label,
                  label: "Label Text",
                  hidden: fn %{show_label?: show_label?} ->
                    !show_label?
                  end
                }
              ]
            },
            # Timer
            %Option{
              key: :timer_seconds,
              label: "Timer (seconds)",
              config: %{
                type: "tel"
              }
            }
          ]

        #####################################################
        # Section Runtime
        #####################################################

        @impl true
        def init_section(scene, %Timer{} = section_config, _opts) do
          # Here we simply store all of the fields in the section's configuration
          # struct (see the embedded_schema above) in the Scene's `assigns`
          # and then render the UI.
          scene =
            scene
            |> assign(Map.from_struct(section_config))
            |> render()

          # As mentioned above, Scene's are Genservers, so we can send messages just like we typically would.
          Process.send_after(self(), :tick_timer, 1_000)

          # `init_section/3` supports all the returns types supported by `Scenic.Scene.init/3`
          {:ok, scene}
        end

        @impl GenServer
        def handle_info(:tick_timer, scene) do
          # Gets the `:timer_seconds` from the `Scene.assigns`
          # (which we set from the config in the `init_section` callback) and subtracts 1
          timer_seconds = get(scene, :timer_seconds) - 1

          # Assign the updated timer and re-render the scene
          scene =
            scene
            |> assign(:timer_seconds, timer_seconds)
            |> render()

          # We only want to tick the timer until it reaches zero
          if timer_seconds > 0 do
            Process.send_after(self(), :tick_timer, 1_000)
          end

          # return from the `handle_info/2` like normal.
          {:noreply, scene}
        end

        defp render(%Scenic.Scene{} = scene) do
          # Here we render the graph to either show the remaining time or
          # that the timer has reached zero.  The `h2()` and `bold()` functions
          # are helpers provided by `ReflectOS.Kernel.Typography` to help create
          # a consistent look and feel.
          graph =
            case scene.assigns[:timer_seconds] do
              timer_seconds when timer_seconds > 0 ->
                Graph.build()
                |> text(
                  "Timer will go off in \#{timer_seconds} seconds.",
                  h2()
                  |> bold()
                )

              _ ->
                Graph.build()
                |> text(
                  "Timer has completed!",
                  h2()
                  |> bold()
                )
            end

          label_config =
            scene.assigns
            |> Map.take([:show_label?, :label])

          # Use one of the `ReflectOS.Kernel.Components` to render a label
          # This MUST be called after the graph is complete.
          graph =
            render_section_label(graph, label_config)

          # Note that we use `push_section/2` instead of the typical `Scenic.Scene.push_graph/3`
          push_section(scene, graph)
        end
      end

  For more detailed examples of ReflectOS Sections, see the [ReflectOS Core](https://github.com/Reflect-OS/core/tree/main/lib/sections) sections, which are shipped with the pre-built system firmware.

  ## Look and Feel Consistency

  As you saw in the example above, one of the goals of ReflectOS is to create a cohesive visual experience for users - that is, there is styling consistency across all the sections displayed at any given time.  One of the goals of ReflectOS is to be the one screen in your home that is not constantly trying to get your attention - it should blend into it's environment, but be available for information when needed.

  If you plan on publishing your extension for others to use, please consider following some basic styling guidelines:

  * **Use black, white, and grayscale colors only**.  Since many users will be using your section behind a one-way mirror, white text on a black background generally provides the best contrast (this is the default).  Colors are more easily washed out by the reflection of the surrounding environment.

  * **Use font size and weight (e.g. bold, normal, light) to establish an information hierarchy**.  Think about the most important information in your section, which you'd like to be available "at a glance", and use large font sizes or bold text or both make it more prominent.  For information with lower priority, use smaller font sizes or light text or both - not everything generall needs to be read from across the room!  Particuarly with a fixed screen size (no scrolling), space is at a premium and using smaller, more compact text wherever possible helps conserve space.

  * **Sections define their own width and height**.  Native UIs using Scenic don't have the same flexible layout tools (e.g. flexbox) as HTML.  Thus, sections are responsible for establishing their own width - this means wrapping their own text as needed (see `FontMetrics.wrap/5`), properly sizing images, etc.

  ## Tips and Tricks

  * **Provide as many defaults as possible in your `embedded_schema`**.  Ease of use is a first-order concern for ReflectOS, so providing reasonable defaults wherever possible is a great way to make it quick an easy for users to get started with your section while also providing them with a high level of customization.

  * **Use `push_section/2` instead of `push_graph`**.  To render a `Scenic.Graph` within a `Scenic.Scene`, one would typically use the `Scenic.Scene.push_graph/2` function.  However, Sections must use `push_section/2` instead to ensure proper positioning within the Layout.

  * **To aid with styling, use the helpers provide in this library**.  For more details, see `ReflectOS.Kernel.Typography` and `ReflectOS.Kernel.Components`.

  * **Use the `config` field on `ReflectOS.Kernel.Option`**.  This can be used to pass properties directly to the HTML input in the Console UI.  For example, you could use the `placeholder` property to show what the input might look like.

  * **You can subscribe to System Settings updates**.  If your section uses values from the System Settings (such as the timezone), you can subscribe to changes so you can update the rendered section in realtime.  See `ReflectOS.Kernel.Settings.System` for more details.
  """

  require Logger

  require Ecto.Schema
  alias __MODULE__

  alias Scenic.Scene

  alias ReflectOS.Kernel.{Option, OptionGroup}
  alias ReflectOS.Kernel.Settings.SectionStore
  alias ReflectOS.Kernel.Section.Definition

  @doc false
  @type t :: %Section{
          id: binary(),
          name: binary(),
          module: module(),
          config: map()
        }

  defstruct id: nil,
            name: nil,
            module: nil,
            config: %{}

  @doc """
  Provides the `ReflectOS.Kernel.Section.Definition` struct for the section.

  This is used to show your section in the Console UI.  From the `Timer` example above:

      def section_definition(),
        do: %Definition{
          name: "Timer",
          icon: \"\"\"
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512">
            <!--!Font Awesome Free 6.6.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2024 Fonticons, Inc.-->
            <path d="M176 0c-17.7 0-32 14.3-32 32s14.3 32 32 32l16 0 0 34.4C92.3 113.8 16 200 16 304c0 114.9 93.1 208 208 208s208-93.1 208-208c0-41.8-12.3-80.7-33.5-113.2l24.1-24.1c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0L355.7 143c-28.1-23-62.2-38.8-99.7-44.6L256 64l16 0c17.7 0 32-14.3 32-32s-14.3-32-32-32L224 0 176 0zm72 192l0 128c0 13.3-10.7 24-24 24s-24-10.7-24-24l0-128c0-13.3 10.7-24 24-24s24 10.7 24 24z"/>
          </svg>
        \"\"\",
        description: fn assigns ->
          ~H\"\"\"
          This section allows you to configure a timer for your ReflectOS dashboard, which will count down to zero.
          <br />
          <br />
          To start a new time after it reaches zero, simply update the sections configuration with a new timer.
          \"\"\"
        end
      }
  Note that the `icon` property is passed in as simple string, while the `description` property takes a function which can be passed to `Phoenix.LiveView`.  This allows you to use html in your description.  Additionally,
  note that the argument must be called `assigns`.

  See `ReflectOS.Kernel.Section.Definition` for more details.
  """
  @callback section_definition() :: Definition.t()

  @doc """
  Provides the list of options which can be configured through the ReflectOS console.

  From the `Timer` example above:

      def section_options(),
        do: [
          %OptionGroup{
            label: "Label",
            options: [
              %Option{
                key: :show_label?,
                label: "Show Label",
                config: %{
                  type: "checkbox"
                }
              },
              %Option{
                key: :label,
                label: "Label Text",
                hidden: fn %{show_label?: show_label?} ->
                  !show_label?
                end
              }
            ]
          },
          # Timer
          %Option{
            key: :timer_seconds,
            label: "Timer (seconds)",
            config: %{
              type: "tel"
            }
          }
        ]

  Note that any properties in the `config` map will be passed directly to the HTML input in the Console UI configuration form.

  See `ReflectOS.Kernel.Option` and `ReflectOS.Kernel.OptionGroup` for more information.
  """
  @callback section_options() :: [Option.t() | OptionGroup.t()]

  @doc """
  Used to cast and validate input from the user via the ReflectOS console web ui.

  Can be used like a standard `Ecto.Changeset`.  Here is the callback from the `Timer` example section above:

      @impl true
      def changeset(%Timer{} = section, params \\ %{}) do
        section
        |> cast(params, [:show_label?, :label, :timer_seconds])
        |> validate_required([:timer_seconds])
        |> validate_number(:timer_seconds, greater_than: 0)
      end
  """
  @callback changeset(section :: Ecto.Schema.embedded_schema(), params :: %{binary() => any()}) ::
              Ecto.Changeset.t()

  @doc """
  Callback invoked during initialization of the section.

  Wraps the `c:Scenic.Scene.init/3` callback, and allows the same return values.  The `config` argument will be the populated `Ecto.Schema` defined in your section module.  The `options` argument may contain a `styles` property which can use to pass styles from the ReflectOS layout to your graph if you like.

  From the `Timer` example above:

      def init_section(scene, %Timer{} = section_config, _opts) do
        scene =
          scene
          |> assign(Map.from_struct(section_config))
          |> render()

        # As mentioned above, Scene's are Genservers, so we can send messages just like we typically would.
        Process.send_after(self(), :tick_timer, 1_000)

        {:ok, scene}
      end
  """
  @callback init_section(
              scene :: Scenic.Scene.t(),
              config :: Ecto.Schema.embedded_schema(),
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
  Optional callback to validate the section config at runtime.

  This is likely to be rarely used, as sections use the `c:changeset/2` callback to validate the configuration from the user, but is provided as it can be useful during development to ensure configuration your section is receiving matches what you expect.
  """
  @callback validate_section(config :: struct()) :: :ok | {:error, error: any()}

  @doc """
  Optional callback for when users update a section's configuration while it's displayed on the ReflectOS dashboard.

  The default behavior when section configuration changes is to restart the section process with the new configuration.  This will likely work in most circumstances, but you can override this behavior if it is desirable (e.g. your scene has a lengthy start up time).
  """
  @callback handle_config_update(scene :: Scene.t(), config :: struct()) :: Scene.t()

  @optional_callbacks validate_section: 1, handle_config_update: 2

  @doc false
  defmacro __using__(opts) do
    quote location: :keep do
      @behaviour unquote(__MODULE__)

      use Scenic.Component, unquote(opts)
      import Ecto.Changeset
      use Ecto.Schema

      @primary_key false

      import unquote(__MODULE__),
        only: [
          push_section: 2
        ]

      def validate({layout_tracker, section_id} = init_args) do
        section = SectionStore.get(section_id)

        if Kernel.function_exported?(__MODULE__, :validate_section, 1) do
          case Kernel.apply(__MODULE__, :validate_section, [section.config]) do
            :ok -> :ok
            {:error, msg} -> raise msg
          end
        end

        {:ok, init_args}
      end

      def init(
            %Scenic.Scene{} = scene,
            {layout_tracker, section_id},
            opts
          ) do
        section = SectionStore.get(section_id)

        scene =
          scene
          |> assign(:__layout_tracker, layout_tracker)

        ReflectOS.Kernel.Settings.SectionStore.subscribe(section_id)

        init_section(scene, section.config, opts)
      end

      # Handle update to section, but only if the config changes
      def handle_info(
            %PropertyTable.Event{
              property: ["sections", _section_id],
              value: section,
              previous_value: previous
            },
            scene
          )
          when previous.config != section.config do
        scene =
          if Kernel.function_exported?(__MODULE__, :handle_config_update, 2) do
            config = struct(__MODULE__, section.config)
            Kernel.apply(__MODULE__, :handle_config_update, [scene, config])
          else
            exit({:shutdown, :config_update})
            scene
          end

        {:noreply, scene}
      end

      def handle_info(%PropertyTable.Event{property: ["sections", _section_id]} = _event, scene),
        do: {:noreply, scene}
    end
  end

  @doc """
  Renders the section's graph to the ReflectOS layout.

  This is wrapper around `Scenic.Scene.push_graph/3`, and must be used to push graph as ensures any changes to the size of the section are accomodated by the current layout.
  """
  @spec push_section(Scenic.Scene.t(), Scenic.Graph.t()) :: Scenic.Scene.t()
  def push_section(
        %Scenic.Scene{assigns: %{__layout_tracker: layout_tracker}} = scene,
        %Scenic.Graph{} = graph
      ) do
    # Notify Layout that the section has been updated
    Scenic.Scene.send_parent(scene, {:section_graph_updated, layout_tracker, graph})
    Scenic.Scene.push_graph(scene, graph)
  end
end
