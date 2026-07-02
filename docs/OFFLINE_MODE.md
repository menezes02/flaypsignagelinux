# Offline Mode

Flayp Signage Linux supports offline playback after at least one successful online collection.

## What Is Cached

The player envdir stores:

- CMS configuration (`cms.json`);
- player settings (`settings.json`);
- schedule cache (`sched.json`);
- generated layout files;
- downloaded media and fonts;
- raw XML responses for troubleshooting.

Runtime config and private keys are intentionally ignored by git.

## Startup Offline

Use:

```sh
flaypsignagelinux --allow-offline ~/.local/share/flaypsignagelinux
```

If the CMS cannot be reached, the player loads cached settings and schedule data, starts the local media server, and displays the cached active layout.

## Limits

Offline mode cannot display content that has never been downloaded. New CMS assignments only become available offline after the player has collected and cached them while online.

## Deployment Recommendation

Before shipping a device, run it online once and confirm the log contains:

```text
collection successful
layout <id> initialized
```

Then test offline startup by disconnecting the network and launching with `--allow-offline`.
