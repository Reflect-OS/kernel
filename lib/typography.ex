defmodule ReflectOS.Kernel.Typography do
  alias Scenic.Assets.Static

  ############
  # Font metrics wrappers
  ############

  def wrap(text, width, styles) do
    font_size = Keyword.get(styles, :font_size)
    typeface = Keyword.get(styles, :font, :roboto)
    {:ok, {Static.Font, fm}} = Static.meta(typeface)

    FontMetrics.wrap(text, width, font_size, fm)
  end

  ############
  # Helpers
  ############

  def font_size(styles), do: Keyword.get(styles, :font_size)

  ############
  # Font size
  ############

  def h1(opts \\ []) do
    [font_size: 80] ++ opts
  end

  def h2(opts \\ []) do
    [font_size: 72] ++ opts
  end

  def h3(opts \\ []) do
    [font_size: 64] ++ opts
  end

  def h4(opts \\ []) do
    [font_size: 56] ++ opts
  end

  def h5(opts \\ []) do
    [font_size: 48] ++ opts
  end

  def h6(opts \\ []) do
    [font_size: 40] ++ opts
  end

  def h7(opts \\ []) do
    [font_size: 32] ++ opts
  end

  def p(opts \\ []) do
    [font_size: 24] ++ opts
  end

  ############
  # Font Weight
  ############

  def bold(opts \\ []) do
    [font: :roboto_bold] ++ opts
  end

  def light(opts \\ []) do
    [font: :roboto_light] ++ opts
  end
end
