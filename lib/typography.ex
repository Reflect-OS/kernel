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
  def h2(styles \\ []) do
    [font_size: 72] ++ styles
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
  def h3(styles \\ []) do
    [font_size: 64] ++ styles
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
  def h4(styles \\ []) do
    [font_size: 56] ++ styles
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
  def h5(styles \\ []) do
    [font_size: 48] ++ styles
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
  def h6(styles \\ []) do
    [font_size: 40] ++ styles
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
  def h7(styles \\ []) do
    [font_size: 32] ++ styles
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
  def p(styles \\ []) do
    [font_size: 24] ++ styles
  end

  ############
  # Font Weight
  ############

  @doc """
  Sets the `font` to `:roboto_bold` and returns the style list for
  method piping.  `styles` defaults to an empty list so that
  this method can be used to start piping.

      iex> p() |> bold()
      [font: :roboto_bold, font_size: 24]

      iex> bold()
      [font: :roboto_bold]
  """
  @spec bold(styles :: Keyword.t()) :: Keyword.t()
  def bold(styles \\ []) do
    [font: :roboto_bold] ++ styles
  end

  @doc """
  Sets the `font` to `:roboto_bold` and returns the style list for
  method piping.  `styles` defaults to an empty list so that
  this method can be used to start piping.

      iex> p() |> light()
      [font: :roboto_light, font_size: 24]

      iex> light()
      [font: :roboto_light]
  """
  @spec light(styles :: Keyword.t()) :: Keyword.t()
  def light(styles \\ []) do
    [font: :roboto_light] ++ styles
  end
end
