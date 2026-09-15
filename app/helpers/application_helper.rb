module ApplicationHelper
  # A day, shown as a day.
  def format_day(date)
    date&.strftime("%B %-d, %Y")
  end

  # An instant, shown as an instant.
  def format_instant(time)
    time&.strftime("%B %-d, %Y at %H:%M")
  end
end
