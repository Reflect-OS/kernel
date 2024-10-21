defmodule ReflectOS.Kernel.Typography do
  @moduledoc """
  Provides a set of helper functions working with text in
   `Scenic.Scene` for ReflectOS sections.

  We recommend using these helpers to ensure a consistent look and feel
  between sections, so that they are visually cohesive when shown together
  on the user's dashboard.

  For example:

      graph
      |> text("Here is some text", [t: {10,10}] |> h5() |> light())
  """

  alias Scenic.Assets.Static

  ############
  # Font metrics wrappers
  ############

  @doc """
  Wraps the provided text so that it does not exceed the given width.

  The `styles` keyword list must contain a value for `:font_size`.
  The default is `:roboto`, but this can be overridden by providing
  a value for `:font` in the `styles` keyword list.
  """
  @spec wrap(text :: binary(), width :: number(), styles :: Keyword.t()) :: binary()
  def wrap(text, width, styles) do
    font_size = Keyword.get(styles, :font_size)
    typeface = Keyword.get(styles, :font, :roboto)
    {:ok, {Static.Font, fm}} = Static.meta(typeface)

    FontMetrics.wrap(text, width, font_size, fm)
  end

  ############
  # Helpers
  ############

  @doc """
  Extracts the `:font_size` value from the provided `styles`.

      iex> font_size([font_size: 24])
      24
  """
  @spec font_size(keyword()) :: binary() | nil
  def font_size(styles), do: Keyword.get(styles, :font_size)

  ############
  # Font size
  ############

  @doc """
  Sets the font size to 80 and returns the style list for
  method piping.  `styles` defaults to an empty list so that
  this method can be used to start piping.

      iex> h1([font: :arial])
      [font_size: 80, font: :arial]

      iex> h1()
      [font_size: 80]
  """
  @spec h1(styles :: Keyword.t()) :: Keyword.t()
  def h1(styles \\ []) do
    [font_size: 80] ++ styles
  end

  @doc """
  Sets the font size to 72 and returns the style list for
  method piping.  `styles` defaults to an empty list so that
  this method can be used to start piping.

      iex> h2([font: :arial])
      [font_size: 72, font: :arial]

      iex> h2()
      [font_size: 72]
  """
  @spec h2(styles :: Keyword.t()) :: Keyword.t()
  def h2(opts \\ []) do
    [font_size: 72] ++ opts
  end

  @doc """
  Sets the font size to 64 and returns the style list for
  method piping.  `styles` defaults to an empty list so that
  this method can be used to start piping.

      iex> h3([font: :arial])
      [font_size: 64, font: :arial]

      iex> h3()
      [font_size: 64]
  """
  @spec h3(styles :: Keyword.t()) :: Keyword.t()
  def h3(opts \\ []) do
    [font_size: 64] ++ opts
  end

  @doc """
  Sets the font size to 56 and returns the style list for
  method piping.  `styles` defaults to an empty list so that
  this method can be used to start piping.

      iex> h4([font: :arial])
      [font_size: 56, font: :arial]

      iex> h4()
      [font_size: 56]
  """
  @spec h4(styles :: Keyword.t()) :: Keyword.t()
  def h4(opts \\ []) do
    [font_size: 56] ++ opts
  end

  @doc """
  Sets the font size to 48 and returns the style list for
  method piping.  `styles` defaults to an empty list so that
  this method can be used to start piping.

      iex> h5([font: :arial])
      [font_size: 48, font: :arial]

      iex> h5()
      [font_size: 48]
  """
  @spec h5(styles :: Keyword.t()) :: Keyword.t()
  def h5(opts \\ []) do
    [font_size: 48] ++ opts
  end

  @doc """
  Sets the font size to 40 and returns the style list for
  method piping.  `styles` defaults to an empty list so that
  this method can be used to start piping.

      iex> h6([font: :arial])
      [font_size: 40, font: :arial]

      iex> h6()
      [font_size: 40]
  """
  @spec h6(styles :: Keyword.t()) :: Keyword.t()
  def h6(opts \\ []) do
    [font_size: 40] ++ opts
  end

  @doc """
  Sets the font size to 32 and returns the style list for
  method piping.  `styles` defaults to an empty list so that
  this method can be used to start piping.

      iex> h7([font: :arial])
      [font_size: 32, font: :arial]

      iex> h7()
      [font_size: 32]
  """
  @spec h7(styles :: Keyword.t()) :: Keyword.t()
  def h7(opts \\ []) do
    [font_size: 32] ++ opts
  end

  @doc """
  Sets the font size to 24 and returns the style list for
  method piping.  `styles` defaults to an empty list so that
  this method can be used to start piping.

  Intended to be used as the standard non-header font size.

      iex> p([font: :arial])
      [font_size: 24, font: :arial]

      iex> p()
      [font_size: 24]
  """
  @spec p(styles :: Keyword.t()) :: Keyword.t()
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
