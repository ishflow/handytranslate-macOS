# HandyTranslate macOS

Native macOS menu bar app that instantly translates text between Turkish and English using OpenAI API.

## How It Works

1. Type text in any app (Notes, Slack, WhatsApp, Discord, etc.)
2. Press **⌘⇧⌥M**
3. Text is selected, translated, and replaced — all in one step

No floating windows, no popups. Just a keyboard shortcut that works everywhere.

## Features

- **Global shortcut (⌘⇧⌥M)** — works in every app, no Accessibility permission needed
- **Auto-detect language** — Turkish → English, English → Turkish
- **Menu bar status** — shows translation progress in the menu bar icon
- **Clipboard-safe** — saves and restores your clipboard during translation
- **Lightweight** — runs as a menu bar app (no Dock icon)

## Requirements

- macOS 13.0+
- OpenAI API key

## Setup

1. Install [xcodegen](https://github.com/yonaskolb/XcodeGen):
   ```bash
   brew install xcodegen
   ```
2. Generate the Xcode project:
   ```bash
   xcodegen generate
   ```
3. Build and run:
   ```bash
   xcodebuild -scheme HandyTranslateMac build
   ```
4. Launch the app from `DerivedData` or Xcode
5. Click the menu bar icon → **Settings** → enter your OpenAI API key
6. Press **⌘⇧⌥M** in any app to translate

## Tech Stack

- Swift / AppKit
- OpenAI API (gpt-4o-mini)
- Carbon Hot Key API for global shortcuts
- CGEvent for keyboard simulation (Cmd+A, Cmd+C, Cmd+V)

## Project Structure

```
macOS/              → App source (AppDelegate, TranslationCoordinator, etc.)
Shared/             → Swift Package (OpenAI client, TranslationService, settings)
project.yml         → XcodeGen configuration
```
