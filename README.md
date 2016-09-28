# floppycipher

This program reads all data sectors from a floppy (skipping boot sector, FAT tables and root dir) and ciphers strings of 8 bytes by applying an XOR operation with the string "UCAB2005".

After applying this code to a floppy once, the files will not be readable. After applying this program a second time, the XOR operation will be reverted and the floppy will have exactly the same state as in the beginning; the files will be readable once again.

Written by Samuel Akerman.
Caracas, Venezuela
