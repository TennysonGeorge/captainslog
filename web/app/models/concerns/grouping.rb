# Grouping helpers for books and their collections. Used to find and create
# current, past, and upcoming collections for any given book and group setting.
module Grouping
private

  # Calculates a book collection's start and end times for any given time.
  #
  # @param [Time] time, defaults to `Time.current`. Use user's timezone for
  #   best results.
  # @return [Tuple<Time, Time>]
  def grouping_time_range(time)
    if group_by_none?
      []
    elsif group_by_day?
      [time.beginning_of_day.utc, time.end_of_day.utc]
    elsif group_by_week?
      [time.beginning_of_week.utc, time.end_of_week.utc]
    elsif group_by_month?
      [time.beginning_of_month.utc, time.end_of_month.utc]
    elsif group_by_year?
      [time.beginning_of_year.utc, time.end_of_year.utc]
    end
  end

  # Generates a book collection's time unit used to move back and forth between
  # separate collections.
  #
  # @return [::ActiveSupport::Duration]
  def grouping_time_unit
    if group_by_none?
      0
    elsif group_by_day?
      1.day
    elsif group_by_week?
      1.week
    elsif group_by_month?
      1.month
    elsif group_by_year?
      1.year
    end
  end

  # Calculates the times for the book collection that is before and after a
  # given time.
  #
  # @param [Time] time, defaults to `Time.current`. Use user's timezone for
  #   best results.
  # @return [Array<Time>]
  def grouping_prev_next_times(time)
    time_unit = grouping_time_unit
    prev_time = time - time_unit
    next_time = time + time_unit
    [prev_time, next_time]
  end
end
