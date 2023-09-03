module ApplicationHelper
  def errors_for(model, key)
    tag.div do
      model.errors.messages_for(key).join(", ")
    end
  end

  def format_time(time)
    "#{time_ago_in_words(time)} ago"
  end
end
