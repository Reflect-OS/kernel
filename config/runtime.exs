import Config

config :reflect_os_kernel, :system,
  time_format: "%-I:%M %p",
  viewport_size: {1080, 1920},
  timezone: "America/New_York"

config :reflect_os_kernel, :dashboard,
  sections: %{
    "default_date_time" => %{
      name: "Local Time and Date",
      module: ReflectOS.Firmware.Sections.DateTime,
      config: %{}
    }
  },
  layouts: %{
    "default" => %{
      name: "System Default",
      module: ReflectOS.Firmware.Layouts.FourCorners,
      config: %{},
      sections: %{
        top_left: [
          "default_date_time"
        ]
      }
    }
  },
  layout_managers: %{
    "default" => %{
      name: "Single Layout",
      module: ReflectOS.Firmware.LayoutManagers.Default,
      config: %{
        layout: "default_layout"
      }
    }
  },
  layout_manager: "default"
