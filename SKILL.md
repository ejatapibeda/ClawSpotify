---
name: clawspotify
# Control Spotify playback — play, pause, skip, search, queue, volume, and view now-playing status from OpenClaw.
description: "Control Spotify playback: play, pause, resume, skip, previous, restart, search, queue, set volume, shuffle, repeat, and view now-playing status."
metadata:
  openclaw:
    emoji: "🎵"
    requires:
      bins: ["bash", "python3"]
---

# clawspotify

Control your Spotify playback directly from your OpenClaw agent. Search songs, control playback, manage volume, and view what's currently playing.

## Trigger

Use when the user asks to:
- Play, pause, resume, skip, previous, or restart a song or playlist
- Search for a song, artist, or playlist (without playing)
- Add something to the queue
- Check what's playing now
- Change volume or shuffle/repeat settings
- Set up their Spotify session (first-time)

## Commands

### Now playing status
```bash
clawspotify status                   # full now-playing info + device
```

### Search music (without playing)
```bash
clawspotify search "Bohemian Rhapsody"        # search tracks and show top 5 results
clawspotify search-playlist "Workout"         # search playlists and show top 5 results
```

### Search and play
```bash
clawspotify play "Bohemian Rhapsody"          # search tracks and play first result
clawspotify play "Bohemian Rhapsody" --index 2  # pick result #2 (0-indexed)
clawspotify play-playlist "Lofi Girl"         # search playlists and play first result
```

### Playback controls
```bash
clawspotify pause
clawspotify resume
clawspotify skip                     # skip to next track
clawspotify prev                     # go to previous track
clawspotify restart                  # restart current track from beginning
```

### Queue
```bash
clawspotify queue "Stairway to Heaven"        # search and add to queue
clawspotify queue "spotify:track:3z8h0TU..."  # add by URI directly
```

### Volume
```bash
clawspotify volume 50                # set volume to 50%
clawspotify volume 0                 # mute
clawspotify volume 100               # max volume
```

### Shuffle / Repeat
```bash
clawspotify shuffle on
clawspotify shuffle off
clawspotify repeat on
clawspotify repeat off
```

### Session setup (first time only)
```bash
clawspotify setup --sp-dc "AQC..." --sp-key "07c9..." --id "my_account"
```

## Notes
- Session is stored at `~/.config/spotapi/session.json` — only needs to be set up once.
- Default session identifier is `"default"`. Use `--id` to manage multiple accounts.
- `sp_dc` and `sp_key` cookies can be found in browser DevTools → Application → Cookies → open.spotify.com.
- Commands target the currently active Spotify device (PC, phone, or web).
- **Script location:** `{skill_folder}/clawspotify`
- **Platform note:** If your human is on Windows, they'll need WSL, Git Bash, or Cygwin to run this skill since it uses a Bash wrapper.

