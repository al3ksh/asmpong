BITS 64
DEFAULT REL

extern GetStdHandle
extern SetConsoleCursorInfo
extern SetConsoleCursorPosition
extern WriteConsoleA
extern FillConsoleOutputCharacterA
extern Sleep
extern GetAsyncKeyState
extern ExitProcess
extern Beep
extern GetTickCount

STD_OUTPUT_HANDLE equ -11

section .data
    hStdOut dq 0
    written dq 0
    cursor_info dd 100, 0
    menu_choice db 0
    p1_y db 10
    p2_y db 10
    ball_x db 40
    ball_y db 12
    ball_dx db 1
    ball_dy db 1
    score1 db 0
    score2 db 0
    sleep_time db 45
    win_score db 5
    paused db 0
    back_to_menu db 0
    stat_bounces dw 0
    stat_wall_bounces dw 0
    stat_max_speed db 0
    stat_game_start dd 0
    stat_game_time dd 0

    m_title db "======== ASSEMBLY PONG ========", 13, 10
    mt_len equ $ - m_title
    m_blank db 13, 10
    mb_len equ $ - m_blank
    m_a0 db "     ######    #####    ##  ##   ##### ", 13, 10
    ma0 equ $ - m_a0
    m_a1 db "     ##   ##  ##  ##   ### ##   ##    ", 13, 10
    ma1 equ $ - m_a1
    m_a2 db "     ######   ##  ##   ## ## #  ## ### ", 13, 10
    ma2 equ $ - m_a2
    m_a3 db "     ##       ##  ##   ##  ###  ##  ## ", 13, 10
    ma3 equ $ - m_a3
    m_a4 db "     ##        #####    ##  ##   ####  ", 13, 10
    ma4 equ $ - m_a4
    m_opt1  db "       [1] GRAJ", 13, 10
    mo1 equ $ - m_opt1
    m_opt2  db "       [2] STEROWANIE", 13, 10
    mo2 equ $ - m_opt2
    m_opt3  db "       [3] WYJDZ", 13, 10
    mo3 equ $ - m_opt3
    m_opt4  db "       [4] PUNKTY: ", 0
    mo4 equ $ - m_opt4
    m_opt4a db "3", 0
    mo4a equ $ - m_opt4a
    m_opt4b db "5", 0
    mo4b equ $ - m_opt4b
    m_opt4c db "10", 0
    mo4c equ $ - m_opt4c
    m_opt4d db " (domyslnie)", 13, 10
    mo4d equ $ - m_opt4d
    m_ver   db "  nasm x86_64 win64 | 2026", 13, 10
    mv equ $ - m_ver

    h_title db "====== STEROWANIE ======", 13, 10
    ht_len equ $ - h_title
    h_l1    db "  Gracz 1 (lewy):  W / S", 13, 10
    hl1 equ $ - h_l1
    h_l2    db "  Gracz 2 (prawy): UP / DOWN", 13, 10
    hl2 equ $ - h_l2
    h_l3    db "  ESC = PAUZA w grze", 13, 10
    hl3 equ $ - h_l3
    h_l5    db "  Nacisnij ENTER...", 13, 10
    hl5 equ $ - h_l5

    s_w1 db "=== WYGRAL GRACZ 1! ===", 13, 10
    sw1 equ $ - s_w1
    s_w2 db "=== WYGRAL GRACZ 2! ===", 13, 10
    sw2 equ $ - s_w2
    ss_title db "  WYBIERZ LICZBE PUNKTOW:", 13, 10
    sst equ $ - ss_title
    ss_line db "  [1] 3 punkty   [2] 5 punktow   [3] 10 punktow", 13, 10
    ssl equ $ - ss_line
    s_back db "  Nacisnij ENTER aby wrocic...", 13, 10
    sbk equ $ - s_back
    s_p1 db "P1:"
    s_p2 db "P2:"
    digits db "0123456789"

    cnt3_0 db " ####### "
    cnt3_1 db "       # "
    cnt3_2 db "  #####  "
    cnt3_3 db "       # "
    cnt3_4 db " ####### "
    cnt2_0 db " ####### "
    cnt2_1 db "       # "
    cnt2_2 db "  #####  "
    cnt2_3 db " #       "
    cnt2_4 db " ####### "
    cnt1_0 db "    #    "
    cnt1_1 db "   ###   "
    cnt1_2 db "    #    "
    cnt1_3 db "    #    "
    cnt1_4 db " ####### "
    go_0 db " #######  #####   "
    go_1 db " #         #    #  "
    go_2 db " # ####    #    #  "
    go_3 db " #    #    #    #  "
    go_4 db " #####     #####   "
    s_pause db "       || PAUZA ||", 13, 10
    spa equ $ - s_pause
    s_cont db "     ESC = kontynuuj", 13, 10
    spau equ $ - s_cont
    s_menu db "       Q = MENU", 13, 10
    smnu equ $ - s_menu

    st_title db "====== STATYSTYKI ======", 13, 10
    stt equ $ - st_title
    st_blank db 13, 10
    stb equ $ - st_blank
    st_bnc db "  Odbicia od paletek:  ", 0
    stbnc equ $ - st_bnc
    st_wall db "  Odbicia od scian:   ", 0
    stw equ $ - st_wall
    st_spd db "  Max predkosc:        ", 0
    stsp equ $ - st_spd
    st_tml db "  Czas gry (sek):      ", 0
    sttm equ $ - st_tml
    st_bk db "  Nacisnij ENTER...", 13, 10
    stbk equ $ - st_bk

    pad_ch db '#'
    ball_ch db 'O'
    net_ch db '|'
    border_h db '-'
    border_v db '|'
    corner_ch db '+'
    trail0 db '.'
    trail1 db ':'
    flash_line db "********************************************************************************", 13, 10
    fll equ $ - flash_line

    trail_x db 0, 0, 0
    trail_y db 0, 0, 0

section .text
global main

; ===== CONSOLE HELPERS =====

fill_screen:
    push rbp
    mov rbp, rsp
    and rsp, -16
    sub rsp, 48
    mov rcx, [hStdOut]
    mov rdx, 0x20
    mov r8d, 3000
    xor r9d, r9d
    lea rax, [written]
    mov qword [rsp + 32], rax
    call FillConsoleOutputCharacterA
    leave
    ret

fill_stars:
    push rbp
    mov rbp, rsp
    and rsp, -16
    sub rsp, 48
    mov rcx, [hStdOut]
    mov rdx, 0x2A
    mov r8d, 3000
    xor r9d, r9d
    lea rax, [written]
    mov qword [rsp + 32], rax
    call FillConsoleOutputCharacterA
    leave
    ret

cur0:
    push rbp
    mov rbp, rsp
    and rsp, -16
    sub rsp, 32
    mov rcx, [hStdOut]
    xor edx, edx
    call SetConsoleCursorPosition
    leave
    ret

; rcx=hStdOut, edx=COORD
goto_xy:
    push rbp
    mov rbp, rsp
    and rsp, -16
    sub rsp, 32
    call SetConsoleCursorPosition
    leave
    ret

; rcx=hStdOut, rdx=char_ptr, r8=len
wprint:
    push rbp
    mov rbp, rsp
    and rsp, -16
    sub rsp, 48
    lea r9, [written]
    mov qword [rsp + 32], 0
    call WriteConsoleA
    leave
    ret

; rcx=x, edx=y, r8=char_ptr
draw_ch:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 48
    mov rbx, r8
    mov eax, edx
    shl eax, 16
    mov ax, cx
    mov rcx, [hStdOut]
    mov edx, eax
    call SetConsoleCursorPosition
    mov rcx, [hStdOut]
    mov rdx, rbx
    mov r8, 1
    lea r9, [written]
    mov qword [rsp + 32], 0
    call WriteConsoleA
    pop rbx
    leave
    ret

; rcx=x, edx=y, r8=art_addr, r9d=line_len
print_art:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    sub rsp, 48
    mov r12d, ecx
    mov r13d, edx
    mov rbx, r8
    mov r14d, r9d
    mov dword [rsp + 16], 0
.pa_loop:
    mov eax, r13d
    add eax, dword [rsp + 16]
    shl eax, 16
    or eax, r12d
    mov edx, eax
    mov rcx, [hStdOut]
    call SetConsoleCursorPosition
    mov rcx, [hStdOut]
    mov rdx, rbx
    mov r8d, r14d
    lea r9, [written]
    mov qword [rsp + 32], 0
    call WriteConsoleA
    mov eax, r14d
    add rbx, rax
    inc dword [rsp + 16]
    cmp dword [rsp + 16], 5
    jl .pa_loop
    pop r14
    pop r13
    pop r12
    pop rbx
    leave
    ret

; ===== GAME LOGIC =====

reset_trail:
    mov byte [trail_x], 0
    mov byte [trail_x+1], 0
    mov byte [trail_x+2], 0
    mov byte [trail_y], 0
    mov byte [trail_y+1], 0
    mov byte [trail_y+2], 0
    ret

check_pause:
    push rbp
    mov rbp, rsp
    and rsp, -16
    sub rsp, 32
    cmp byte [paused], 1
    jne .not_paused
.paused:
    call cur0
    call fill_screen
    mov rcx, [hStdOut]
    mov edx, (11 << 16) | 27
    call SetConsoleCursorPosition
    mov rcx, [hStdOut]
    lea rdx, [s_pause]
    mov r8, spa
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [s_cont]
    mov r8, spau
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [s_menu]
    mov r8, smnu
    call wprint
    mov rcx, 0x51
    call GetAsyncKeyState
    and rax, 0x8000
    jnz .go_menu_pause
    mov rcx, 0x1B
    call GetAsyncKeyState
    and rax, 0x8000
    jz .p_wait
.wait_esc_up:
    mov rcx, 0x1B
    call GetAsyncKeyState
    and rax, 0x8000
    jnz .wait_esc_up
    mov rcx, 50
    call Sleep
.wait_esc_dn:
    mov rcx, 0x1B
    call GetAsyncKeyState
    and rax, 0x8000
    jz .wait_esc_dn
.wait_esc_up2:
    mov rcx, 0x1B
    call GetAsyncKeyState
    and rax, 0x8000
    jnz .wait_esc_up2
    mov byte [paused], 0
    jmp .done
.go_menu_pause:
    mov byte [back_to_menu], 1
    mov byte [paused], 0
    jmp .done
.p_wait:
    mov rcx, 100
    call Sleep
    jmp .paused
.not_paused:
    mov rcx, 0x1B
    call GetAsyncKeyState
    and rax, 0x8000
    jz .done
.wait_up3:
    mov rcx, 0x1B
    call GetAsyncKeyState
    and rax, 0x8000
    jnz .wait_up3
    mov byte [paused], 1
    jmp .paused
.done:
    leave
    ret

countdown:
    push rbp
    mov rbp, rsp
    and rsp, -16
    sub rsp, 32

    call cur0
    call fill_screen
    mov ecx, 36
    mov edx, 10
    lea r8, [cnt3_0]
    mov r9d, 9
    call print_art
    mov rcx, 600
    call Sleep

    call cur0
    call fill_screen
    mov ecx, 36
    mov edx, 10
    lea r8, [cnt2_0]
    mov r9d, 9
    call print_art
    mov rcx, 600
    call Sleep

    call cur0
    call fill_screen
    mov ecx, 36
    mov edx, 10
    lea r8, [cnt1_0]
    mov r9d, 9
    call print_art
    mov rcx, 600
    call Sleep

    call cur0
    call fill_screen
    mov ecx, 31
    mov edx, 10
    lea r8, [go_0]
    mov r9d, 19
    call print_art
    mov rcx, 600
    call Sleep

    leave
    ret

reset_game:
    mov byte [p1_y], 10
    mov byte [p2_y], 10
    mov byte [ball_x], 40
    mov byte [ball_y], 12
    mov byte [ball_dx], 1
    mov byte [ball_dy], 1
    mov byte [score1], 0
    mov byte [score2], 0
    mov byte [sleep_time], 70
    mov byte [back_to_menu], 0
    mov byte [stat_max_speed], 45
    mov word [stat_bounces], 0
    mov word [stat_wall_bounces], 0
    call reset_trail
    call GetTickCount
    mov [stat_game_start], eax
    ret

reset_ball:
    call reset_trail
    mov byte [ball_x], 40
    mov byte [ball_y], 12
    cmp byte [ball_dx], 1
    jge .rb1
    mov byte [ball_dx], 1
    jmp .rbdy
.rb1:
    mov byte [ball_dx], -1
.rbdy:
    mov al, [score1]
    xor al, [score2]
    and al, 1
    jz .rbup
    mov byte [ball_dy], 1
    ret
.rbup:
    mov byte [ball_dy], -1
    ret

read_input:
    push rbp
    mov rbp, rsp
    and rsp, -16
    sub rsp, 32
    mov rcx, 0x57
    call GetAsyncKeyState
    and rax, 0x8000
    jz .p1d
    cmp byte [p1_y], 1
    jz .p1d
    dec byte [p1_y]
.p1d:
    mov rcx, 0x53
    call GetAsyncKeyState
    and rax, 0x8000
    jz .p2u
    mov al, [p1_y]
    add al, 5
    cmp al, 24
    jge .p2u
    inc byte [p1_y]
.p2u:
    mov rcx, 0x26
    call GetAsyncKeyState
    and rax, 0x8000
    jz .p2d
    cmp byte [p2_y], 1
    jz .p2d
    dec byte [p2_y]
.p2d:
    mov rcx, 0x28
    call GetAsyncKeyState
    and rax, 0x8000
    jz .rid
    mov al, [p2_y]
    add al, 5
    cmp al, 24
    jge .rid
    inc byte [p2_y]
.rid:
    leave
    ret

update_ball:
    push rbp
    mov rbp, rsp
    and rsp, -16
    sub rsp, 32
    mov al, [ball_y]
    add al, [ball_dy]
    cmp al, 1
    jl .bt
    cmp al, 23
    jg .bb
    mov [ball_y], al
    jmp .mx
.bt:
    neg byte [ball_dy]
    mov byte [ball_y], 2
    inc word [stat_wall_bounces]
    mov rcx, 600
    mov rdx, 30
    call Beep
    jmp .mx
.bb:
    neg byte [ball_dy]
    mov byte [ball_y], 22
    inc word [stat_wall_bounces]
    mov rcx, 600
    mov rdx, 30
    call Beep
    jmp .mx
.mx:
    mov al, [ball_x]
    add al, [ball_dx]
    cmp al, 0
    je .sp2
    cmp al, 80
    je .sp1
    cmp al, 3
    jne .ck2
    mov bl, [ball_y]
    cmp bl, 1
    jl .mv
    cmp bl, 23
    jg .mv
    mov bl, [ball_y]
    mov cl, [p1_y]
    cmp bl, cl
    jl .mv
    add cl, 5
    cmp bl, cl
    jge .mv
    mov byte [ball_dx], 1
    mov [ball_x], al
    mov al, [ball_y]
    sub al, [p1_y]
    cmp al, 2
    jl .p1up
    cmp al, 2
    je .p1mid
    mov byte [ball_dy], 1
    cmp al, 4
    jg .p1edge
    jmp .p1bd
.p1up:
    mov byte [ball_dy], -1
    cmp al, 1
    jl .p1edge
    jmp .p1bd
.p1mid:
    mov byte [ball_dy], 0
    jmp .p1bd
.p1edge:
    inc word [stat_bounces]
    mov rcx, 800
    mov rdx, 40
    call Beep
    cmp byte [sleep_time], 10
    jle .p1bd2
    sub byte [sleep_time], 4
    jmp .p1bd2
.p1bd:
    inc word [stat_bounces]
    mov rcx, 800
    mov rdx, 40
    call Beep
    cmp byte [sleep_time], 10
    jle .p1bd2
    sub byte [sleep_time], 2
.p1bd2:
    jmp .spd
.ck2:
    cmp al, 76
    jne .mv
    mov bl, [ball_y]
    cmp bl, 1
    jl .mv
    cmp bl, 23
    jg .mv
    mov bl, [ball_y]
    mov cl, [p2_y]
    cmp bl, cl
    jl .mv
    add cl, 5
    cmp bl, cl
    jge .mv
    mov byte [ball_dx], -1
    mov [ball_x], al
    mov al, [ball_y]
    sub al, [p2_y]
    cmp al, 2
    jl .p2up
    cmp al, 2
    je .p2mid
    mov byte [ball_dy], 1
    cmp al, 4
    jg .p2edge
    jmp .p2bd
.p2up:
    mov byte [ball_dy], -1
    cmp al, 1
    jl .p2edge
    jmp .p2bd
.p2mid:
    mov byte [ball_dy], 0
    jmp .p2bd
.p2edge:
    inc word [stat_bounces]
    mov rcx, 800
    mov rdx, 40
    call Beep
    cmp byte [sleep_time], 10
    jle .p2bd2
    sub byte [sleep_time], 4
    jmp .p2bd2
.p2bd:
    inc word [stat_bounces]
    mov rcx, 800
    mov rdx, 40
    call Beep
    cmp byte [sleep_time], 10
    jle .p2bd2
    sub byte [sleep_time], 2
.p2bd2:
    jmp .spd
.mv:
    mov [ball_x], al
    jmp .ubd
.sp1:
    inc byte [score1]
    mov rcx, 300
    mov rdx, 200
    call Beep
    mov rcx, 500
    mov rdx, 200
    call Beep
    call reset_ball
    jmp .ubd

.sp2:
    inc byte [score2]
    mov rcx, 300
    mov rdx, 200
    call Beep
    mov rcx, 500
    mov rdx, 200
    call Beep
    call reset_ball
    jmp .ubd
.spd:
    mov al, [stat_max_speed]
    cmp al, [sleep_time]
    jle .ubd
    mov byte [stat_max_speed], al
.ubd:
    leave
    ret

flash_goal:
    push rbp
    mov rbp, rsp
    and rsp, -16
    sub rsp, 32

    call cur0
    call fill_stars
    mov rcx, 150
    call Sleep

    call cur0
    call fill_screen
    mov rcx, 150
    call Sleep

    call cur0
    call fill_stars
    mov rcx, 150
    call Sleep

    call cur0
    call fill_screen
    mov rcx, 150
    call Sleep

    leave
    ret

; ===== STATISTICS =====

; Helper: print 16-bit number from AX as decimal using stack buffer
; Uses [rsp+32..39] as temp buffer (safe: we're in a function with sub rsp, 48+)
print_u16:
    push rbp
    mov rbp, rsp
    and rsp, -16
    sub rsp, 48
    mov r12d, eax
    lea rsi, [rsp + 40]
    mov byte [rsi], 0
    mov rcx, 5
.dloop:
    dec rcx
    jz .dend
    xor edx, edx
    mov eax, r12d
    mov r8d, 10
    div r8d
    mov r12d, eax
    add dl, '0'
    mov byte [rsp + rcx + 32], dl
    jmp .dloop
.dend:
    mov byte [rsp + 37], 0
    lea rdx, [rsp + 32]
    mov r8, 5
    mov rcx, [hStdOut]
    lea r9, [written]
    mov qword [rsp + 40], 0
    call WriteConsoleA
    leave
    ret

show_stats:
    push rbp
    mov rbp, rsp
    and rsp, -16
    sub rsp, 48

    call GetTickCount
    mov ecx, [stat_game_start]
    sub eax, ecx
    mov ecx, 1000
    xor edx, edx
    div ecx
    mov [stat_game_time], eax

    call cur0
    call fill_screen
    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [st_title]
    mov r8, stt
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint

    mov rcx, [hStdOut]
    lea rdx, [st_bnc]
    mov r8, stbnc
    lea r9, [written]
    mov qword [rsp + 32], 0
    call WriteConsoleA
    movzx eax, word [stat_bounces]
    call print_u16

    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint

    mov rcx, [hStdOut]
    lea rdx, [st_wall]
    mov r8, stw
    lea r9, [written]
    mov qword [rsp + 32], 0
    call WriteConsoleA
    movzx eax, word [stat_wall_bounces]
    call print_u16

    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint

    mov rcx, [hStdOut]
    lea rdx, [st_spd]
    mov r8, stsp
    lea r9, [written]
    mov qword [rsp + 32], 0
    call WriteConsoleA
    mov al, [stat_max_speed]
    neg al
    add al, 70
    movzx eax, al
    call print_u16

    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint

    mov rcx, [hStdOut]
    lea rdx, [st_tml]
    mov r8, sttm
    lea r9, [written]
    mov qword [rsp + 32], 0
    call WriteConsoleA
    mov eax, [stat_game_time]
    call print_u16

    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [st_bk]
    mov r8, stbk
    call wprint

.swk:
    mov rcx, 0x0D
    call GetAsyncKeyState
    and rax, 0x8000
    test rax, rax
    jz .swk
    mov rcx, 150
    call Sleep
    leave
    ret

; ===== RENDER =====

render:
    push rbp
    mov rbp, rsp
    push r12
    push rbx
    and rsp, -16
    sub rsp, 48

    call cur0
    call fill_screen

    ; top border y=0
    mov ecx, 0
    xor edx, edx
    mov r8, corner_ch
    call draw_ch
    mov rcx, [hStdOut]
    mov edx, (0 << 16) | 1
    call SetConsoleCursorPosition
    mov rcx, [hStdOut]
    lea rdx, [border_h]
    mov r8, 78
    lea r9, [written]
    mov qword [rsp + 32], 0
    call WriteConsoleA
    mov ecx, 79
    xor edx, edx
    mov r8, corner_ch
    call draw_ch

    ; bottom border y=24
    mov ecx, 0
    mov edx, 24
    mov r8, corner_ch
    call draw_ch
    mov rcx, [hStdOut]
    mov edx, (24 << 16) | 1
    call SetConsoleCursorPosition
    mov rcx, [hStdOut]
    lea rdx, [border_h]
    mov r8, 78
    lea r9, [written]
    mov qword [rsp + 32], 0
    call WriteConsoleA
    mov ecx, 79
    mov edx, 24
    mov r8, corner_ch
    call draw_ch

    ; left border x=0 y=1..23
    mov r12d, 1
.lvl:
    mov ecx, 0
    mov edx, r12d
    mov r8, border_v
    call draw_ch
    inc r12d
    cmp r12d, 24
    jl .lvl

    ; right border x=79 y=1..23
    mov r12d, 1
.lvr:
    mov ecx, 79
    mov edx, r12d
    mov r8, border_v
    call draw_ch
    inc r12d
    cmp r12d, 24
    jl .lvr

    ; update trail
    mov al, [ball_x]
    mov bl, [ball_y]
    mov cl, [trail_x+1]
    mov dl, [trail_y+1]
    mov byte [trail_x+2], cl
    mov byte [trail_y+2], dl
    mov cl, [trail_x]
    mov dl, [trail_y]
    mov byte [trail_x+1], cl
    mov byte [trail_y+1], dl
    mov [trail_x], al
    mov [trail_y], bl

    ; draw trail[2] only if valid position inside border
    movzx ecx, byte [trail_x+2]
    cmp ecx, 1
    jl .t1
    cmp ecx, 78
    jg .t1
    movzx edx, byte [trail_y+2]
    cmp edx, 1
    jl .t1
    cmp edx, 23
    jg .t1
    mov r8, trail1
    call draw_ch
.t1:
    movzx ecx, byte [trail_x+1]
    cmp ecx, 1
    jl .t0
    cmp ecx, 78
    jg .t0
    movzx edx, byte [trail_y+1]
    cmp edx, 1
    jl .t0
    cmp edx, 23
    jg .t0
    mov r8, trail0
    call draw_ch
.t0:

    ; net x=40 y=1..23
    mov r12d, 1
.nlp:
    mov ecx, 40
    mov edx, r12d
    mov r8, net_ch
    call draw_ch
    inc r12d
    cmp r12d, 24
    jl .nlp

    ; P1 paddle x=2
    mov r12d, 0
.p1l:
    mov ecx, 2
    movzx edx, byte [p1_y]
    add edx, r12d
    mov r8, pad_ch
    call draw_ch
    inc r12d
    cmp r12d, 5
    jl .p1l

    ; P2 paddle x=77
    xor r12d, r12d
.p2l:
    mov ecx, 77
    movzx edx, byte [p2_y]
    add edx, r12d
    mov r8, pad_ch
    call draw_ch
    inc r12d
    cmp r12d, 5
    jl .p2l

    ; ball
    movzx ecx, byte [ball_x]
    movzx edx, byte [ball_y]
    mov r8, ball_ch
    call draw_ch

    ; score P1 at (5, 1)
    mov rcx, [hStdOut]
    mov edx, (1 << 16) | 5
    call SetConsoleCursorPosition
    mov rcx, [hStdOut]
    lea rdx, [s_p1]
    mov r8, 3
    lea r9, [written]
    mov qword [rsp + 32], 0
    call WriteConsoleA
    movzx eax, byte [score1]
    lea rbx, [digits]
    movzx eax, byte [rbx + rax]
    mov [rsp + 32], al
    mov byte [rsp + 33], 0
    mov rcx, [hStdOut]
    mov edx, (1 << 16) | 8
    call SetConsoleCursorPosition
    mov rcx, [hStdOut]
    lea rdx, [rsp + 32]
    mov r8, 1
    lea r9, [written]
    mov qword [rsp + 40], 0
    call WriteConsoleA
    ; score P2 at (70, 1)
    mov rcx, [hStdOut]
    mov edx, (1 << 16) | 70
    call SetConsoleCursorPosition
    mov rcx, [hStdOut]
    lea rdx, [s_p2]
    mov r8, 3
    lea r9, [written]
    mov qword [rsp + 32], 0
    call WriteConsoleA
    movzx eax, byte [score2]
    lea rbx, [digits]
    movzx eax, byte [rbx + rax]
    mov [rsp + 32], al
    mov byte [rsp + 33], 0
    mov rcx, [hStdOut]
    mov edx, (1 << 16) | 73
    call SetConsoleCursorPosition
    mov rcx, [hStdOut]
    lea rdx, [rsp + 32]
    mov r8, 1
    lea r9, [written]
    mov qword [rsp + 40], 0
    call WriteConsoleA

    pop rbx
    pop r12
    leave
    ret

; ===== MENU =====

show_menu:
    push rbp
    mov rbp, rsp
    and rsp, -16
    sub rsp, 48

    mov rcx, [hStdOut]
    lea rdx, [m_title]
    mov r8, mt_len
    call wprint

    mov rcx, [hStdOut]
    lea rdx, [m_a0]
    mov r8, ma0
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_a1]
    mov r8, ma1
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_a2]
    mov r8, ma2
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_a3]
    mov r8, ma3
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_a4]
    mov r8, ma4
    call wprint

    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint

    mov rcx, [hStdOut]
    lea rdx, [m_opt1]
    mov r8, mo1
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_opt2]
    mov r8, mo2
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_opt3]
    mov r8, mo3
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_opt4]
    mov r8, mo4
    call wprint
    mov rcx, [hStdOut]
    movzx eax, byte [win_score]
    cmp al, 10
    jne .not10
    lea rdx, [m_opt4c]
    mov r8, mo4c
    jmp .pr_score
.not10:
    lea rbx, [digits]
    movzx eax, byte [rbx + rax]
    mov [rsp + 32], al
    mov byte [rsp + 33], 0
    mov rcx, [hStdOut]
    lea rdx, [rsp + 32]
    mov r8, 1
.pr_score:
    lea r9, [written]
    mov qword [rsp + 40], 0
    call WriteConsoleA
    cmp byte [win_score], 5
    jne .no_def
    mov rcx, [hStdOut]
    lea rdx, [m_opt4d]
    mov r8, mo4d
    call wprint
.no_def:

    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint

    mov rcx, [hStdOut]
    lea rdx, [m_ver]
    mov r8, mv
    call wprint

.mw:
    mov rcx, 0x31
    call GetAsyncKeyState
    and rax, 0x8000
    jnz .m1
    mov rcx, 0x32
    call GetAsyncKeyState
    and rax, 0x8000
    jnz .m2
    mov rcx, 0x33
    call GetAsyncKeyState
    and rax, 0x8000
    jnz .m3
    mov rcx, 0x34
    call GetAsyncKeyState
    and rax, 0x8000
    jnz .m4
    mov rcx, 0x0D
    call GetAsyncKeyState
    and rax, 0x8000
    jnz .m1
    mov rcx, 50
    call Sleep
    jmp .mw
.m1:
    mov byte [menu_choice], 1
    jmp .md
.m2:
    mov byte [menu_choice], 2
    jmp .md
.m3:
    mov byte [menu_choice], 3
    jmp .md
.m4:
    mov byte [menu_choice], 4
.md:
    mov rcx, 150
    call Sleep
    leave
    ret

show_help:
    push rbp
    mov rbp, rsp
    and rsp, -16
    sub rsp, 48

    mov rcx, [hStdOut]
    lea rdx, [h_title]
    mov r8, ht_len
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [h_l1]
    mov r8, hl1
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [h_l2]
    mov r8, hl2
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [h_l3]
    mov r8, hl3
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [h_l5]
    mov r8, hl5
    call wprint

.hw:
    mov rcx, 0x0D
    call GetAsyncKeyState
    and rax, 0x8000
    test rax, rax
    jz .hw
    mov rcx, 150
    call Sleep
    leave
    ret

; ===== MAIN =====

main:
    push rbp
    mov rbp, rsp
    and rsp, -16
    sub rsp, 64

    mov rcx, STD_OUTPUT_HANDLE
    call GetStdHandle
    mov [hStdOut], rax

    mov rcx, [hStdOut]
    lea rdx, [cursor_info]
    call SetConsoleCursorInfo

.menu_loop:
    call cur0
    call fill_screen
    call show_menu
    cmp byte [menu_choice], 1
    je .start_game
    cmp byte [menu_choice], 2
    je .show_help
    cmp byte [menu_choice], 3
    je .do_exit
    cmp byte [menu_choice], 4
    je .score_select
    jmp .menu_loop

.score_select:
    call cur0
    call fill_screen
    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [ss_title]
    mov r8, sst
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [ss_line]
    mov r8, ssl
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [m_blank]
    mov r8, mb_len
    call wprint
    mov rcx, [hStdOut]
    lea rdx, [s_back]
    mov r8, sbk
    call wprint
.ss_lp:
    mov rcx, 0x31
    call GetAsyncKeyState
    and rax, 0x8000
    jnz .ss3
    mov rcx, 0x32
    call GetAsyncKeyState
    and rax, 0x8000
    jnz .ss5
    mov rcx, 0x33
    call GetAsyncKeyState
    and rax, 0x8000
    jnz .ss10
    mov rcx, 0x0D
    call GetAsyncKeyState
    and rax, 0x8000
    test rax, rax
    jz .ss_lp
    jmp .ss_lp
.ss3:
    mov byte [win_score], 3
    jmp .ss_back
.ss5:
    mov byte [win_score], 5
    jmp .ss_back
.ss10:
    mov byte [win_score], 10
.ss_back:
    mov rcx, 50
    call Sleep
.wait_keys:
    mov rcx, 0x31
    call GetAsyncKeyState
    and rax, 0x8000
    jnz .wait_keys
    mov rcx, 0x32
    call GetAsyncKeyState
    and rax, 0x8000
    jnz .wait_keys
    mov rcx, 0x33
    call GetAsyncKeyState
    and rax, 0x8000
    jnz .wait_keys
    call cur0
    call fill_screen
    jmp .menu_loop

.start_game:
    call reset_game
    call cur0
    call fill_screen
    call countdown

.game_loop:
    call read_input
    call check_pause
    cmp byte [back_to_menu], 1
    je .menu_loop
    cmp byte [paused], 1
    je .game_loop
    call update_ball
    movzx ecx, byte [win_score]
    cmp byte [score1], cl
    je .p1w
    cmp byte [score2], cl
    je .p2w
    call render
    movzx ecx, byte [sleep_time]
    call Sleep
    jmp .game_loop

.p1w:
    call cur0
    call fill_screen
    mov rcx, [hStdOut]
    lea rdx, [s_w1]
    mov r8, sw1
    call wprint
    jmp .wb

.p2w:
    call cur0
    call fill_screen
    mov rcx, [hStdOut]
    lea rdx, [s_w2]
    mov r8, sw2
    call wprint

.wb:
    mov rcx, [hStdOut]
    lea rdx, [s_back]
    mov r8, sbk
    call wprint

.wk:
    mov rcx, 0x0D
    call GetAsyncKeyState
    and rax, 0x8000
    test rax, rax
    jz .wk
    mov rcx, 150
    call Sleep
    call show_stats
    jmp .menu_loop

.show_help:
    call show_help
    jmp .menu_loop

.do_exit:
    xor rcx, rcx
    call ExitProcess
