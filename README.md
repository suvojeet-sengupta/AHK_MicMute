<h1 align="center">
    <img src="./src/resources/icons/1000.ico" width="32" height="32"></img>
    MicMute
</h1>
<p align="center">
    Simple microphone mute/unmute control for Windows.
</p>

<p align="center">
    <a href="https://github.com/suvojeet-sengupta/AHK_MicMute/releases/latest"><img src="https://img.shields.io/github/v/release/suvojeet-sengupta/AHK_MicMute?color=4facfe&label=latest&logo=github&style=for-the-badge"></a>
    <a href="https://github.com/suvojeet-sengupta/AHK_MicMute/releases/latest"><img src="https://img.shields.io/github/downloads/suvojeet-sengupta/AHK_MicMute/total?color=00f2fe&logo=github&style=for-the-badge"></img></a>
</p>

## ✨ Features

- 🎤 **One-click toggle** - Click the tray icon to mute/unmute
- ⚙️ **Simple settings** - Select your microphone, set theme
- 🚀 **Auto-start** - Option to start with Windows
- 🔇 **Mute on startup** - Start with microphone muted
- 🎨 **Dark/Light theme** - Follows system or manual selection

## 📥 Installation

### Download
Download the latest [MicMute.exe](https://github.com/suvojeet-sengupta/AHK_MicMute/releases/latest/download/MicMute.exe) from releases.

### Scoop (Windows Package Manager)
```powershell
scoop bucket add extras
scoop install micmute
```

## 🚀 Usage

1. **Download & Run** - Double-click `MicMute.exe`
2. **System Tray** - MicMute appears in your system tray
3. **Toggle Mic** - Single-click the tray icon to mute/unmute
4. **Settings** - Right-click → Settings to configure

### Tray Menu
| Option | Description |
|--------|-------------|
| Toggle microphone | Mute/unmute your mic |
| Settings | Open configuration window |
| Start on boot | Run MicMute at Windows startup |
| About | View app info and updates |
| Exit | Close MicMute |

## ⚙️ Settings

| Setting | Description |
|---------|-------------|
| Microphone | Select which microphone to control |
| Mute on startup | Start with microphone muted |
| Start with Windows | Launch MicMute at login |
| Theme | System / Dark / Light |

## 🛠️ Build from Source

### Prerequisites
- [AutoHotkey](https://www.autohotkey.com/)
- [Git](https://git-scm.com/)
- [ahkpm](https://ahkpm.dev/)

### Build Steps
```powershell
# Clone repository
git clone https://github.com/suvojeet-sengupta/AHK_MicMute.git
cd AHK_MicMute

# Install dependencies
ahkpm install

# Download BASS audio library
Invoke-WebRequest "https://www.un4seen.com/files/bass24.zip" -OutFile "bass24.zip"
Expand-Archive "bass24.zip" -DestinationPath "bass24"
Copy-Item "bass24\x64\bass.dll" -Destination "src\Lib\bass.dll"

# Compile
ahk2exe.exe /in "src\MicMute.ahk" /out "MicMute.exe"
```

## 📚 Libraries Used

| Library | License |
|---------|---------|
| [Material Design Icons](https://github.com/Templarian/MaterialDesign) | Apache 2.0 |
| [BASS Audio](https://www.un4seen.com) | Free for non-commercial |
| [VA.ahk](https://github.com/SaifAqqad/VA.ahk) | MIT |
| [Neutron.ahk](https://github.com/G33kDude/Neutron.ahk) | MIT |
| [cJson.ahk](https://github.com/G33kDude/cJson.ahk) | MIT |
| [Bulma CSS](https://bulma.io) | MIT |

## 👤 Developer

**Suvojeet Sengupta**

- GitHub: [@suvojeet-sengupta](https://github.com/suvojeet-sengupta)

## 📄 License

This project is licensed under [The Unlicense](LICENSE) - free and unencumbered software released into the public domain.

---

<p align="center">
Made with ❤️ by Suvojeet Sengupta
</p>
