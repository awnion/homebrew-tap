cask "font-afio" do
  version "0.0.17"
  sha256 "849f903fd1e3efce22644587043588d3142b6002ca2b580281ac3eb628bad746"

  url "https://github.com/awnion/custom-iosevka-nerd-font/releases/download/v#{version}/afio-#{version}.zip"
  name "AFIO"
  desc "Custom Iosevka Nerd Font with hand-picked glyph variants"
  homepage "https://github.com/awnion/custom-iosevka-nerd-font"

  font "afio-Bold.ttf"
  font "afio-Light.ttf"
  font "afio-Medium.ttf"
  font "afio-Regular.ttf"
end
