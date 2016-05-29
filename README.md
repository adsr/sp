sp
==

I sometimes find myself using the mouse to copy a path visible on the terminal
that was printed by another program (e.g., find, git), usually with intent to
paste it as a parameter to another shell command. sp helps you do this without
using the mouse.

### Synopsis

    adam@asx1c2:~/tmp$ find
    .
    ./file-a
    ./file-b
    ./dir
    ./dir/file-c
    adam@asx1c2:~/tmp$ sp
    0 ./file-a
    1 ./file-b
    2 ./dir
    3 ./dir/file-c
    adam@asx1c2:~/tmp$ sp 2
    ./dir
    adam@asx1c2:~/tmp$ sp c
    ./dir/file-c
    adam@asx1c2:~/tmp$ sp d
    ./dir
    adam@asx1c2:~/tmp$ sp @d
    ./dir
    ./dir/file-c
    adam@asx1c2:~/tmp$ sp nope
    adam@asx1c2:~/tmp$ echo $?
    1
    adam@asx1c2:~/tmp$ sp 999
    Path index 999 out of range.
    adam@asx1c2:~/tmp$ echo $?
    1
    adam@asx1c2:~/tmp$ echo $(sp 3)
    ./dir/file-c

### Limitations

sp only works from inside screen or tmux.
