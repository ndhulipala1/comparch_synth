# Demo song generator

This directory contains a Python script to generate an `memh` file for a custom
demo song.

## Note about the synth hardware

The demo splits the 25 channels into 6 groups of 4. These 6 groups can each
play their own pitch, waveform, and dynamic (how many channels are enabled).
These groups of 4 are called voices. The remaining channel plays nothing.

## Block ROM format

Each address in the memh represents the state of the channels for 1 subdivision
of the song. The width is 96.

The 96 bits is broken into 6 16-bit messages (1 per voice). They look like
this:

| Bits     | Purpose                                |
|----------|----------------------------------------|
| `[1:0]`  | Waveform                               |
| `[3:2]`  | Volume/number of channels to play with |
| `[15:4]` | Pitch signal                           |

## Music file format

The file is not case sensitive. Capitols and lowercase letters are treated the
same.

Each line of the file represents a command. Lines starting with `#`, `;`, or
`//` are treated as comments. Here is a list of commands and descriptions:

### Change State Commands

These commands change the state of the internal model in Python land.

- `wave` `voice` `waveform`: Sets the waveform of `voice` to `waveform`.
- `freq` `voice` `value`: Sets the pitch of `voice` to `value` (a frequency).
  Only useful for micro tones.
- `note` `voice` `value`: Sets the pitch of `voice` to a dictionary
  mapping. `value` is a pitch from (RANGE). Sharps are indicated with an `s` or
  a `#` after the letter and flats a `b`. Valid values include `A4`, `Cs4`,
  `Eb4`, etc.
- `notes` `*values`: Sets the pitch of up to 6 voices from a dictionary
  mapping.
- `vol` `voice` `value`: Sets the volume of `voice` to `value`.
- `vols` `*voices`: Sets the volume of up to 6 voices.
- `measure` `subs`: Sets a measure to be `subs` subdivisions.

The initial state is assumed a measure is 16 subdivisions, and all voices are
playing A4 (`A4`) square waves (`0`) at 0 volume (`0`).

### Write State Commands

These commands write the current state into an 96-bit line.

- `s` `num`: Writes `num` subdivisions of the current state.
- `m` `num`: Writes `m` measures of the current state.
