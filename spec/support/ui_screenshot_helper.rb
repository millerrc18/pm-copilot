require "fileutils"

APPLE_VIEWPORTS = {
  "iphone_se" => [ 320, 568 ],
  "iphone_15_pro" => [ 393, 852 ],
  "iphone_15_pro_max" => [ 430, 932 ],
  "iphone_15_pro_landscape" => [ 852, 393 ],
  "ipad_air_11" => [ 834, 1194 ],
  "ipad_pro_12_9" => [ 1024, 1366 ],
  "ipad_pro_landscape" => [ 1366, 1024 ],
  "macbook_14" => [ 1512, 982 ]
}.freeze

module UiScreenshotHelper
  def set_viewport(width, height)
    if page.current_window.respond_to?(:resize_to)
      page.current_window.resize_to(width, height)
    elsif page.driver.browser.respond_to?(:manage)
      page.driver.browser.manage.window.resize_to(width, height)
    end
  end

  def save_ui_screenshot(page_name, device_name, state)
    dir = Rails.root.join("tmp", "screenshots", "ui", page_name)
    FileUtils.mkdir_p(dir)
    path = dir.join("#{device_name}__#{state}.png")
    page.save_screenshot(path, full: true)
  end
end
