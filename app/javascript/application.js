// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Change to true to allow Turbo
Turbo.session.drive = false

// Allow UJS alongside Turbo
import jquery from "jquery";
window.jQuery = jquery;
window.$ = jquery;
import Rails from "@rails/ujs"
Rails.start();

const updateSearchKeytips = () => {
  const keytips = document.querySelectorAll("[data-search-keytip]");
  if (!keytips.length) return;

  const platform = navigator.platform || "";
  const isApple = /Mac|iPhone|iPad/.test(platform);
  keytips.forEach((keytip) => {
    const macKeytip = keytip.dataset.macKeytip;
    const nonMacKeytip = keytip.dataset.nonMacKeytip;
    keytip.textContent = isApple ? macKeytip : nonMacKeytip;
  });
};

document.addEventListener("turbo:load", updateSearchKeytips);
