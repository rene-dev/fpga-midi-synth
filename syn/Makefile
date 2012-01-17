TOP_LEVEL = synth_top

PLATFORM = nexys3

UCF_FILE = $(TOP_LEVEL)_$(PLATFORM).ucf

#XILINX = /opt/Xilinx/13.1/ISE_DS/settings64.sh
#XILINX = /usr/local/Xilinx101/ISE/settings32.sh
XILINX = /opt/Xilinx/13.2/ISE_DS/settings32.sh

ifeq ($(PLATFORM),s3board)
	FPGA = xc3s200-ft256-4
	MAPFLAGS = -cm area
	PARFLAGS = -t 1
else ifeq ($(PLATFORM),nexys2-500)
	FPGA = xc3s500e-fg320-5
	MAPFLAGS = -cm area
	PARFLAGS = -t 1
else ifeq ($(PLATFORM),nexys2-1200)
	FPGA = xc3s1200e-fg320-5
	MAPFLAGS = -cm area
	PARFLAGS = -t 1
else ifeq ($(PLATFORM),atlys)
	FPGA = xc6slx45-csg324-3
	MAPFLAGS =
	PARFLAGS =
else ifeq ($(PLATFORM),nexys3)
	FPGA = xc6slx16-csg324-3
	MAPFLAGS =
	PARFLAGS =
else ifeq ($(PLATFORM),xupv5)
	FPGA = xc5vlx110t-ff1136-1
	MAPFLAGS =
	PARFLAGS =
endif

all: $(TOP_LEVEL).bit

syn: $(TOP_LEVEL).ngc

imp: $(TOP_LEVEL).bit
	
report: $(TOP_LEVEL).twr

# This assumes that the "XILINX" environment variable is set 
#$(TOP_LEVEL).xsvf: platforms/$(PLATFORM)/platform.batch $(TOP_LEVEL).bit
#	cat $< | sed s#\$${XILINX}#$(subst \,/,$(XILINX))#g > temp.batch
#	impact -batch temp.batch
#	rm -f temp.batch

$(TOP_LEVEL).bit: platforms/$(PLATFORM)/platform.ut $(TOP_LEVEL).ncd
	. $(XILINX); bitgen -intstyle ise -f $+

$(TOP_LEVEL).twr: $(TOP_LEVEL).ncd ../layout/$(UCF_FILE)
	. $(XILINX); trce -intstyle ise -v 3 -s 4 -n 3 -fastpaths -xml $(TOP_LEVEL).twx $< -o $@ $(TOP_LEVEL).pcf -ucf ../layout/$(UCF_FILE)

$(TOP_LEVEL).ncd: $(TOP_LEVEL)_map.ncd
	. $(XILINX); par -w -intstyle ise -ol high $(PARFLAGS) $< $@ $(TOP_LEVEL).pcf

$(TOP_LEVEL)_map.ncd: $(TOP_LEVEL).ngd
	. $(XILINX); map -intstyle ise -p $(FPGA) $(MAPFLAGS) -ir off -pr off -c 100 -o $@ $< $(TOP_LEVEL).pcf -w

$(TOP_LEVEL).ngd: $(TOP_LEVEL).ngc ../layout/$(UCF_FILE)
	. $(XILINX); ngdbuild -intstyle ise -dd _ngo -nt timestamp -uc ../layout/$(UCF_FILE) -p $(FPGA) $< $@

$(TOP_LEVEL).ngc: platforms/$(PLATFORM)/platform.xst $(TOP_LEVEL).prj
	mkdir -p xst/projnav.tmp
	sed s/TopLevel/$(TOP_LEVEL)/g $< > tmp.xst
	. $(XILINX); xst -intstyle ise -ifn tmp.xst -ofn $(TOP_LEVEL).syr

$(TOP_LEVEL).prj: ../rtl/*.vhd*
	for i in ../rtl/*.vhd*; do echo "vhdl work $$i"; done > $@
	
prog: $(TOP_LEVEL).bit
	sudo djtgcfg prog -i 0 -d Nexys3 -f $(TOP_LEVEL).bit

clean:
	rm -rf *.xsvf *.csvf _ngo *.bgn *.drc *.ncd *.ntrc_log *.prj *.twr *.csv *.html _xmsgs *.bit *.gise *.ngc *.pad *.ptwx *.twx *.ngm *.txt *.xml *.xrpt *.bld *.ise *.ngd *.par *.stx *.map *.twr auto_project_xdb *.cmd_log *.lso *.ngr *.pcf *.syr *.unroutes *.xpi *.mrp xst *.log *.cmd *.xwbt iseconfig xlnx_auto_0_xdb *.xst
