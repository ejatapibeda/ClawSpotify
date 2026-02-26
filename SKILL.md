---
name: clawspotify
description: "Control Spotify playback: play, pause, resume, skip, previous, restart, search, queue, set volume, shuffle, repeat, and view now-playing status."
metadata:
  openclaw:
    emoji: "🎵"
    requires:
      bins: ["bash", "python3"]
---

# clawspotify

Control your Spotify playback directly from your OpenClaw agent. Works with **both Free and Premium** Spotify accounts.

## Trigger

Use when the user asks to:
- Play, pause, resume, skip, previous, or restart a song or playlist
- Search for a song, artist, or playlist (without playing)
- Add something to the queue
- Check what's playing now
- Change volume or shuffle/repeat settings
- Set up their Spotify session (first-time)

## Authentication

clawspotify uses your Spotify browser cookies (`sp_dc` and `sp_key`) — **no official API key needed**. Works for both **Free and Premium** accounts.

### One-time setup (how to get cookies)

1. Open **https://open.spotify.com** in your browser and log in
2. Press **F12** to open DevTools
3. Go to **Application** tab → **Cookies** → `https://open.spotify.com`
4. Find and copy the value of **`sp_dc`**
5. Find and copy the value of **`sp_key`**
6. Run:
```bash
clawspotify setup --sp-dc "AQC..." --sp-key "07c9..."
```

Session is saved to `~/.config/spotapi/session.json` and reused automatically.

> If the user gives you their `sp_dc` and `sp_key` values, run the setup command for them.

### Multi-account
```bash
clawspotify setup --sp-dc "..." --sp-key "..." --id "work"
clawspotify status --id "work"
```

## Commands

### Now playing status
```bash
clawspotify status
```

### Search music (without playing)
```bash
clawspotify search "Bohemian Rhapsody"        # search tracks, show top 5
clawspotify search-playlist "Workout"         # search playlists, show top 5
```

### Search and play
```bash
clawspotify play "Bohemian Rhapsody"          # play first result
clawspotify play "Bohemian Rhapsody" --index 2  # pick result #2 (0-indexed)
clawspotify play-playlist "Lofi Girl"         # play first playlist result
```

### Playback controls
```bash
clawspotify pause
clawspotify resume
clawspotify skip                     # next track
clawspotify prev                     # previous track
clawspotify restart                  # restart from beginning
```

### Queue
```bash
clawspotify queue "Stairway to Heaven"
clawspotify queue "spotify:track:3z8h0TU..."  # add by URI
```

### Volume
```bash
clawspotify volume 50
clawspotify volume 0     # mute
clawspotify volume 100   # max
```

### Shuffle / Repeat
```bash
clawspotify shuffle on
clawspotify shuffle off
clawspotify repeat on
clawspotify repeat off
```

## Notes
- **Works with Free and Premium** Spotify accounts.
- Spotify must be **open on at least one device** (PC, phone, or web) for playback commands to work.
- Cookies expire periodically — if commands fail with a 401 error, re-run setup with fresh cookies.
- Default session identifier is `"default"`. Use `--id` to manage multiple accounts.
- **Script location:** `{skill_folder}/clawspotify.sh`
- **Platform note:** If your human is on Windows, they'll need WSL, Git Bash, or Cygwin to run this skill.
