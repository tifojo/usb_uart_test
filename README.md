# usb_uart_test
Test USB-UART interface on the Digilent Cmod A7

The FPGA will send 4096 bytes of dummy data in response to any byte sent by the PC. The intention is to test full round-trip flow control, where the PC sends an acknowledgement for every buffer's worth of data, rather than using the XON/XOFF method supplied (maybe?) by the FTDI chip.
