# -Wall turns on all warnings
# -g2012 selects the 2012 version of iVerilog
IVERILOG=iverilog -DSIMULATION -Wall -Wno-sensitivity-entire-vector -Wno-sensitivity-entire-array -g2012 -Y.sv -I ./hdl -I ./tests 
VVP=vvp
VVP_POST=-fst
VIVADO=vivado -mode batch -source

# Source files for large module tests
CHANNEL_SRCS=hdl/channel.sv hdl/sq_wave_generator.sv hdl/tri_wave_generator.sv hdl/sine_wave_generator.sv hdl/saw_wave_generator.sv hdl/clock_divider.sv
CONTROLLER_SRCS=hdl/audio_controller.sv hdl/i2c_controller.sv hdl/wave_adder.sv


# Add any new source files needed for the final bitstream here
MAIN_SRCS=hdl/main.sv hdl/pulse_generator.sv hdl/pwm.sv hdl/triangle_generator.sv hdl/block_ram.sv ${ILI9341_SRCS} ${FT6206_SRCS}
MAIN_MEMORIES=memories/ili9341_init.memh

# Look up .PHONY rules for Makefiles
.PHONY: clean submission remove_solutions

test_sq_wave_generator: tests/test_sq_wave_generator.sv hdl/sq_wave_generator.sv
	${IVERILOG} $^ -o test_sq_wave_generator.bin && ${VVP} test_sq_wave_generator.bin ${VVP_POST}

test_tri_wave_generator: tests/test_tri_wave_generator.sv hdl/tri_wave_generator.sv
	${IVERILOG} $^ -o test_tri_wave_generator.bin && ${VVP} test_tri_wave_generator.bin ${VVP_POST}

test_sine_wave_generator: tests/test_sine_wave_generator.sv hdl/sine_wave_generator.sv
	${IVERILOG} $^ -o test_sine_wave_generator.bin && ${VVP} test_sine_wave_generator.bin ${VVP_POST}

test_saw_wave_generator: tests/test_saw_wave_generator.sv hdl/saw_wave_generator.sv
	${IVERILOG} $^ -o test_saw_wave_generator.bin && ${VVP} test_saw_wave_generator.bin ${VVP_POST}

test_clock_divider: tests/test_clock_divider.sv hdl/clock_divider.sv
	${IVERILOG} $^ -o test_clock_divider.bin && ${VVP} test_clock_divider.bin ${VVP_POST}

test_channel: tests/test_channel.sv ${CHANNEL_SRCS}
	${IVERILOG} $^ -o test_channel.bin && ${VVP} test_channel.bin ${VVP_POST}

test_wave_adder: tests/test_wave_adder.sv hdl/wave_adder.sv
	${IVERILOG} $^ -o test_wave_adder.bin && ${VVP} test_wave_adder.bin ${VVP_POST}

test_audio_controller: tests/test_audio_controller.sv ${CONTROLLER_SRCS}
	${IVERILOG} $^ -o test_audio_controller.bin && ${VVP} test_audio_controller.bin ${VVP_POST}

test_audio_pwm_generator: tests/test_audio_pwm_generator.sv hdl/wave_adder.sv hdl/audio_pwm_generator.sv hdl/sine_wave_generator.sv
	${IVERILOG} $^ -o test_audio_pwm_generator.bin && ${VVP} test_audio_pwm_generator.bin ${VVP_POST}

waves_audio_pwm_generator: test_audio_pwm_generator
	gtkwave audio_pwm_generator.fst -a tests/test_audio_pwm_generator.gtkw


waves_channel: test_channel
	gtkwave channel.fst -a tests/test_channel.gtkw

waves_clock_divider: test_clock_divider
	gtkwave clock_divider.fst -a tests/test_clock_divider.gtkw

waves_sq_wave_generator: test_sq_wave_generator
	gtkwave sq_wave_generator.fst -a tests/test_sq_wave_generator.gtkw

waves_tri_wave_generator: test_tri_wave_generator
	gtkwave tri_wave_generator.fst -a tests/test_tri_wave_generator.gtkw

waves_sine_wave_generator: test_sine_wave_generator
	gtkwave sine_wave_generator.fst -a tests/test_sine_wave_generator.gtkw

waves_saw_wave_generator: test_saw_wave_generator
	gtkwave saw_wave_generator.fst -a tests/test_saw_wave_generator.gtkw

waves_wave_adder: test_wave_adder
	gtkwave wave_adder.fst -a tests/test_wave_adder.gtkw

test_spi_controller : tests/test_spi_controller.sv hdl/spi_controller.sv hdl/spi_types.sv
	${IVERILOG} $^ -o test_spi_controller.bin && ${VVP} test_spi_controller.bin ${VVP_POST}
waves_spi_controller: test_spi_controller
	gtkwave spi_controller.fst -a tests/spi_controller.gtkw

test_i2c_controller : tests/test_i2c_controller.sv hdl/i2c_controller.sv hdl/i2c_types.sv
	${IVERILOG} $^ -o test_i2c_controller.bin && ${VVP} test_i2c_controller.bin ${VVP_POST}
waves_i2c_controller: test_i2c_controller
	gtkwave i2c_controller.fst -a tests/i2c_controller.gtkw

memories/ili9341_init.memh: generate_memories.py
	./generate_memories.py --memory ili9341 --out memories/ili9341_init.memh

memories/fibonacci.memh: generate_memories.py
	./generate_memories.py --memory fibonacci --out memories/fibonacci.memh

test_block_rom : memories/fibonacci.memh hdl/block_rom.sv tests/test_block_rom.sv
	${IVERILOG} hdl/block_rom.sv tests/test_block_rom.sv -o test_block_rom.bin && ${VVP} test_block_rom.bin ${VVP_POST}

test_ili9341_display_controller : tests/test_ili9341_display_controller.sv $(ILI9341_SRCS) memories/ili9341_init.memh
	${IVERILOG} ${ILI9341_SRCS} tests/test_ili9341_display_controller.sv  -o test_ili9341_display_controller.bin && ${VVP} test_ili9341_display_controller.bin ${VVP_POST}
waves_ili9341_display_controller: test_ili9341_display_controller
	gtkwave ili9341_display_controller.fst -a tests/ili9341_display_controller.gtkw

test_ft6206_controller : tests/test_ft6206_controller.sv tests/ft6206_model.sv $(FT6206_SRCS)
	${IVERILOG} ${FT6206_SRCS} tests/test_ft6206_controller.sv tests/ft6206_model.sv -o test_ft6206.bin && ${VVP} test_ft6206.bin ${VVP_POST}
waves_ft6206_controller: test_ft6206_controller
	gtkwave ft6206_controller.fst -a tests/ft6206_controller.gtkw

test_main: tests/test_main.sv ${MAIN_SRCS} memories/ili9341_init.memh tests/ft6206_model.sv tests/touch_generator.sv
	@echo "This might take a while, we're testing a lot of clock cycles!"
	${IVERILOG} tests/test_main.sv tests/ft6206_model.sv tests/touch_generator.sv ${MAIN_SRCS} -o test_main.bin && ${VVP} test_main.bin ${VVP_POST}

main.bit: $(MAIN_SRCS) $(MAIN_MEMORIES) memories/ili9341_init.memh build.tcl main.xdc
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
