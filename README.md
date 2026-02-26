# ClawSpotify 🎵

> OpenClaw skill — control Spotify playback from your AI agent or terminal.

Control Spotify entirely from the command line (or via your OpenClaw agent): play songs by name, skip tracks, manage volume, shuffle, repeat, and check what's playing — all without touching the Spotify app.

---

## Requirements

| Requirement | Notes |
|-------------|-------|
| Python 3.10+ | `python3 --version` |
| [spotapi](https://github.com/Usiein/SpotAPI) | `pip install spotapi` or `pip install -e ./SpotAPI` |
| Active Spotify account | Free or Premium |
| Spotify open on any device | Desktop, mobile, or web player |

---

## Installation

### Via ClawHub
```bash
clawhub install spotify
```

### Manual
```bash
git clone https://github.com/ejatapibeda/ClawSpotify.git
cd ClawSpotify
chmod +x spotify
# Add to PATH or symlink
ln -s $(pwd)/spotify /usr/local/bin/spotify
```

---

## First-time Setup — Getting `sp_dc` and `sp_key`

`spotify` authenticates using two session cookies from your browser. You only need to do this **once per account**.

### Step-by-step

1. Open **[https://open.spotify.com](https://open.spotify.com)** in your browser and **log in**
2. Press **F12** to open DevTools
3. Go to **Application** tab → **Cookies** → `https://open.spotify.com`
4. Find and copy the value of **`sp_dc`**
5. Find and copy the value of **`sp_key`**

### Save your session

```bash
spotify setup --sp-dc "AQCqbfRJ..." --sp-key "07c956c0..."
```

This saves credentials to `~/.config/spotapi/session.json`. The session is reused automatically — no login needed on subsequent runs.

#### Multi-account support

```bash
# Save a second account with a custom identifier
spotify setup --sp-dc "..." --sp-key "..." --id "work"

# Use it with any command via --id
spotify status --id "work"
spotify play "Lo-fi beats" --id "work"
```

---

## Commands

All commands accept an optional `--id <identifier>` flag (default: `"default"`).

### `status` — Now Playing

```bash
spotify status
```

**Example output:**
```
  ▶  Playing

  Title   : Bohemian Rhapsody
  Album   : A Night at the Opera
  Position: 2:14 / 5:55

  Device  : Reza's MacBook (Computer)
  Volume  : 72%
  Shuffle : off   Repeat: off
```

---

### `play` — Search and Play

```bash
spotify play "<query>"
spotify play "<query>" --index <N>   # pick the Nth result (0-indexed)
```

```bash
spotify play "Bohemian Rhapsody"
spotify play "Taylor Swift Anti-Hero" --index 0
spotify play "Bach cello suite" --index 2
```

Searches Spotify and immediately plays the first matching track (or the one at `--index`).

---

### `pause` / `resume` — Playback Control

```bash
spotify pause
spotify resume
```

---

### `skip` / `prev` — Track Navigation

```bash
spotify skip      # next track
spotify prev      # previous track
```

---

### `restart` — Restart Current Track

```bash
spotify restart   # seek to 0:00
```

---

### `queue` — Add to Queue

```bash
# Search and add first result
spotify queue "Stairway to Heaven"

# Add directly by Spotify URI
spotify queue "spotify:track:5CQ30WqJwcep0pYcV4AMNc"
```

---

### `volume` — Set Volume

```bash
spotify volume 50    # 50%
spotify volume 0     # mute
spotify volume 100   # max
```

---

### `shuffle` — Toggle Shuffle

```bash
spotify shuffle on
spotify shuffle off
```

---

### `repeat` — Toggle Repeat

```bash
spotify repeat on
spotify repeat off
```

---

### `setup` — Save Session

```bash
spotify setup --sp-dc "<value>" --sp-key "<value>"
spotify setup --sp-dc "<value>" --sp-key "<value>" --id "my_account"
```

---

## Session File

Sessions are stored at:

```
~/.config/spotapi/session.json
```

Multiple accounts are supported — each identified by a label (e.g. `"default"`, `"work"`, `"personal"`).

To list sessions manually, inspect the JSON:

```bash
cat ~/.config/spotapi/session.json
```

---

## Using as an OpenClaw Skill

After manual install or cloning into `~/.openclaw/workspace/skills/spotify`, the skill is ready.

OpenClaw reads [`SKILL.md`](./SKILL.md) to understand when and how to invoke `spotify`. The agent will automatically call the right command based on user intent — no extra configuration needed.

**Example agent interactions:**

> "Play something by Radiohead"
> → `spotify play "Radiohead"`

> "Turn the volume down to 30"
> → `spotify volume 30`

> "What's playing right now?"
> → `spotify status`

> "Add Stairway to Heaven to the queue"
> → `spotify queue "Stairway to Heaven"`

---

## Troubleshooting

### `✗ Error: No session file found`

Run setup first:
```bash
spotify setup --sp-dc "..." --sp-key "..."
```

### `✗ Error: No active Spotify device found`

Spotify must be open and active on at least one device (desktop app, mobile app, or web player at [open.spotify.com](https://open.spotify.com)). Start playing something manually once, then retry.

### `✗ Error: spotapi is not installed`

```bash
pip install spotapi
# or from source:
pip install -e ./SpotAPI
# or via pipx (installer will auto-detect it):
pipx install git+https://github.com/ejatapibeda/SpotAPI.git
```

> **pipx users:** The installer automatically finds `spotapi` inside your pipx venv and injects it into the wrapper's `PYTHONPATH`. Just re-run `bash install.sh` after installing via `pipx`.

### `$'\r': command not found` / CRLF errors

This happens when `spotify` or `spotify.py` has Windows line endings (CRLF). Fix with:

```bash
sed -i 's/\r$//' ClawSpotify/spotify
```

> To prevent this permanently, the repo includes a [`.gitattributes`](./.gitattributes) file that enforces LF line endings for `.sh` and `.py` files on checkout.

### `spotify: command not found`

Add `~/.local/bin` to your PATH:
```bash
echo 'export PATH="${HOME}/.local/bin:${PATH}"' >> ~/.bashrc
source ~/.bashrc
```

### Cookies expired / authentication errors

Spotify session cookies expire periodically. Re-run setup with fresh cookies:
```bash
spotify setup --sp-dc "new_value" --sp-key "new_value"
```

---

## Project Structure

```
ClawSpotify/
├── SKILL.md              # OpenClaw skill definition
├── README.md             # This file
├── spotify               # CLI wrapper script
└── scripts/
    └── spotify.py        # CLI implementation
```

---

## License

This skill is part of the AI-Project-EJA workspace. SpotAPI is a separate project — see [`SpotAPI/LICENSE`](../SpotAPI/LICENSE) for its terms.
