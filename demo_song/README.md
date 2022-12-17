# Demo song generator

This directory contains a Python script to generate an `memh` file for a custom
demo song.

## Note about the synth hardware

The demo splits the 25 channels into 5 groups of 5. These 5 groups can each
play their own pitch, waveform, and dynamic (how many channels are enabled).

## Block ROM format

Each address in the memh represents the state of the channels for 1 subdivision
of the song. The width is 80 bits long.

The 80 bits is broken into 5 16-bit messages. They look like this:

| Bits      | Purpose                                                                                    |
|-----------|--------------------------------------------------------------------------------------------|
| `[1:0]`   | Waveform                                                                                   |
| `[4:2]`   | Volume/number of channels to play with, if 5+ use all                                      |
| `[13:5]`  | 9 LSBs of pitch signal to send to synth. 3 `1`s are inserted as the MSBs in hardware land. |
| `[15:14]` | Reserved for extensions                                                                    |

## Music file format

Each line of the file represents a command. Here is a list of commands and
descriptions:

### Change State Commands

These commands change the state of the internal model in Python land.

- `wave` `block` `waveform`: Sets the waveform of `block` block to `waveform`.
- `pitch` `block` `value`: Sets the pitch of `block` block to `value`. Only
  useful for micro tones.
- `note` `block` `value`: Sets the pitch of `block` block to a dictionary
  mapping. `value` is a pitch from (RANGE). Sharps are indicated with an `s`
  after the letter and flats a `b`. Valid values include `A4`, `Cs4`, `Eb4`,
  etc.
- `measure` `subs`: Sets a measure to be `subs` subdivisions.

The initial state is assumed a measure is 16 subdivisions, and all blocks are
playing A4 (`A4`) square waves (`0`) at 0 volume (`0`).

### Write State Commands

These commands write the current state into an 80-bit line.

- `s` `num`: Writes `num` subdivisions of the current state.
- `m` `num`: Writes `m` measures of the current state.
