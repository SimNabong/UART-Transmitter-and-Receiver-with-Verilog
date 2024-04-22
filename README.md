# UART-Transmitter-and-Receiver-with-Verilog
Verilog UART Receiver and Transmitter Module with parity checking and baud rate control
This is a UART verilog code for a Transmitter and a Receiver module with parity checking(both even and odd) and 5 selections of baud rates. 
The UART transmitter module takes 8 parallel data bits from the user, then transmit them serially(in this order Idle,start, 8 input data, parity, and stop bits). The UART receiver module then receives these transmitted bits serially(1 bit at a time), then outputs the 8 data bits in a parallel. You might be thinking, why use UART if youre going from parallel inputs to parallel outputs, when you can just take your parallel input bits and transmit the bits directly as parallel output bits, and my answer is because I can. This is also part of a motor controller project that im working on that I may or may not post once I get a job. As for the physical set-up im using, I'm currently making a video to further detail my deseign. You can use FPGA for this but im using 2 CPLDs(1 as a transmitter and 1 as a receiver) because im poor and broke(see the picture).  This UART transmitter and Receiver module has 5 baud rates selections(Baud_9600 ,Baud_19200,Baud_38400,Baud_57600,Baud_115200). The selections can be further increased with minor modification to the baud control module and the top entity modules. The UART Transmitter and Receiver also includes parity checking for both even and odd, so users can use the maximum number of combination(256 unique combinations) of the 8-bit data that gets sent, while providing error checking. 


The Transmitter module:
Top Level Entity module:Transmitter_BaudRate.v
-included modules: BaudControl.v and the UART_Transmitter.v

The Receiver module:
Top Level Entity module: UARTReceiver.v
-included modules: BaudControl.v , Eight_Bit_Parity_Checker.v, and UARTReceiverStateMachine.v
