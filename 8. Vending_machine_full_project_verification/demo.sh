rm -rf compile.log test.log
rm -rf csrc/*
rm -rf simv*
rm -rf vending_machine.vpd
vcs +v2k -I-debug_all -debug_pp -sverilog vending_machine_tb.sv -l compile.log
./simv -l test.log

