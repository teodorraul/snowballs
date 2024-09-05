# Snowballs

Snowballs is a hotkeys-first, async, always-on, GPT client for macOS. 

This product requires you to create an [API key for OpenAI.](https://platform.openai.com/api-keys)

### Built for developers
Snowballs enables a quick workflow, where you can simply start a chat with `⌥ + Q`, write your query and return back to your code editor by pressing `⌥ + Q` again, without ever using your mouse.

# Installation
1. Head to Releases and download the latest version and run it
2. Tap the 🧤 Mitten icon in the Menu bar, and select Configure
3. Enter your API Key, keychain will ask for permission at this point.
4. Start using it:
    - Press `⌥ + Q` to start chatting
    - `⌥ + W` and `⌥ + S` to move between chats
    - `⌥ + D` to delete a chat
5. Consider enabling Launch at Login.

# Updates
Keep an eye on the releases page for now, there's no automated process in place, but [Sparkle](https://sparkle-project.org) will be added in the next versions.

# What's next
- [ ] Add error handling
- [ ] Improve the logging
- [ ] Setup "Check for updates"
- [ ] App Icon!
- [ ] Scroll without the mouse
- [ ] Improve the rendering in such a way that enables text selection while the response is being written
- [ ] Add "Copy to Clipboard" for codeblocks
- [ ] Window Resizing/Moving
- [ ] Maybe add an icon for each snowball, depending on the context of the chat

Consider suggesting other improvements.


# How is the API Key stored?
The API Key is stored directly into your Keychain.
It's only stored in memory and accessed when an API request towards OpenAI is made.

# Credits
- Sindre Sorhus for [Launch at Login](https://github.com/sindresorhus/LaunchAtLogin-Modern) and [Keyboard Shortcuts](https://github.com/sindresorhus/KeyboardShortcuts)
- John Sundell for the [Splash Highlighter](https://github.com/JohnSundell/Splash)
- MacPaw for the [OpenAI wrapper](https://github.com/MacPaw/OpenAI)
