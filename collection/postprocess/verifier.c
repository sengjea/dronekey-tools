#include <stdio.h>
#include "nv08c.h"

static int num_commands = 0, num_errors = 0;

void
verify_dat(unsigned char *cb, unsigned char *pb, int total_length, int position, FILE* output) {
  static int prev_is_dle = 0, state = 0, cmd_start_index = 0, start_at_pb = 0, in_crc;
  int cur_read_index = 0;
  while (cur_read_index < total_length) { 
    switch (state) {
      case 0:
        prev_is_dle = 0;
        start_at_pb = 0;
        in_crc = 0;
        cmd_start_index = cur_read_index; 
        if (cb[cur_read_index] != NV08C_BINR_DLE) {
          state = 0;
        } else {
          state++; 
        }
        
        cur_read_index++;
        break; 
      case 1:
        if (cb[cur_read_index] == NV08C_BINR_DLE ||
            cb[cur_read_index] == NV08C_BINR_ETX ||
            cb[cur_read_index] == NV08C_BINR_CRC) {
          /* Not the right state. Abort remaining
           * cmd will be discarded */ 
          state = 0;
        } else {
          state++;
          num_commands++; 
        }
        cur_read_index++;
        break;
      case 2:
        if (prev_is_dle) {
          switch (cb[cur_read_index]) {
            case NV08C_BINR_CRC:
              in_crc = 1;
            case NV08C_BINR_DLE:
              prev_is_dle = 0;
              break;
            case NV08C_BINR_ETX:
              if (start_at_pb) {
                fwrite(&pb[cmd_start_index], (1024-cmd_start_index), sizeof(char),  
                    output);
                fwrite(&cb[0], (cur_read_index + 1), sizeof(char),  
                    output);
              } else {
                fwrite(&cb[cmd_start_index], (cur_read_index + 1 - cmd_start_index), sizeof(char),  
                    output);
              }
              state = 0;
              break;
            default:
              printf("Error at %08X\r\n", position+cur_read_index); 
              num_errors++; 
              state = 0;
              break;
          } 
        } else {
          prev_is_dle = (cb[cur_read_index] == NV08C_BINR_DLE) ? !in_crc : 0; 
        } 
        cur_read_index++;
        break;
    } 
  }
  if (!start_at_pb) { 
    start_at_pb = 1;
  } else {
    printf("Command too long!");
  }
}


int
main (int argc, char** argv) {
  FILE *input, *output;
  unsigned char a[4096], b[4096]; 
  int length = 0, current_size, i = 0;
  input = fopen(argv[1],"r");
  output = fopen(argv[2],"w");
  if (!input || !output) return 1;
  while ((length = fread((i%2?b:a), sizeof(char), 1024, input))) {
    current_size = ftell(input);
    verify_dat((i%2?b:a), (i%2?a:b), length, current_size, output);
    i++;
    if(length < 1024) break;
  }
  printf("%d %d\r\n", num_commands, num_errors);
  fclose(input);
  
  return 0;
}



