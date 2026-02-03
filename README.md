# ADHD Hyperfocus Battery

**Full-screen low battery alerts for the hyperfocused mind** — Because when you're in the zone, regular notifications don't cut it.

![macOS](https://img.shields.io/badge/macOS-13.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Why?

You know the feeling: You're deep in hyperfocus mode, crushing it on a project, when suddenly... your laptop dies. The tiny macOS battery warning at 10%? You dismissed it without even noticing.

**ADHD Hyperfocus Battery** shows a **full-screen alert** that breaks through your focus state before disaster strikes.

Built for:
- People with ADHD who hyperfocus and lose track of everything else
- Anyone who gets "in the zone" and ignores notifications
- Remote workers, students, and creatives who can't afford to lose their work

## Features

- **Full-Screen Alerts** — Impossible-to-miss warnings with liquid glass UI
- **Customizable Threshold** — Set alert level from 1% to 50% (default: 7%)
- **Snooze Option** — "Not now" = remind me in 5 minutes
- **Launch at Login** — Runs quietly in your menu bar
- **Alert Sound** — Optional audio to break through headphones
- **ADHD-Friendly Design** — Built with neurodivergent users in mind

## Screenshots

*Coming soon*

## Installation

### From Mac App Store

*Coming soon*

### Build from Source

1. Clone the repository
2. Open `deadbatterydummies.xcodeproj` in Xcode
3. Build and run (⌘R)

**Requirements:**
- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later

## Usage

1. Launch the app — it appears as a brain icon in your menu bar
2. Click to access settings
3. Adjust your alert threshold
4. Enable "Launch at Login" for always-on protection

When your battery drops to the threshold:
- A full-screen glass alert appears
- Click **Dismiss** or press Escape to close
- Click **Snooze** to be reminded in 5 minutes

## Tech Stack

- **SwiftUI** — Modern declarative UI with liquid glass effects
- **IOKit** — Event-driven battery monitoring (zero CPU when idle)
- **SMAppService** — Launch at login
- **App Sandbox** — Secure, App Store compliant

## Privacy

ADHD Hyperfocus Battery collects **no data**. All preferences are stored locally. See [PRIVACY_POLICY.md](PRIVACY_POLICY.md).

## License

MIT License — see [LICENSE](LICENSE) for details.

## Contributing

Issues and pull requests welcome!

---

Made with ❤️ for the hyperfocused community
