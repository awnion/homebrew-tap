class FontAfio < Formula
  desc "Custom Iosevka Nerd Font with hand-picked glyph variants"
  homepage "https://github.com/awnion/custom-iosevka-nerd-font"
  version "0.0.17"
  url "https://github.com/awnion/custom-iosevka-nerd-font/releases/download/v#{version}/afio-#{version}.zip"
  sha256 "849f903fd1e3efce22644587043588d3142b6002ca2b580281ac3eb628bad746"
  license any_of: ["MIT", "Apache-2.0"]

  def install
    if OS.mac?
      (share/"fonts/afio").install Dir["*.ttf"]
    else
      (share/"fonts/afio").install Dir["*.ttf"]
    end
  end

  def post_install
    if OS.mac?
      user_fonts = Pathname.new("#{ENV["HOME"]}/Library/Fonts")
      user_fonts.mkpath
      (share/"fonts/afio").each_child do |font|
        FileUtils.ln_sf(font, user_fonts/font.basename)
      end
    else
      user_fonts = Pathname.new("#{ENV["HOME"]}/.local/share/fonts")
      user_fonts.mkpath
      (share/"fonts/afio").each_child do |font|
        FileUtils.ln_sf(font, user_fonts/font.basename)
      end
      system "fc-cache", "-fv", user_fonts if which("fc-cache")
    end
  end

  test do
    assert_predicate share/"fonts/afio", :directory?
    assert_match(/\.ttf$/, Dir[share/"fonts/afio/*"].first)
  end
end
