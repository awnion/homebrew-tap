class Afio < Formula
  desc "Custom Iosevka Nerd Font with hand-picked glyph variants"
  homepage "https://github.com/awnion/custom-iosevka-nerd-font"
  version "0.0.17"
  url "https://github.com/awnion/custom-iosevka-nerd-font/releases/download/v#{version}/afio-#{version}.zip"
  sha256 "849f903fd1e3efce22644587043588d3142b6002ca2b580281ac3eb628bad746"
  license any_of: ["MIT", "Apache-2.0"]

  def install
    (share/"fonts/afio").install Dir["*.ttf"]
  end

  def post_install
    if OS.mac?
      user_fonts = Pathname.new("#{ENV["HOME"]}/Library/Fonts")
      user_fonts.mkpath
      (share/"fonts/afio").each_child do |font|
        target = user_fonts/font.basename
        target.unlink if target.exist?
        FileUtils.cp(font, target)
      end
    end
  end

  test do
    assert_predicate share/"fonts/afio", :directory?
    assert_match(/\.ttf$/, Dir[share/"fonts/afio/*"].first)
  end
end
