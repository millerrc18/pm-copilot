module ApplicationHelper
  def search_keytip
    user_agent = request&.user_agent.to_s
    return "⌘ K" if user_agent.match?(/Mac|iPhone|iPad/i)

    "Ctrl K"
  end
end
