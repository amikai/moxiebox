	.globl	main
	.type	main,@function
	.text
main:
    dec $sp, 8

    /* find data */
    jsra find_data
    sto.l -4($fp), $r0 # -4($fp) = find_data return val

    /* $r0 = prot = MOXIE_PROT_READ | MOXIE_PROT_WRITE | MOXIE_PROT_EXEC */
    ldi.l $r0, 7 
    /* $r1 = flags = MOXIE_MAP_PRIVATE | MOXIE_MAP_ANONYMOUS */
    ldi.l $r1, 6
    /* mmap */
    mov $r2, $r0 # $r2 = prot
    mov $r3, $r1 # $r3 = flags
    xor $r0, $r0 # $r0 = 0
    ldi.l $r1, 0x10000 # $r1 = MAP_SIZE = 0x10000
    xor $r4, $r4 # $r4 = 0
    xor $r5, $r5 # $r5 = 0
    jsra mmap # mmap(NULL, MAX_SIZE, prot, flags, 0, 0)
    sto.l -8($fp), $r0 #  -8($fp) = mmap return val

    
    ldo.l $r0, -4($fp) # load find_data  return val
    jsra fib_iter
    mov $r1, $r0 # use $r1 get the result

    
    ldo.l $r0, -8($fp) # p = $r0 = mmap return value 
    st.l ($r0), $r1 #  *p = $r2

    ldo.l $r0, -8($fp) # p = $r0 = mmap return value, pass to setreturn
    ldi.l $r1, 4 # length is 4 bytes
    jsra setreturn

    /* exit(0) */
    xor $r0, $r0
    jsra exit


    .type fib_iter,@function
    .text
fib_iter:
    dec $sp, 4
    sto.l -4($fp), $r0
    
    /* fib $r2 is result */
    xor $r0, $r0 # a = 0
    xor $r1, $r1 # b = 0
    xor $r2, $r2 # t = 0
    xor $r3, $r3 # i = 0
    xor $r4, $r4 # n = 0
    xor $r6, $r6 # z = 0
    ldi.l $r1, 1 # b = 1
    ldo.l $r4, -4($fp) # n = input

    .L:
    mov $r2, $r0 # t = a
    add $r2, $r1 # t = t + b
    mov $r0, $r1 # a = b
    mov $r1, $r2 # b = t
    dec $r4,   1 # n --
    cmp $r4, $r6 # if(n>0)
    bgt .L       # goto L

    mov $r0, $r2 # return $r0
    ret




data_tag:
    .string "data0,"
    .size data_tag, 4
    
    
    
    .type find_data,@function
    .text
find_data:
        dec $sp, 4
        xor $r0, $r0
        lda.l $r0, moxie_memmap # $r0 = moxie_memmap
        sto.l -4($fp), $r0 # -4($fp) = moxie_memmap

    .L2:
        ldo.l $r0, -4($fp) # $r0 = -4($fp) = moxie_memmap = ent
        ld.l $r1, ($r0) # $r1 = ent->addr
        xor $r0, $r0 # $r0 = 0
        cmp $r1, $r0 # if(ent->addr == 0)
        beq .L3       # goto L3 and return

        
        ldo.l $r0, -4($fp) # $r0 = ent
        inc $r0, 8 # $r0 = (ent->tags)
        ldi.l $r1, data_tag; # $r1 = "data0,"
        jsra strstr # $r0 = strstr($r0, $r1)
        xor $r1, $r1 # $r1 = 0
        cmp $r0, $r1 # if($r0 != $r1)
        bne .L4       # goto L4

        ldo.l $r0, -4($fp) # r0 = ent
        inc $r0, 32 # r0 = ent++
        sto.l -4($fp), $r0
        jmpa .L2

    .L4:

        ldo.l $r0, -4($fp) # r0 = ent
        ld.l $r0, ($r0) # $r0 = ent->addr
        ld.l $r0, ($r0) # $r0 = *(ent->addr)
        ret
        
    .L3:
        ldi.l $r0, -1
        ret





