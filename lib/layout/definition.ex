defmodule ReflectOS.Kernel.Layout.Definition do
  @moduledoc """
  Holds the layout definition struct.

  ## Struct Fields
  * **name** [required]: The name of the layout type when it's
  displayed in the Console UI.
  * **icon** [required]: An SVG in raw string format which will be displayed
  next to layout in the Console UI.
  * **description** [optional]: A short description of the layout. If provided,
  must be a single arity function an argument called `assigns` which returns
  a compiled `HEEx` component.  The best way to accomplish this is to
  use the `Phoenix.LiveView.sigil_H/2` macro.
  * **locations** [required]: A list of locations in the format
  `%{key: :my_location, label: "MyLocation"}` indicating where users can place
  sections in your layout.

  ## Example

  Here an example adapted from the `FourCorner` layout in ReflectOS Core:

      %Definition{
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
  """

  @enforce_keys [:name, :icon]

  @type t :: %__MODULE__{
          name: binary(),
          description: (map() -> Macro.t()) | nil,
          icon: binary(),
          locations: list(%{key: atom(), label: binary()})
        }

  defstruct name: nil,
            description: nil,
            icon: nil,
            locations: []
end
