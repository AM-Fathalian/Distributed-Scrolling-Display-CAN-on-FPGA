SECTIONS
{
    . = 0x40;
    .vectortable : {boot/vectortable.o(.text)}
    . = 0x80;
    .boot : {boot/boot.o(.text)}
    .text : {*(.text)}
}