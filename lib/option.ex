defmodule ReflectOS.Kernel.Option do
  @moduledoc """
  Defines the struct used by sections, layouts, and layout managers to
  present configuration options to users in the ReflectOS Console UI.

  ## Struct Fields
  * **key** [required]: The key of the field in the configuration schema.
  * **label** [required]: Label used for the HTML input in the Console UI.
  * **hidden** [optional]: Function which determines whether or not this
  input should be displayed.  Takes a single argument, which is a map of
  configuration values as the user fills out the configuration form.
  * **config** [required]: A map which is passed directly to the HTML input
  in the Console UI.

  ## Examples

  ### Simple Text Input

  This example shows a minimal option.

      %Option{
        key: :rss_feed,
        label: "RSS Feed Url"
      }

  ### Select Input

  This example shows a select input - note that the list of options is
  populated at runtime, not at compile time.  This provides quite a bit of
  flexibility.

      %Option{
        key: :time_format,
        label: "Time Format",
        config: %{
          type: "select",
          options: [
            {"12 Hour (6:30 PM)", "%-I:%M %p"},
            {"24 Hour (18:30)", "%-H:%M"},
            {"System Default [\#{case System.time_format() do
              "%-I:%M %p" -> "12 Hour (6:30 PM)"
              "%-H:%M" -> "24 Hour (18:30)"
              _ -> ""
              end}]", "system"}
          ]
        }
      }

  ### Input with Help Text

  This example shows how to display help text, which is displayed under
  the input to provide the user more information on how to fill in the field.

  Note that `help_text` takes a single arity function which MUST take an argument called
  `assigns` and return the result of a `Phoenix.Component.sigil_H/2`.

  The ReflectOS Console uses the
  [Flowbite CSS Library](https://flowbite.com/docs/getting-started/introduction/)
  for styling, so feel free to use any of the css classes that it provides!

      %Option{
        key: :rss_feed,
        label: "RSS Feed Url",
        help_text: fn assigns ->
          ~H\"\"\"
          Web address of the RSS feed.  Some popular examples can be found
          <a
            class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
            href="https://github.com/plenaryapp/awesome-rss-feeds?tab=readme-ov-file#-United-States"
            target="_blank">
            here
          </a>.
          \"\"\"
        end
      }

  ### Hiding Inputs

  The `hidden` field allows you specify when the input should be hidden
  based on the current values the user has provided in the configuration
  form.

  Consider this common example where the text input for the label is only
  shown if the user elects to show the label.

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
  """
  @enforce_keys [:key, :label]

  defstruct key: nil,
            label: nil,
            hidden: nil,
            config: %{}

  @type t :: %__MODULE__{
          key: atom(),
          label: String.t(),
          hidden: function(),
          config: map()
        }
end
