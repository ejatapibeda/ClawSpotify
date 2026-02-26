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

```bash
# 1. Clone or navigate to this skill directory
cd ClawSpotify

# 2. Run the installer
bash install.sh
```

The installer will:
- Verify Python 3 and `spotapi` are available
- Create a `spotify-ctl` wrapper in `~/.local/bin/`
- Optionally link the skill to your OpenClaw workspace

> **PATH note:** If `~/.local/bin` is not in your `PATH`, add this to `~/.bashrc` or `~/.zshrc`:
> ```bash
> export PATH="${HOME}/.local/bin:${PATH}"
> ```

---

## First-time Setup — Getting `sp_dc` and `sp_key`

`spotify-ctl` authenticates using two session cookies from your browser. You only need to do this **once per account**.

### Step-by-step

1. Open **[https://open.spotify.com](https://open.spotify.com)** in your browser and **log in**
2. Press **F12** to open DevTools
3. Go to **Application** tab → **Cookies** → `https://open.spotify.com`
4. Find and copy the value of **`sp_dc`**
5. Find and copy the value of **`sp_key`**

### Save your session

```bash
spotify-ctl setup --sp-dc "AQCqbfRJ..." --sp-key "07c956c0..."
```

This saves credentials to `~/.config/spotapi/session.json`. The session is reused automatically — no login needed on subsequent runs.

#### Multi-account support

```bash
# Save a second account with a custom identifier
spotify-ctl setup --sp-dc "..." --sp-key "..." --id "work"

# Use it with any command via --id
spotify-ctl status --id "work"
spotify-ctl play "Lo-fi beats" --id "work"
```

---

## Commands

All commands accept an optional `--id <identifier>` flag (default: `"default"`).

### `status` — Now Playing

```bash
spotify-ctl status
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
spotify-ctl play "<query>"
spotify-ctl play "<query>" --index <N>   # pick the Nth result (0-indexed)
```

```bash
spotify-ctl play "Bohemian Rhapsody"
spotify-ctl play "Taylor Swift Anti-Hero" --index 0
spotify-ctl play "Bach cello suite" --index 2
```

Searches Spotify and immediately plays the first matching track (or the one at `--index`).

---

### `pause` / `resume` — Playback Control

```bash
spotify-ctl pause
spotify-ctl resume
```

---

### `skip` / `prev` — Track Navigation

```bash
spotify-ctl skip      # next track
spotify-ctl prev      # previous track
```

---

### `restart` — Restart Current Track

```bash
spotify-ctl restart   # seek to 0:00
```

---

### `queue` — Add to Queue

```bash
# Search and add first result
spotify-ctl queue "Stairway to Heaven"

# Add directly by Spotify URI
spotify-ctl queue "spotify:track:5CQ30WqJwcep0pYcV4AMNc"
```

---

### `volume` — Set Volume

```bash
spotify-ctl volume 50    # 50%
spotify-ctl volume 0     # mute
spotify-ctl volume 100   # max
```

---

### `shuffle` — Toggle Shuffle

```bash
spotify-ctl shuffle on
spotify-ctl shuffle off
```

---

### `repeat` — Toggle Repeat

```bash
spotify-ctl repeat on
spotify-ctl repeat off
```

---

### `setup` — Save Session

```bash
spotify-ctl setup --sp-dc "<value>" --sp-key "<value>"
spotify-ctl setup --sp-dc "<value>" --sp-key "<value>" --id "my_account"
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

After running `install.sh`, the skill is linked to `~/.openclaw/workspace/skills/spotify`.

OpenClaw reads [`SKILL.md`](./SKILL.md) to understand when and how to invoke `spotify-ctl`. The agent will automatically call the right command based on user intent — no extra configuration needed.

**Example agent interactions:**

> "Play something by Radiohead"
> → `spotify-ctl play "Radiohead"`

> "Turn the volume down to 30"
> → `spotify-ctl volume 30`

> "What's playing right now?"
> → `spotify-ctl status`

> "Add Stairway to Heaven to the queue"
> → `spotify-ctl queue "Stairway to Heaven"`

---

## Troubleshooting

### `✗ Error: No session file found`

Run setup first:
```bash
spotify-ctl setup --sp-dc "..." --sp-key "..."
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

This happens when `install.sh` or `spotify.py` has Windows line endings (CRLF). Fix with:

```bash
sed -i 's/\r$//' ClawSpotify/install.sh
bash ClawSpotify/install.sh
```

> To prevent this permanently, the repo includes a [`.gitattributes`](./.gitattributes) file that enforces LF line endings for `.sh` and `.py` files on checkout.

### `spotify-ctl: command not found`

Add `~/.local/bin` to your PATH:
```bash
echo 'export PATH="${HOME}/.local/bin:${PATH}"' >> ~/.bashrc
source ~/.bashrc
```

### Cookies expired / authentication errors

Spotify session cookies expire periodically. Re-run setup with fresh cookies:
```bash
spotify-ctl setup --sp-dc "new_value" --sp-key "new_value"
```

---

## Project Structure

```
ClawSpotify/
├── SKILL.md              # OpenClaw skill definition
├── README.md             # This file
├── install.sh            # Installer script
└── scripts/
    └── spotify.py        # CLI implementation
```

---

## License

This skill is part of the AI-Project-EJA workspace. SpotAPI is a separate project — see [`SpotAPI/LICENSE`](../SpotAPI/LICENSE) for its terms.
