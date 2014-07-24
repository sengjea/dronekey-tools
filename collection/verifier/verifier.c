#include <stdio.h>
#include "nv08c.h"


int
verify_dat(char *b, int total_length) {
  static int prev_is_dle = 0, state = 0;
  int read_length = 0;
  while (read_length < total_length) { 
    printf("%02X ", (unsigned char) b[read_length]); 
    switch (state) {
      case 0:
        prev_is_dle = 0;
        if (b[read_length] != NV08C_BINR_DLE) continue;
        state++; 
        read_length++;
        break; 
      case 1:
        if (b[read_length] == NV08C_BINR_DLE ||
            b[read_length] == NV08C_BINR_ETX ||
            b[read_length] == NV08C_BINR_CRC) {
          /* Not the right state. Abort remaining
           * cmd will be discarded */ 
          printf("FAIL!: %04X\r\n", read_length); 
          state = 0;
          return 0; 
        }
        state++;
        read_length++;
        break;
      case 2:
        if (prev_is_dle && b[read_length] == NV08C_BINR_ETX) {
          state = 0;
          printf("\r\n\r\n");
        } else {
          prev_is_dle = (b[read_length] == NV08C_BINR_DLE) ? 1 : 0; 
        } 
        read_length++;
        break;
    } 
  }
  return 1;
}


int
main (int argc, char** argv) {
  FILE *f;
  char buffer[1024]; 
  int length = 0;
  f = fopen(argv[1],"r");
  if (!f) return 1;
  while ((length = fread(buffer, sizeof(char), 1024, f))) {
    if (!verify_dat(buffer, length)) {
      break; 
    }     
  }
  fclose(f);
  printf("\r\n");
  return 0;
}



