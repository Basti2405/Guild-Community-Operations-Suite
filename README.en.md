# Guild & Community Operations Suite

**A roster and readiness audit for guilds — and an export a server can
actually read.**

*[Deutsche Fassung](README.md)*

> The core add-on is called **GuildOps** in your AddOns folder and its slash
> command is `/gops`.

## Status: scaffold with a working core

**Not a finished add-on**, but more than a sketch: reading the guild roster,
checking gear, reading the Great Vault and the JSON export **work and are
tested** — 33 logic tests, all green. Details in [`Planung/`](Planung/)
(in German).

## Structure

```
GuildOps/                Core
GuildOps_Attendance/     Module – attendance
GuildOps_LootAudit/      Module – loot distribution
GuildOps_ChannelSync/    Module – sync between installations
```

Every module declares `## Dependencies: GuildOps` and can be disabled
individually.

## The export

The actual point: what is recorded here should reach a web dashboard or a
Discord bot.

`/gops export` opens a text box to copy from, containing **JSON**. Not the
SavedVariables — that is Lua source a server would have to execute, and you
do not execute foreign Lua source.

The export is **assembled, not dumped**: window positions and intermediate
module state stay out. Keys are sorted so two snapshots can be compared.
Both are covered by tests.

An add-on cannot send anything anywhere on its own. That is a WoW
limitation, not a missing feature.

## Commands

| Command | Effect |
|---|---|
| `/gops` | Show or hide the window |
| `/gops export` | Data as JSON, ready to copy |
| `/gops doctor` | Self-check |

## What it can*not* do

- **Inspect other characters.** `Inspect` only works in range, is
  asynchronous and often fails. So every player records **their own** state.
  Without the sync module an officer sees only their own characters — not
  half the guild.
- **See other players' Great Vault.** Not queryable at all.
- **Know who was rostered.** The game has no concept of a roster plan. Who
  was missing only emerges from comparing against an external list.
- **Check gems** — not yet. The item link does not reveal how many gem
  sockets an item has, so an empty field does not necessarily mean "gem
  missing". Better no check than one reporting gaps that are not there.

## Development

```bash
tools/junction.cmd
./tools/test.sh
```

## Licence

MIT, see [LICENSE](LICENSE).
