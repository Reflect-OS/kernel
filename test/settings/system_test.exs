defmodule ReflectOS.Kernel.Settings.SystemTest do
  use ExUnit.Case

  alias ReflectOS.Kernel.Settings.SectionStore
  alias ReflectOS.Kernel.Section
  alias ReflectOS.Kernel.Settings.System

  test "time format can be set and retrieved" do
    # Arrange
    time_format = "time_format"
    assert System.time_format(time_format) == :ok

    # Assert
    assert System.time_format() == time_format
  end

  test "viewport size can be set and retrieved" do
    # Arrange
    viewport_size = {500, 500}
    assert System.time_format(viewport_size) == :ok

    # Assert
    assert System.viewport_size() == viewport_size
  end

  test "timezone can be set and retrieved" do
    # Arrange
    timezone = "US/Eastern"
    assert System.timezone(timezone) == :ok

    # Assert
    assert System.timezone() == timezone
  end

  test "show instructions can be set and retrieved" do
    # Arrange
    show_instructions? = false
    assert System.show_instructions?(show_instructions?) == :ok

    # Assert
    assert System.show_instructions?() == show_instructions?
  end

  test "layout manager can be set and retrieved" do
    # Arrange
    layout_manager = "layout-id"
    assert System.layout_manager(layout_manager) == :ok

    # Assert
    assert System.layout_manager() == layout_manager
  end

  describe "subscribe/0" do
    test "notifies caller of changes" do
      # Arrange
      System.subscribe("timezone")

      # Act
      System.timezone("US/Pacific")

      # Assert
      assert_receive %PropertyTable.Event{
        value: "US/Pacific"
      }
    end
  end
end
