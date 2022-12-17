"""
Module to generate memh from custom song.

Requires Python 3.10
"""

# Note: this is quickly hobbled together

CLOCK_FREQ  = 12000000 # Clock frequency
PERIOD_BITS = 6        # Number of bits in period counter

from notes_dict import NOTES

class SongParser:
    def __init__(self):
        # [frequency, waveform, volume]
        self.voices = [{"freq": 440, "wave": 0, "volume": 0},
                       {"freq": 440, "wave": 0, "volume": 0},
                       {"freq": 440, "wave": 0, "volume": 0},
                       {"freq": 440, "wave": 0, "volume": 0},
                       {"freq": 440, "wave": 0, "volume": 0},
                       {"freq": 440, "wave": 0, "volume": 0}, ]
        self.measure = 16
        self.mem = [] # List of strings
        self.line_num = 0

    def get_bits(self):
        """
        Return a string representing the hex value for the memh file.
        """
        data = ""
        for voice in self.voices:
            pitch       = int((CLOCK_FREQ // (2*(2**PERIOD_BITS) * voice["freq"])))-1
            pitch_bits  = format(pitch, "b").zfill(12)
            if len(pitch_bits) > 12:
                pitch_bits = "111111111111"
            volume_bits = format(voice["volume"], "b").zfill(2)
            if len(volume_bits) > 2:
                volume_bits = "11"
            wave_bits   = format(voice["wave"], "b").zfill(2)
            if len(wave_bits) > 2:
                wave_bits = "11"
            voice_bits = pitch_bits + volume_bits + wave_bits
            voice_hex = format(int(voice_bits, 2), "x").zfill(4)
            data = data + voice_hex
        return data

    def parse_line(self, line):
        """
        Parse a line of data and update state.
        """
        # I guess it's doing more than parsing
        self.line_num += 1

        line = line.lower()

        match line.split():
            # Comments
            case ["#"]:
                pass
            case ["//"]:
                pass
            case [";"]:
                pass
            # State Update
            case ["wave", voice, waveform]:
                self.voices[int(voice)]["wave"] = int(waveform)
            case ["freq", voice, value]:
                self.voices[int(voice)]["freq"] = int(value)
            case ["note", voice, value]:
                note = NOTES[value]
                self.voices[int(voice)]["freq"] = note
            case ["notes", *values]:
                for i in range(len(values)):
                    note = NOTES[values[i]]
                    self.voices[int(i)]["freq"] = note
            case ["vol", voice, value]:
                self.voices[int(voice)]["volume"] = int(value)
            case ["measure", subs]:
                self.measure = int(subs)
            # Write State
            case ["s", num]:
                bits = self.get_bits()
                for i in range(int(num)):
                    self.mem.append(bits)
            case ["m", num]:
                bits = self.get_bits()
                for i in range(int(num)*self.measure):
                    self.mem.append(bits)
            # Invalid
            case "_":
                print(f"Invalid line {self.line_num}")
                print(line)


def main():
    import argparse
    parser = argparse.ArgumentParser(
        prog="DemoSongGenerator",
        description="Compile demo song into memh.",
    )
    parser.add_argument(
        "input",
        help="File path to song.",
    )
    parser.add_argument(
        "output",
        help="File path to memh output",
    )
    args   = parser.parse_args()
    input  = args.input
    output = args.output

    song_parser = SongParser()
    # Parse input
    with open(input, "r") as song:
        for line in song:
            song_parser.parse_line(line.strip())

    # Write output
    with open(output, "w") as memh:
        for line in song_parser.mem:
            memh.write(line+"\n")

if __name__ == "__main__":
    main()
