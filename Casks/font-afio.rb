cask "font-afio" do
  version "0.0.18"
  sha256 "22ee20a90c873b9a068930ea44ef46525b12c655cd5d0e2de5d74acd86417592"

  url "https://github.com/awnion/custom-iosevka-nerd-font/releases/download/v#{version}/afio-#{version}.zip"
  name "AFIO"
  desc "Custom Iosevka Nerd Font with hand-picked glyph variants"
  homepage "https://github.com/awnion/custom-iosevka-nerd-font"

  font "afio-Bold.ttf"
  font "afio-Light.ttf"
  font "afio-Medium.ttf"
  font "afio-Regular.ttf"
end
