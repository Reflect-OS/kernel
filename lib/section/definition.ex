defmodule ReflectOS.Kernel.Section.Definition do
  @moduledoc """
  Holds the section definition struct.

  ## Struct Fields
  * **name** [required]: The name of the section type when it's
  displayed in the Console UI.
  * **icon** [required]: An SVG in raw string format which will be displayed
  next to section in the Console UI.
  * **description** [optional]: A short description of what the section does.
  If provided, must be a single arity function an argument called `assigns` which returns a compiled `HEEx` component.  The best way to accomplish this is to
  use the `Phoenix.LiveView.sigil_H/2` macro.
  * **auto_align** [optional, default: false]: A boolean indicating if the
  ReflectOS layout should inject styles into the `opts` argument in the
  section's`init_section` based on where the section appears in the layout.  For
  example, if your section appears on the right side of the screen, the layout
  might inject a `text_align: right` style.

  ## Example

  Here is the `Timer` example from the `ReflectOS.Kernel.Section` documentation:

      %Definition{
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
  """

  @enforce_keys [:name, :icon]

  @type t :: %__MODULE__{
          name: binary(),
          icon: binary(),
          description: (map() -> Macro.t()) | nil,
          auto_align: boolean()
        }
  defstruct name: nil,
            description: nil,
            icon: nil,
            auto_align: false
end
