defmodule ReflectOS.Kernel.MixProject do
  use Mix.Project

  @version Path.join(__DIR__, "VERSION")
           |> File.read!()
           |> String.trim()

  @source_url "https://github.com/Reflect-OS/kernel"

  def project do
    [
      app: :reflect_os_kernel,
      description: description(),
      version: @version,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [ignore_modules: [~r/ReflectOS\.Kernel\.Test/], summary: [threshold: 80]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ReflectOS.Kernel.Application, []},
      extra_applications: [:logger],
      registered: [CubDB, ReflectOS.PubSub, ReflectOS.Notification]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:property_table, "~> 0.2.5"},
      {:scenic, "~>  0.11.2"},
      {:qrcode_ex, "~> 0.1.0"},
      {:uuid, "~> 1.1"},
      {:ecto, "~> 3.12"}
    ]
  end

  defp docs do
    [
      name: "ReflectOS Kernel",
      source_url: "https://github.com/Reflect-OS/kernel",
      homepage_url: "https://github.com/Reflect-OS/kernel",
      source_ref: "v#{@version}",
      extras: ["README.md"],
      main: "readme",
      groups_for_modules: groups_for_modules()
    ]
  end

  defp groups_for_modules do
    [
      Sections: [
        ReflectOS.Kernel.Section,
        ReflectOS.Kernel.Section.Definition,
        ReflectOS.Kernel.Section.Registry
      ],
      Layouts: [
        ReflectOS.Kernel.Layout,
        ReflectOS.Kernel.Layout.Definition,
        ReflectOS.Kernel.Layout.Registry
      ],
      "Layout Managers": [
        ReflectOS.Kernel.LayoutManager,
        ReflectOS.Kernel.LayoutManager.Definition,
        ReflectOS.Kernel.LayoutManager.State,
        ReflectOS.Kernel.LayoutManager.Registry
      ],
      "Configuration Options": [
        ReflectOS.Kernel.Option,
        ReflectOS.Kernel.OptionGroup
      ],
      System: [
        ReflectOS.Kernel.ActiveLayout,
        ReflectOS.Kernel.Settings.System
      ],
      "Section Helpers": [
        ReflectOS.Kernel.Primitives,
        ReflectOS.Kernel.Typography,
        ReflectOS.Kernel.GraphHelpers
      ],
      Ecto: [
        ReflectOS.Kernel.Ecto.Module
      ]
    ]
  end

  defp package do
    [
      files: package_files(),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp description do
    """
    ReflectOS Kernel is the foundation of the ReflectOS ecosystem, and provides the base set of
    modules needed to extend your ReflectOS system.
    """
  end

  defp package_files,
    do: [
      "lib",
      ".formatter.exs",
      "CHANGELOG.md",
      "LICENSE",
      "mix.exs",
      "README.md",
      "VERSION"
    ]

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]
end
