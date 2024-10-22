defmodule ReflectOS.Kernel.LayoutManager.Definition do
  @moduledoc """
  Holds the layout manager definition struct.

  ## Struct Fields
  * **name** [required]: The name of the layout manager type when it's
  displayed in the Console UI.
  * **icon** [required]: An SVG in raw string format which will be displayed
  next to layout managers in the Console UI.
  * **description** [optional]: A short description of what the section does.
  If provided, must be a single arity function an argument called `assigns` which returns a compiled `HEEx` component.
  The best way to accomplish this is to use the `Phoenix.LiveView.sigil_H/2` macro.

  ## Example

  Here is the `Static` example from the `ReflectOS.Kernel.LayoutManger` documentation:

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
  """

  @enforce_keys [:name, :icon]

  @type t :: %__MODULE__{
          name: binary(),
          icon: binary(),
          description: (map() -> Macro.t()) | nil
        }
  defstruct name: nil,
            icon: nil,
            description: nil
end
