
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt



  ORG 100h

player_x db 1
player_y db 1

maze db '####################', 13, 10
     db '#X ##### #         #', 13, 10
     db '# #      # # ##### #', 13, 10 
     db '#   #### # # #     #', 13, 10
     db '#####    # # #     #', 13, 10
     db '# #   #### # ##### #', 13, 10
     db '#     #### ###   # #', 13, 10
     db '# #    ###   #E  # #', 13, 10
     db '# #### #   # ### # #', 13, 10
     db '#    #   ###  #    #', 13, 10
     db '###################', 13, 10, '$'

start:
    call draw_maze

game_loop:
    mov ah, 08h
    int 21h
    cmp al, 'w'
    je move_up
    cmp al, 's'
    je move_down
    cmp al, 'a'
    je move_left
    cmp al, 'd'
    je move_right
    jmp game_loop 
    

move_up: 
    push ax
    call erase_player 
    pop ax
    dec player_y 
    call check_and_update
    jmp game_loop

move_down: 
    push ax
    call erase_player 
    pop ax
    inc player_y
    call check_and_update
    jmp game_loop

move_left:
    push ax
    call erase_player 
    pop ax
    dec player_x
    call check_and_update
    jmp game_loop

move_right:  
    push ax
    call erase_player 
    pop ax
    inc player_x
    call check_and_update
    jmp game_loop

check_and_update:
    call check_move_valid
    call erase_player
    call update_player
    call draw_maze
    ret

check_move_valid: 

    ;cmp player_x,2   
    ;jl invalid_move_left       
    
    push ax
    call calculate_position 
    pop ax
    mov bl, [si]
    
    cmp bl, '#'     
    je invalid_move   
    
    
    cmp bl, 'E'
    je game_won
    ret   
    
    
    
invalid_move:
    cmp al, 'w'
    je invalid_move_up
    cmp al, 's'
    je invalid_move_down
    cmp al, 'a'
    je invalid_move_left
    cmp al, 'd' 
    je invalid_move_right
          
          

invalid_move_up:     
    inc player_y 
    call update_player
    jmp start  
    
invalid_move_down:     
    dec player_y
    call update_player 
    jmp start
    
invalid_move_left:     
    inc player_x
    call update_player
    jmp start
    
invalid_move_right:     
    dec player_x 
    call update_player
    jmp start

      
erase_player:
    mov al, ' '    
    call update_maze 
    ret 

update_player:
    mov al, 'X' 
    call update_maze
    ret

check_win:
    push ax
    call calculate_position 
    pop ax
    mov al, [si]
    cmp al, 'E'
    je game_won
    ret

game_won:
    lea dx, win_msg
    mov ah, 09h
    int 21h
    jmp exit

exit:
    mov ah, 4Ch
    int 21h

win_msg db 'You reached the end of the maze!$'

draw_maze:
    lea dx, maze
    mov ah, 09h
    int 21h
    ret


calculate_position:
    lea si, maze      
    mov bl, player_y  
    mov ax, 22       
    mul bl            
    add si, ax        
    mov bl, player_x  
    add si, bx        
    ret         
    
    
    
update_maze:
    push ax
    call calculate_position 
    pop ax
    mov [si], al            
    ret