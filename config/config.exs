import Config

config :reflect_os_kernel, :settings, data_directory: "./data"

config :scenic, :assets, module: ReflectOS.Kernel.Mock.Assets
