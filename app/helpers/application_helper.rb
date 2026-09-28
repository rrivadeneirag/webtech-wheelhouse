module ApplicationHelper
  # A day, shown as a day.
  def format_day(date)
    date&.strftime("%B %-d, %Y")
  end

  # An instant, shown as an instant.
  def format_instant(time)
    time&.strftime("%B %-d, %Y at %H:%M")
  end

  # "is-invalid" when any of the given attributes carries an error on the object,
  # so Bootstrap paints the field red.
  def invalid_class(object, *attributes)
    "is-invalid" if attributes.any? { |attr| object.errors[attr].present? }
  end

  # The messages attached to one field, ready to drop under it. Nothing when clean.
  def field_feedback(object, attribute)
    return if object.errors[attribute].blank?

    tag.div(object.errors[attribute].to_sentence, class: "invalid-feedback d-block")
  end
end
