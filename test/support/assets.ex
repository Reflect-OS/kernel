defmodule ReflectOS.Kernel.TestAssets do
  use Scenic.Assets.Static,
    otp_app: :reflect_os_kernel,
    sources: [
      "assets",
      {:scenic, "deps/scenic/assets"}
    ],
    alias: [
      roboto_bold: "fonts/roboto-bold.ttf",
      roboto_light: "fonts/roboto-light.ttf"
    ]
end
