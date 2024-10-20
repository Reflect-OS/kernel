defmodule ReflectOS.Kernel.OptionGroup do
  @moduledoc """
  Creates a visual grouping of configuration option inputs in the Console UI.

  ## Struct Fields

  * **label** [required]: Title of the input grouping.
  * **description** [optional]: A single arity function which can be passed to `Phoenix.LiveView`.
  * **options** [optional]: List of `ReflectOS.Kernel.Option` which should be
  displayed in the input grouping.

  Note that `description` takes a single arity function which MUST take an argument called
  `assigns` and return the result of a `Phoenix.Component.sigil_H/2`.  This allows
  you to use html markup in the description.  The ReflectOS Console uses the
  [Flowbite CSS Library](https://flowbite.com/docs/getting-started/introduction/)
  for styling, so feel free to use any of the css classes that it provides!

  ## Example

      %OptionGroup{
        label: "Label",
        description: fn assigns ->
          ~H\"\"\"
          The label appears over the section, and can be optionally shown or hidden.
          For more information, see the documentation
          <a
            class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
            href="https://example.com"
            target="_blank">
            here
          </a>.
          \"\"\"
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
      }
  """
  alias ReflectOS.Kernel.Option

  @enforce_keys [:label]

  defstruct label: nil,
            description: nil,
            options: []

  @type t :: %__MODULE__{
          label: String.t(),
          description: function(),
          options: list(Option.t())
        }
end
