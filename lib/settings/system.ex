defmodule ReflectOS.Kernel.Settings.System do
  @moduledoc """
  This module allows you to retrieve system settings, as well as
  subscribe to changes.

  A common pattern is to default section configuration to use a
  system setting (e.g. time format), but allow users to override it
  for a given section.

  If the default system setting is used, your section can subscribe
  to changes in the setting so the display can be updated in real-time.
  System Setting uses the excellent `PropertyTable` library
  under the hood, and the message sent to your section when you subscribe
  are the standard `PropertyTable.Event` struct.

  Here is an example using the `time_format/0` function,
  excerpted from the date/time section in
  [ReflectOS Core](https://github.com/Reflect-OS/core):

      defmodule ReflectOS.Core.Sections.DateTime do
        use ReflectOS.Kernel.Section, has_children: false

        alias ReflectOS.Kernel.Settings.System
        alias ReflectOS.Kernel.Section.Definition
        alias ReflectOS.Kernel.{OptionGroup, Option}


        embedded_schema do
          # Default time format to the system setting
          field(:time_format, :string, default: "system")
        end

        def section_options(),
          do: [
            %Option{
              key: :time_format,
              label: "Hour Format",
              config: %{
                type: "select",
                options: [
                  {"12 Hour (6:30 PM)", "%-I:%M %p"},
                  {"24 Hour (18:30)", "%-H:%M"},
                  {"System Default", "system"}
                ]
              }
            }
          ]

        def init_section(scene, %__MODULE__{} = section_config, opts) do
          time_format =
            if section_config.time_format == "system" do
              # If we are using the system setting,
              # subscribe for updates
              System.subscribe("time_format")
              System.time_format()
            else
              # otherwise, use the user's selection
              section_config.time_format
            end


          {:ok, assign(scene, time_format: time_format)}
        end

        # Handle event when the time_format system setting changes.
        # This will only get called if the select time format for
        # the section is the "System Default"
        def handle_info(
              %PropertyTable.Event{
                property: ["system", "time_format"],
                value: time_format
              },
              scene
            ) do
          scene =
            scene
            |> assign(time_format: time_format)

          {:noreply, render(scene)}
        end
      end
  """
  alias ReflectOS.Kernel.Settings

  @system_settings [
    "time_format",
    "viewport_size",
    "timezone",
    "layout_manager",
    "show_instructions"
  ]

  @typedoc """
    "time_format"
    | "viewport_size"
    | "timezone"
  """
  @type system_settings_key :: String.t()

  @doc """
  Gets the system time format, which is a formatting string
  compatible with the `Calendar.strftime/3` function.
  """
  @spec time_format() :: binary()
  def time_format() do
    get("time_format")
  end

  @doc false
  def time_format(time_format) do
    put("time_format", time_format)
  end

  @doc """
  Gets the viewport (screen) size formatted as a `{width, height}` tuple.
  """
  @spec viewport_size() :: {width :: integer(), height :: integer()}
  def viewport_size() do
    get("viewport_size")
  end

  @doc false
  def viewport_size(viewport_size) do
    put("viewport_size", viewport_size)
  end

  @doc """
  Gets the system timezone.
  """
  @spec timezone() :: binary()
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

  @doc """
  Subscribes the current process to changes in the system setting.
  Works just like `PropertyTable.subscribe/2`, and will send the
  current process a `PropertyTable.Event` struct if the subscribed
  setting is updated.

  See the example above for an example of how to handle this event.
  Note that the `property` field in the struct will be in the
  format `["system", "<subscribed setting>"]`.
  """
  @spec subscribe(system_settings_key()) :: :ok
  def subscribe(key) when key in @system_settings do
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
