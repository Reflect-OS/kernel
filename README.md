# ReflectOS Kernel

## About

ReflectOS is the approachable, configurable, and extensible OS for your smart mirror project.  It is designed to allow anyone to easily install, customize, and enjoy a smart mirror/display - no coding or command line usage required!  Instructions for installing on your device and more details about ReflectOS can be found on the [ReflectOS Firmware](https://github.com/Reflect-OS/firmware) project.

This package provides the foundation for developers in the community to extend the OS by building their own sections, layouts, and layout managers.

## Building ReflectOS Extensions

### Getting Started

ReflectOS allows developers to extend it's functionality by creating elixir libraries which register the extension with the system.  New sections, layouts, and layout managers can all be added to the OS via extension libraries (which are just standard elixir packages containig new ReflectOS modules).

The best way to start building your own extension library is to create 
a standard new elixir project using the `mix new` command, for example:
```
$ mix new reflect_os_myextensions --sup
```
Note that it is a good idea to use the `--sup` option to generate the 
application calback, this is a great place to register the modules you 
build with the ReflectOS system (more on that later).

Then, bring this package to your project by adding `reflect_os_kernel` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:reflect_os_kernel, "~> 0.1.0"}
  ]
end
```

### Creating an Extension

Creating an extension is essentially just creating a module in your library which implements the proper elixir behavior.  Most extensions are comprised of a set of callbacks which describe both the runtime behavior and configuration experience through the [ReflectOS Console](https://github.com/reflect-os/console).  

See the documentation for `ReflectOS.Kernel.Section`, `ReflectOS.Kernel.Layout`, and `ReflectOS.Kernel.LayoutManager`  for more details on how to get started.

Note that while Layout Managers are built on top of `GenServer`, Sections and Layouts are built on top of `Scenic.Scene` from the [Scenic UI Framework](https://hexdocs.pm/scenic/overview_general.html).  If you are building your own Section or Layout, it is highly recommended you familiarize yourself with Scenic before getting started.

### Registering

Once created, extensions modules must be registered with ReflectOS in order to be available in the console web application which allows users to manage their displays.  Best practice is to do so via a supervised task during your application start up (this is why we recommend creating new projects with the `--sup` option).

For example:

```elixir
defmodule MyReflectOSExtensions.Application do
  @moduledoc false

  use Application

  alias ReflectOS.Kernel.Section.Registry, as: SectionRegistry
  alias ReflectOS.Kernel.Layout.Registry, as: LayoutRegistry
  alias ReflectOS.Kernel.LayoutManager.Registry, as: LayoutManagerRegistry

  @impl true
  def start(_type, _args) do
    children = [
      # Start a task to register ReflectOS extensions
      {Task, fn -> reflect_os_register() end}
    ]

    opts = [strategy: :one_for_one, name: MyReflectOSExtensions.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp reflect_os_register() do
    # Sections
    SectionRegistry.register([
      MyReflectOSExtensions.Sections.MyNewSection,
    ])

    # Layouts
    LayoutRegistry.register([
      MyReflectOSExtensions.Layouts.MyNewLayout
    ])

    # Layout Managers
    LayoutManagerRegistry.register([
      MyReflectOSExtensions.Layouts.MyNewLayoutManager
    ])
  end
end
```

### Adding Extensions to ReflectOS

To test your library and create a custom ReflectOS firmware image which includes your extensions, clone the [latest release of the ReflectOS Firmware](https://github.com/Reflect-OS/firmware/releases).  Be sure to checkout a release (e.g. use the `-b` flag), as the `main` branch may not be stable.  For example:
```
$ git clone https://github.com/reflect-os/firmware.git my_custom_firmware -b v0.9.0
```
Be sure to use the version number of the most recent release!

From there, it's as simple as adding your library as a dependency to the firmware's `mix.exs` file, we recommend starting using the `path` option to refer to a local directory during development (see `Mix.Tasks.Deps` for more information on the various way to reference a dependency).

Once you've added your extension library as a dependency, follow the getting started instructions in the [Firmware's Readme](https://github.com/Reflect-OS/firmware) to see your project in action!

### Examples

For examples of how to build your own extensions to ReflectOS, check out the [ReflectOS Core](https://github.com/Reflect-OS/core) project.  These are extensions which are shipped with the pre-built ReflectOS firmware.





## Learn More

Full documentation can found on [HexDocs](https://hexdocs.pm/reflect_os_kernel).



