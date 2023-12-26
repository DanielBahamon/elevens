module DuelsHelper
  def calculate_event_time(event)
    if event.present? && event.start_date.present?
      time_remaining = event.start_date - DateTime.now

      if time_remaining <= 0
        return event.start_date.strftime("%H:%M %p - %B %d, %Y")
      elsif time_remaining <= 2.weeks
        days = time_remaining.to_i / 1.day.to_i
        hours = (time_remaining.to_i % 1.day.to_i) / 1.hour.to_i
        minutes = (time_remaining.to_i % 1.hour.to_i) / 1.minute.to_i
        seconds = (time_remaining.to_i % 1.minute.to_i)
        return "#{days}d #{hours}h #{minutes}m #{seconds}s"
      else
        return event.start_date.strftime("%b %d, %Y %H:%M %p")
      end
    else
      return "" # o algún valor predeterminado si el evento no está presente o su fecha es nula
    end
  end
end
