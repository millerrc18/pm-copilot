module ApplicationHelper
  def current_theme
    theme = current_user&.theme
    return "dark-coral" unless user_signed_in?

    User::THEME_OPTIONS.include?(theme) ? theme : "dark-coral"
  end

  def theme_meta_color(theme = current_theme)
    case theme
    when "dark-blue"
      "#0b1120"
    when "light"
      "#f8fafc"
    else
      "#0a0d13"
    end
  end

  def search_keytip
    "Ctrl K / ⌘ K"
  end
end
