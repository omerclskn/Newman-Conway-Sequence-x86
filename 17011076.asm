stacksg        SEGMENT PARA STACK 'yigin'
            DW 200 DUP(?)
stacksg        ENDS

datasg        SEGMENT PARA 'veri'
datasg        ENDS

codesg        SEGMENT PARA 'kod'
              ASSUME CS:codesg, DS:datasg, SS:stacksg

ana proc far 
    
    push    ds
    xor     ax, ax
    push    ax
    mov     ax, datasg
    mov     ds, ax

    mov     ax, 10          ; input 10 ayarlandi
    push    ax              ; input stack e atildi
    call    far ptr CONWAY  ; stack kullanilarak input degeri icin cevap hesaplanir
    pop     ax              ; AX = a(10)
    call    PRINTINT        ; sonuc cevabi yazdirilir

    retf
ANA endp

; CONWAY alt yordam
CONWAY proc far
; registerdaki degerler kaybolmasin diye push lanir
    push    ax
    push    bx
    push    cx
    push    bp

    mov     bp, sp          ; stack pointer alinir
    add     bp, 12          ; push lardan 8 byte far return den 4 byte atlanir
    mov     ax, [bp]        ; stackten n degeri ax e atanir
    
; n=0 durumu
    cmp     ax, 0           
    ja      conway_kont
    mov     ax, 0           ; 0 degeri atanir
    jmp     conway_sonuc

; n=1 ve n=2 durumu
conway_kont:
    cmp     ax, 2           
    ja      conway_hesap
    mov     ax, 1           ; 1 degeri atanir
    jmp     conway_sonuc

; n degerinin 3 ve daha buyuk oldugu durumlar    
conway_hesap:
    dec     ax              ; AX = n - 1
    push    ax              
    call    far ptr CONWAY  
    pop     bx              ; BX = a(n - 1)

    push    bx              ; a(n - 1) stack e atilir    
    call    far ptr CONWAY  
    pop     cx              ; CX = a(a(n - 1))

    inc     ax              
    sub     ax, bx          ; AX = n - a(n - 1)
    push    ax              ; n - a(n - 1) stack e atilir
    call    far ptr CONWAY  
    pop     ax              ; AX = a(n - a(n - 1))

    add     ax, cx          ; AX = a(a(n - 1)) + a(n - a(n - 1))
    
conway_sonuc:
    mov     [bp], ax        ; sonuc stack e koyulur

; basta pushlanan degerler poplanir
    pop     bp
    pop     cx
    pop     bx
    pop     ax
    retf                    
CONWAY endp

; Printint alt yordam
PRINTINT proc
    cmp     ax, 0           
    jne     yazdir      ; ax 0 ise hesap yapmaya gerek yok
    push    ax              
    mov     al, '0'         
    mov     ah, 0eh         
    int     10h             ; yazdirma interrupt
    pop     ax              
    ret                     

yazdir:
    push    ax
    push    bx
    push    dx

    mov     dx, 0           ; DX:AX
    cmp     ax, 0           
    je      bitti           ; ax 0 ise yazdirma islemi bitmistir
    mov     bx, 10          
    div     bx              ; bolum=AX kalan=DX
    call    yazdir          ; rekursif olarak dondurulur
    mov     ax, dx          ; kalan kisim ax e atilir
    add     al, '0'         
    mov     ah, 0eh         
    int     10h             ; yazdirma interrupt

bitti:
    pop     dx
    pop     bx
    pop     ax
    ret                     
PRINTINT endp

codesg ENDS
     END ANA