.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword
INCLUDE Irvine32.inc

.data
.code
main PROC
mov eax,5
add eax,6
main ENDP
END main