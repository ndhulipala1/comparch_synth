# -Wall turns on all warnings
# -g2012 selects the 2012 version of iVerilog
IVERILOG=iverilog -DSIMULATION -Wall -Wno-sensitivity-entire-vector -Wno-sensitivity-entire-array -g2012 -Y.sv -I ./hdl -I ./tests 
VVP=vvp
VVP_POST=-fst
VIVADO=vivado -mode batch -source

# Source files for large module tests
CHANNEL_SRCS=hdl/channel.sv hdl/sq_wave_generator.sv hdl/tri_wave_generator.sv hdl/sine_wave_generator.sv hdl/saw_wave_generator.sv hdl/clock_divider.sv hdl/monostable.sv
CHANNEL_MIXER_SRCS=${CHANNEL_SRCS} hdl/wave_adder.sv hdl/channel_mixer.sv
CONTROLLER_SRCS=hdl/audio_controller.sv hdl/i2c_controller.sv hdl/wave_adder.sv


# Add any new source files needed for the final bitstream here
MAIN_SRCS=hdl/main.sv ${CHANNEL_SRCS} hdl/wave_adder.sv hdl/audio_pwm_generator.sv

# Look up .PHONY rules for Makefiles
.PHONY: clean submission

test_main: tests/test_main.sv ${MAIN_SRCS}
	${IVERILOG} $^ -o test_main.bin && ${VVP} test_main.bin ${VVP_POST}
waves_main: test_main
	gtkwave main.fst -a tests/test_main.gtkw


test_sq_wave_generator: tests/test_sq_wave_generator.sv hdl/sq_wave_generator.sv
	${IVERILOG} $^ -o test_sq_wave_generator.bin && ${VVP} test_sq_wave_generator.bin ${VVP_POST}
waves_sq_wave_generator: test_sq_wave_generator
	gtkwave sq_wave_generator.fst -a tests/test_sq_wave_generator.gtkw


test_tri_wave_generator: tests/test_tri_wave_generator.sv hdl/tri_wave_generator.sv
	${IVERILOG} $^ -o test_tri_wave_generator.bin && ${VVP} test_tri_wave_generator.bin ${VVP_POST}
waves_tri_wave_generator: test_tri_wave_generator
	gtkwave tri_wave_generator.fst -a tests/test_tri_wave_generator.gtkw


test_sine_wave_generator: tests/test_sine_wave_generator.sv hdl/sine_wave_generator.sv
	${IVERILOG} $^ -o test_sine_wave_generator.bin && ${VVP} test_sine_wave_generator.bin ${VVP_POST}
waves_sine_wave_generator: test_sine_wave_generator
	gtkwave sine_wave_generator.fst -a tests/test_sine_wave_generator.gtkw


test_saw_wave_generator: tests/test_saw_wave_generator.sv hdl/saw_wave_generator.sv
	${IVERILOG} $^ -o test_saw_wave_generator.bin && ${VVP} test_saw_wave_generator.bin ${VVP_POST}
waves_saw_wave_generator: test_saw_wave_generator
	gtkwave saw_wave_generator.fst -a tests/test_saw_wave_generator.gtkw


test_clock_divider: tests/test_clock_divider.sv hdl/clock_divider.sv
	${IVERILOG} $^ -o test_clock_divider.bin && ${VVP} test_clock_divider.bin ${VVP_POST}
waves_clock_divider: test_clock_divider
	gtkwave clock_divider.fst -a tests/test_clock_divider.gtkw


test_channel: tests/test_channel.sv ${CHANNEL_SRCS}
	${IVERILOG} $^ -o test_channel.bin && ${VVP} test_channel.bin ${VVP_POST}
waves_channel: test_channel
	gtkwave channel.fst -a tests/test_channel.gtkw


test_wave_adder: tests/test_wave_adder.sv hdl/wave_adder.sv
	${IVERILOG} $^ -o test_wave_adder.bin && ${VVP} test_wave_adder.bin ${VVP_POST}
waves_wave_adder: test_wave_adder
	gtkwave wave_adder.fst -a tests/test_wave_adder.gtkw

test_channel_mixer: tests/test_channel_mixer.sv ${CHANNEL_MIXER_SRCS}
	${IVERILOG} $^ -o test_channel_mixer.bin && ${VVP} test_channel_mixer.bin ${VVP_POST}
waves_channel_mixer: test_channel_mixer
	gtkwave channel_mixer.fst -a tests/test_channel_mixer.gtkw


test_audio_pwm_generator: tests/test_audio_pwm_generator.sv hdl/wave_adder.sv hdl/audio_pwm_generator.sv hdl/sine_wave_generator.sv
	${IVERILOG} $^ -o test_audio_pwm_generator.bin && ${VVP} test_audio_pwm_generator.bin ${VVP_POST}
waves_audio_pwm_generator: test_audio_pwm_generator
	gtkwave audio_pwm_generator.fst -a tests/test_audio_pwm_generator.gtkw


# Test does not have coresponding waves
test_audio_controller: tests/test_audio_controller.sv ${CONTROLLER_SRCS}
	${IVERILOG} $^ -o test_audio_controller.bin && ${VVP} test_audio_controller.bin ${VVP_POST}


# Missing test files
# test_spi_controller : tests/test_spi_controller.sv hdl/spi_controller.sv hdl/spi_types.sv
# 	${IVERILOG} $^ -o test_spi_controller.bin && ${VVP} test_spi_controller.bin ${VVP_POST}
# waves_spi_controller: test_spi_controller
# 	gtkwave spi_controller.fst -a tests/spi_controller.gtkw


# Test does not run
test_i2c_controller : tests/test_i2c_controller.sv hdl/i2c_controller.sv hdl/i2c_types.sv
	${IVERILOG} $^ -o test_i2c_controller.bin && ${VVP} test_i2c_controller.bin ${VVP_POST}
waves_i2c_controller: test_i2c_controller
	gtkwave i2c_controller.fst -a tests/i2c_controller.gtkw


main.bit: $(MAIN_SRCS) main.xdc
	@echo "########################################"
	@echo "#### Building FPGA bitstream        ####"
	@echo "########################################"
	${VIVADO} build.tcl

program_fpga_vivado: main.bit build.tcl program.tcl
	@echo "########################################"
	@echo "#### Programming FPGA (Vivado)      ####"
	@echo "########################################"
	${VIVADO} program.tcl

program_fpga_digilent: main.bit build.tcl
	@echo "########################################"
	@echo "#### Programming FPGA (Digilent)    ####"
	@echo "########################################"
	djtgcfg enum
	djtgcfg prog -d CmodA7 -i 0 -f main.bit

lint: hdl/*.sv
	verilator --lint-only -I./hdl -I./tests $^

# Call this to clean up all your generated files
clean:
	rm -f *.bin *.vcd *.fst vivado*.log *.jou vivado*.str *.log *.checkpoint *.bit *.html *.xml *.out
	rm -rf .Xil

# Call this to generate your submission zip file.
submission:
	zip submission.zip Makefile hdl/*.sv README.md docs/* *.tcl *.xdc tests/*.sv tests/*.gtkw *.pdf
