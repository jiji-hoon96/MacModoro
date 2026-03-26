cask "macmodoro" do
  version "1.0.0"
  sha256 "91952b6afb49f64d6ebf13ef719a6351fdb4e06ca8f241595b9b8ec692dfb15b"

  url "https://github.com/jiji-hoon96/cozyScreen/releases/download/v#{version}/MacModoro-v#{version}.zip"
  name "MacModoro"
  desc "macOS menu bar pomodoro timer with animated pixel art icons"
  homepage "https://github.com/jiji-hoon96/cozyScreen"

  depends_on macos: ">= :sonoma"

  app "MacModoro.app"

  zap trash: [
    "~/Library/Application Support/MacModoro",
    "~/Library/Preferences/com.macmodoro.app.plist",
  ]
end
