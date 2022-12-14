# Digital Synthesizer - MVP

Devlin Ih and Neel Dhulipala

## Overview


## Audio PWM Generator

The `audio_pwm_generator` module takes in our 12 bit audio signal and modulates
it out as a 1-bit PWM signal. Its input ports are are `[11:0] audio`, `clk`,
`rst`, and `ena`. Its output port is `pwm_out`.

`audio_pwm_geneator` modulates the output by making a greater than comparison
to a 12-bit counter.

We improved the quality of the PWM signal with a simple trick found in this
[blog post](https://zipcpu.com/dsp/2017/09/04/pwm-reinvention.html): reversing
the bits in the counter to generate the PWM signal. This improves the spacing
of the pulses. This is best illustrated with an example. Luckily, [@tbl:pwm]
has an example of a 3 bit sample PWM module with a sample of `3'b100`.

| `counter` | `out` | `counter_rev` | `out_rev` |
|-----------|-------|---------------|-----------|
| `000`     | `1`   | `000`         | `1`       |
| `001`     | `1`   | `100`         | `0`       |
| `010`     | `1`   | `010`         | `1`       |
| `011`     | `0`   | `110`         | `0`       |
| `100`     | `0`   | `001`         | `1`       |
| `101`     | `0`   | `101`         | `0`       |
| `110`     | `0`   | `011`         | `0`       |
| `111`     | `0`   | `111`         | `0`       |

: Table showing PWM generator with a sample of `3'b100`. Both the counter and
  reversed counter have the same number of high output cycles, but the reversed
  counter has more distribution among the pulses. {#tbl:pwm}

The PWM module takes a 12-bit sample from the `audio` port every 272 clock
cycles. With a clock frequency of 12MHz, this yields a sample rate of
$12000000/272 \approx 44.1kHz$, twice the highest pitch a human can hear.

You might be wondering how we can modulate a 12-bit sample in 272 clock cycles.
The answer is, we can't. However, due the reversed counter, the output becomes
a $\log_2(272) \approx 8.09$ bit approximation of the 12-bit sample.

## Channel

### Wave Generators


## Debouncing


## Monostable

