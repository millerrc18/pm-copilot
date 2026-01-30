ENV["FERRUM_PROCESS_TIMEOUT"] ||= "60"
ENV["FERRUM_TIMEOUT"] ||= "120"
if ENV["FERRUM_BROWSER_PATH"].nil? && File.exist?("/usr/bin/google-chrome")
  ENV["FERRUM_BROWSER_PATH"] = "/usr/bin/google-chrome"
end

require "capybara/cuprite"

Capybara.register_driver :cuprite do |app|
  browser_path = ENV["FERRUM_BROWSER_PATH"] || ENV["BROWSER_PATH"]
  browser_path ||= [
    "/usr/bin/google-chrome",
    "/usr/bin/chromium",
    "/usr/bin/chromium-browser"
  ].find { |path| File.exist?(path) }

  options = {
    browser_path: browser_path,
    headless: true,
    timeout: 120,
    process_timeout: 60,
    window_size: [1400, 900],
    inspector: false,
    js_errors: true,
    browser_options: {
      "disable-gpu" => nil,
      "no-sandbox" => nil,
      "disable-dev-shm-usage" => nil
    }
  }.compact

  Capybara::Cuprite::Driver.new(app, **options)
end

Capybara.javascript_driver = :cuprite
