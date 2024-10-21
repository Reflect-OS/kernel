defmodule ReflectOS.Kernel.Primatives do
  @moduledoc """
  Provides useful helpers for developing section UIs using `Scenic.Scene`
  on the ReflectOS platform.
  """
  alias Scenic.Graph
  alias Scenic.Assets.Stream
  alias Scenic.Assets.Static
  import Scenic.Primitives

  import ReflectOS.Kernel.Typography

  @doc """
  Renders a label for the given  section graph given the common configuration
  fields of `show_label?` and `label`.

  Note that the section label **must** be called after the graph is complete.

  See `section_label/3` for available options.
  """
  @spec render_section_label(
          graph :: Graph.t(),
          %{show_label?: boolean(), label: binary()},
          opts :: Keyword.t()
        ) :: Graph.t()
  def render_section_label(graph, config, opts \\ [])

  def render_section_label(%Graph{} = graph, %{show_label?: true, label: label}, opts) do
    graph
    |> section_label(label, opts)
  end

  def render_section_label(%Graph{} = graph, %{show_label?: false}, _opts), do: graph

  @doc """
  Renders a label for the given  section graph given the label text.

  Note that the section label **must** be called after the graph is complete.

  Options are:
  * `:width` - A fixed width for the section, defaults to the
  width of the section or of the label text, whichever is greater.
  * `align` - The text alignment of the label, allowed values are `:left`,
  `:center`, and `:right`.
  """
  @spec section_label(graph :: Graph.t(), label :: binary(), opts :: Keyword.t()) :: Graph.t()
  def section_label(%Graph{} = graph, label, opts \\ []) when is_binary(label) do
    {left, top, right, _bottom} =
      case Graph.bounds(graph) do
        nil ->
          {0, 0, 0, 0}

        bounds ->
          bounds
      end

    {:ok, {Static.Font, fm}} = Static.meta(:roboto_light)
    label_width = FontMetrics.width(label, 48, fm)

    section_width = right - left

    width =
      if is_number(opts[:width]) do
        opts[:width]
      else
        max(section_width, label_width)
      end

    left =
      case opts[:align] do
        :right ->
          diff = width - section_width
          left - diff

        :center ->
          left + width / 2

        _ ->
          left
      end

    v_offset = top - 16

    graph =
      graph
      |> text(label, [t: {left, v_offset - 4}, text_align: :left] |> h5 |> light())
      |> line({{left, v_offset}, {left + width, v_offset}}, stroke: {2, :white})

    graph
  end

  @doc """
  Renders a QR code on the provided `Scenic.Graph` which encodes the given `content` string.

  Uses the `QRCodeEx` library.

  Options passed on for generating a QR Code:
  * `:color`
  * `:background_color`
  * `:width`

  We recommend using the default colors, which renders
  a standard black and white QR code on a white background.

  The default `:width` is 250px.

  The remaining `opts` are passed on the underlying `Scenic.Primitives.rect/3`
  """
  @spec qr_code(graph :: Graph.t(), content :: binary(), opts :: keyword()) :: Graph.t()
  def qr_code(%Graph{} = graph, content, opts \\ []) do
    qr_code_spec(content, opts).(graph)
  end

  @doc """
  The "spec" version of `qr_code/3`, which allows it to be rendered later.

  See `Scenic.Primitives` for more information.
  """
  def qr_code_spec(content, opts \\ []) do
    default_width = 250

    {stream_id, opts} = Keyword.pop(opts, :stream_id, UUID.uuid1())

    {qr_opts, opts} =
      opts
      |> Keyword.put_new(:width, default_width)
      |> Enum.split_with(fn {k, _v} -> k in [:color, :background_color, :width] end)

    {:ok, qr_code} =
      content
      |> QRCodeEx.encode()
      |> QRCodeEx.png(qr_opts)
      |> Stream.Image.from_binary()

    {qr_width, qr_height, _} = elem(qr_code, 1)

    Stream.put(stream_id, qr_code)

    opts =
      opts
      |> Keyword.put(:fill, {:stream, stream_id})

    rectangle_spec({qr_width, qr_height}, opts)
  end
end
