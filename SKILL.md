---
name: spotify
# Control Spotify playback — play, pause, skip, search, queue, volume, and view now-playing status from OpenClaw.
description: "Control Spotify playback: play, pause, resume, skip, previous, restart, search, queue, set volume, shuffle, repeat, and view now-playing status."
metadata: { "openclaw": { "requires": { "bins": ["spotify-ctl"] } } }
---

# spotify

Control your Spotify playback directly from your OpenClaw agent. Search songs, control playback, manage volume, and view what's currently playing.

## Trigger

Use when the user asks to:
- Play, pause, resume, skip, previous, or restart a song
- Search for a song or artist (without playing)
- Add something to the queue
- Check what's playing now
- Change volume or shuffle/repeat settings
- Set up their Spotify session (first-time)

## Commands

### Now playing status
```bash
spotify-ctl status                   # full now-playing info + device
```

### Search music (without playing)
```bash
spotify-ctl search "Bohemian Rhapsody"        # search and show top 5 results
```

### Search and play
```bash
spotify-ctl play "Bohemian Rhapsody"          # search and play first result
spotify-ctl play "Bohemian Rhapsody" --index 2  # pick result #2 (0-indexed)
```

### Playback controls
```bash
spotify-ctl pause
spotify-ctl resume
spotify-ctl skip                     # skip to next track
spotify-ctl prev                     # go to previous track
spotify-ctl restart                  # restart current track from beginning
```

### Queue
```bash
spotify-ctl queue "Stairway to Heaven"        # search and add to queue
spotify-ctl queue "spotify:track:3z8h0TU..."  # add by URI directly
```

### Volume
```bash
spotify-ctl volume 50                # set volume to 50%
spotify-ctl volume 0                 # mute
spotify-ctl volume 100               # max volume
```

### Shuffle / Repeat
```bash
spotify-ctl shuffle on
spotify-ctl shuffle off
spotify-ctl repeat on
spotify-ctl repeat off
```

### Session setup (first time only)
```bash
spotify-ctl setup --sp-dc "AQC..." --sp-key "07c9..." --id "my_account"
```

## Notes
- Session is stored at `~/.config/spotapi/session.json` — only needs to be set up once.
- Default session identifier is `"default"`. Use `--id` to manage multiple accounts.
- `sp_dc` and `sp_key` cookies can be found in browser DevTools → Application → Cookies → open.spotify.com.
- Commands target the currently active Spotify device (PC, phone, or web).
