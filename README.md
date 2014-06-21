#Shellcode
This is a repository of Shellcode written by students in NYU-Polytechnic's [ISIS](http://www.isis.poly.edu/) lab. This repository came about as a need for trustworthy and reliable 32/64 bit Intel shellcode for CTF style exploitation.


This repository also contains the [`isis`](https://github.com/isislab/Shellcode/tree/master/isis) python library that has a handful of useful functions for exploitation. 





##Dependencies
In order to assemble and link(for testing) you will need to install:

- GCC
- GCC-multilib
- Nasm
- ia32-libs


To install:

`sudo apt-get install gcc gcc-multilib nasm ia32-libs`



##Usage
Each folder containing shellcode has at least two files. A .s file containg the assembly and a makefile. Typing make in a folder will assemble the shellcode as a raw binary file called `shellcode` and generate an ELF binary for testing called `testShellcode`. Shellcode that cannot be tested by running `testShellcode` alone will have other instructions. You can also test the shellcode by incorporating it into a working exploit. If you would like to hardcode the shellcode into your exploit instead of reading it from the shellcode file you can use the [shellcode as array python script.](https://github.com/isislab/Shellcode/blob/master/shellcodeAsArray/sa.py)


####Configuring
The behaviour of most shellcode instances can be configured with `%define`s. Here are some examples:

- Change the systemcall mechanism. [Mechanism Choice.](https://github.com/isislab/Shellcode/blob/master/32shellEmulator/makefile#L6)  [SYSTEM_CALL macro definition.](https://github.com/isislab/Shellcode/blob/master/include/syscall.s)
- Change the shell mechanism after socket or other operations. [Modular shellcode.](https://github.com/isislab/Shellcode/blob/master/32bitSocketReuse/shell32.s#L63) 
- Enable/disable debugging or other functionality. [Debug.](https://github.com/isislab/Shellcode/blob/master/32bitSocketReuse/shell32.s#L35) [Playfair](https://github.com/isislab/Shellcode/blob/master/32shellEmulator/shell32.s#L22)
- Configure IP/Port for connect back shelcode. [IP/htons macro.](https://github.com/isislab/Shellcode/blob/master/reverse32IPv4/r32.s#L10)

##Writing one-off/special purpose shellcode 
There are many macros in the [include](https://github.com/isislab/Shellcode/tree/master/include) folder that make writing new shellcode easier or modifying shellcode for different operating systems possible. 

##Contributing
Please feel free to contribute by submitting feature requests and bug reports to the issue tracker. Commit bits(for ISIS students only) and pull requests will be handled on a case by case basis.

