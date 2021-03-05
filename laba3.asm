name "string"   
.model tiny
org  100h       
   
.DATA     
buffer db 9 dup (?)
mas dw 30 dup (?)       
m db ?
n db ?
exit_msg db "press any key",0dh,0ah,'$'   
input db "enter matrix size (max 5x6)",0dh,0ah,'$'
minput db "m=",'$'
ninput db "n=",'$'
error db "please, enter correct number",0dh,0ah,'$'
error1 db "out of range",'$'
masinput db "[0][0]=",'$'
next_line db 0dh,0ah,'$'
stars db "*****************************************",0dh,0ah,'$'
sums db "sum:",0dh,0ah,'$'

.CODE

mov ah,09h           ;
mov dx,offset input  ;start message  
int 21h              ;

jmp m_start          ;input m
m_error:             ;error if m<5
mov ah,09h
mov dx,offset error    
int 21h
m_start:
mov dx,offset minput
call int_input
cmp dx,5
jg m_error           ;error  
cmp dx,1
jl m_error
mov bx,offset m      
mov [bx],dl          ;else, add it

                     
jmp n_start          ;input n -||-
n_error:
mov ah,09h
mov dx,offset error    
int 21h
n_start:
mov dx,offset ninput
call int_input
cmp dx,6
jg n_error  
cmp dx,1
jl n_error
mov bx,offset n
mov [bx],dl

;-------------------------input mas-------------------------------------------------

mov bx,offset m     ;
mov cx,[bx]         ;set cx for rows
mov ch,0            ;

mov bx,offset mas   ;have current input position, push and pop everywhere to save it
i_loop:
    
    push bx    
    mov bx,offset m        ;
    mov al,[bx]            ;
    add al,1               ;
    sub al,cl              ;add right number in [x][]
    add al,48              ;
    mov bx,offset masinput ;
    mov [bx+1],al
    pop bx
              ;
    push cx 
    
    push bx
    mov bx,offset n        ;
    mov cx,[bx]            ;set cx for columns
    mov ch,0               ;
    pop bx
    j_loop: 
        
        push bx
        mov bx,offset n         ;
        mov al,[bx]             ;
        add al,1                ;
        sub al,cl               ;add right number in [][x]
        add al,48               ;
        mov bx,offset masinput  ;
        mov [bx+4],al           ;
        pop bx
        
        mov dx,offset masinput  ;
        call int_input          ;input
        mov [bx],dx             ;
        add bx,2                ;
                
    loop j_loop
    
        
    pop cx
loop i_loop

;-------------------------output mas----------------------------------------------

mov ah,09h 
mov dx,offset next_line
int 21h 
mov dx,offset stars
int 21h 
mov dx,offset next_line
int 21h 

mov bx,offset m     ;
mov cx,[bx]         ;set cx for rows
mov ch,0            ;   

mov bx,offset mas   ;have current output position, push and pop everywhere to save it
i_loop_1: 
    
    push cx
    
    push bx
    mov bx,offset n        ;
    mov cx,[bx]            ;set cx for columns
    mov ch,0               ; 
    pop bx
    
    j_loop_1: 
        mov dx,[bx]           ;
        call int_output       ;
        mov dx,offset buffer  ;output number from memory
        mov ah,09h            ;
        int 21h               ;
        add bx,2
    loop j_loop_1
    
    mov ah,09h 
    mov dx,offset next_line
    int 21h  
      
    pop cx
loop i_loop_1

mov ah,09h  
mov dx,offset next_line
int 21h  
mov dx,offset stars
int 21h 
mov dx,offset next_line
int 21h  
mov dx,offset sums
int 21h
 
;-------------------------count sum------------------------------------------------

mov bx,offset m     ;
mov cx,[bx]         ;set cx for rows
mov ch,0            ;   

mov bx,offset mas   ;have current position, push and pop everywhere to save it
i_loop_2: 
    
    push cx
    
    push bx
    mov bx,offset n        ;
    mov cx,[bx]            ;set cx for columns
    mov ch,0               ; 
    pop bx
            
    mov si,0     ;out of range flag
    mov ax,0     ;sum
    j_loop_2:
        mov di,0                     ;
        cmp ax,0                     ;
        jnl count_sum_term_positive  ;save first-term's sign
        mov di,1                     ;
        count_sum_term_positive:     ;
        
        add ax,[bx]
        
        mov dx,[bx]
        cmp dx,0                   ;if it's addition
        jl count_addition_in_range   ;
        cmp di,0                     ;if first term was positive
        jne count_addition_in_range  ;
        cmp ax,0                     ;if summ become negative
        jnl count_addition_in_range  ;
        add si,1                     ;then it's overflow
        count_addition_in_range:     ;
        
        
        mov dx,[bx]
        cmp dx,0                       ;if it's substraction
        jnl count_substraction_in_range  ;
        cmp di,1                         ;if first term was negative
        jne count_substraction_in_range  ;
        cmp ax,0                         ;if summ become positive
        jl count_substraction_in_range   ;
        sub si,1                         ;then it's overflow
        count_substraction_in_range:     ;
              
           
        add bx,2
    loop j_loop_2
    
    cmp si,0
    je count_in_range1
    mov ah,09h             ;
    mov dx,offset error1   ;print out of range message
    int 21h                ;
    mov ax,0    ;set sum to 0 to make it invisible
    
    count_in_range1:
    mov dx,ax               ;
    call int_output         ;
    mov dx,offset buffer    ;print sum
    mov ah,09h              ;
    int 21h                 ;
    
    mov ah,09h 
    mov dx,offset next_line
    int 21h  
      
    pop cx
loop i_loop_2

;-----------------------------------------------------------------------------------

exit:   
mov ah,09h   
mov dx,offset exit_msg
int 21h
mov ah,07h
int 21h
ret  


;------------------------functios-------------------------------------------------



int_input proc        ;input function
push ax
push bx
push cx        
push di      ;if minus
jmp int_input_start 

int_input_error:      ;error message
mov ah,09h
mov dx,offset error    
int 21h
pop dx

int_input_start:      

mov ah,09h            ;input welcum message
int 21h
push dx               ;remember input welcum message

mov ah,0ah            ;
mov dx,offset buffer  ;
mov bx,dx             ;add input to buffer         
mov [bx],7            ;           
int 21h               ;
  
mov ah,09h                ;
mov dx,offset next_line   ;set console to the next line        
int 21h                   ;
  
add bx,1       ;       
mov cx,[bx]    ;add amount of input symbols to cx
mov ch,0       ;
cmp cx,0              ;
je int_input_error    ;error if nothing input

mov ax,0
mov di,0     ;contains sign(1-minus, 0-plus)
buffer_to_int:   
    add bx,1          ;set pointer to next symbol  
    
    
    cmp [bx],2dh
    je buffer_to_int_minus_compare

    
    
    mov dx,0ah                                 ;
    cmp di,0                                   ;
    jne buffer_to_int_multiply_start           ;
    mul dx                        ;            ;
    add ax,0                      ;
    js int_input_error            ;plus mul    ;
    jmp buffer_to_int_multiply_end;            ;multiply and check if sign change(overflow)(1-minus, 0-plus in DI)
    buffer_to_int_multiply_start:              ;
    mul dx                        ;            ;
    add ax,0                      ;
    js buffer_to_int_multiply_end ;            ;
    cmp ax,0                      ;minus mul   ;
    je buffer_to_int_multiply_end ;            ;
    jmp int_input_error           ;            ;
    buffer_to_int_multiply_end:                ;
    
    
    
    cmp [bx],30h         ;
    jl int_input_error   ;error if not number
    cmp [bx],39h         ;
    jg int_input_error   ;
    
    sub [bx],30h   ;get number from ascii
    mov dx,[bx] ;
    mov dh,0    ;add number to sum
    
    
    
    cmp di,0                                    ;
    jne buffer_to_int_substraction_start        ;
    adc ax,dx                      ;            ;
    js int_input_error             ;add         ;
    jmp buffer_to_int_addition_end ;            ;
    buffer_to_int_substraction_start:           ;substract or add depend on sign(1-minus, 0-plus in DI)
    sub ax,dx                      ;            ;
    js buffer_to_int_addition_end  ;            ;
    cmp ax,0                       ;substraction;
    je buffer_to_int_addition_end  ;            ;
    jmp int_input_error            ;            ;
    buffer_to_int_addition_end:                 ;
    
    
    jmp buffer_to_int_end
    
    
    buffer_to_int_minus_compare:   ; 
    mov di,1                       ;
    sub bx,2                       ;check if minus is first symbol
    cmp bx,offset buffer           ;
    jne int_input_error            ;
    add bx,2                       ;
    
    
    buffer_to_int_end:
loop buffer_to_int                      
                    
pop dx
mov dx,ax     
pop di
pop cx
pop bx
pop ax 
ret      
int_input endp 








int_output proc
push ax
push bx
push cx  
push di


mov ax,dx


mov di,0                        ;
cmp ax,0                        ;
jnl int_output_not_negative     ;
mov di,1                        ;save sign and make number positive if its negative
mov dx,-1                       ;
imul dx                         ;
int_output_not_negative:        ;


mov cx,5
output_loop:
    mov bx,10
    mov dx,0             ;assembler can't divide 2-byte numbers if dx contains smth
    div bx               
    
    add dl,48         ;convert to number in ascii
    mov bx,offset buffer    ;
    add bx,cx               ;
    sub bx,1                ;set pointer at next pos, write number
    mov [bx],dl             ;
loop output_loop    
mov [bx+5],' '
mov [bx+6],' '
mov [bx+7],'$'

mov cx,4
erase_leading_zero:
mov bx,offset buffer
cmp [bx],'0'
jne int_loop_output_out  
cmp cx,0
mov dl,[bx+1]
mov [bx],dl
mov dl,[bx+2]
mov [bx+1],dl
mov dl,[bx+3]
mov [bx+2],dl
mov dl,[bx+4]
mov [bx+3],dl
mov dl,[bx+5]
mov [bx+4],dl  
loop erase_leading_zero
int_loop_output_out:


cmp di,0
je int_output_no_leading_minus  
mov dl,[bx+4]
mov [bx+5],dl
mov dl,[bx+3]
mov [bx+4],dl
mov dl,[bx+2]
mov [bx+3],dl
mov dl,[bx+1]
mov [bx+2],dl
mov dl,[bx]
mov [bx+1],dl
mov [bx],'-'
int_output_no_leading_minus:


mov dx,offset buffer  
pop di
pop cx
pop bx
pop ax 
ret   
int_output endp