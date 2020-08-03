#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include "args_parser.h"

void usage(const int argc, const char * const * const argv) {
    printf(" USAGE: %s <pid>\n", argv[0]);
}

bool isvim(const char pid[6], int pid_len) {
    char filename[18];
    ssize_t bytes_read = 0;
    int fd;
    char ppid[6];
    int ppid_i = 0;
    char buf[128];
    int cs;

    %%{
        machine isvim;

        action no {
            return false;
        }

        action yes {
            return true;
        }

        action copy_ppid {
            ppid[ppid_i++] = *p;
        }

        action is_ppid_vim {
            return isvim(ppid, ppid_i);
        }

        pid = ( '1 ' @no
              | [2-9] ' '
              | [1-9] [0-9]{1,5} ' '
              );

        comm = ( '('+ 'n'? 'vim' ')'@yes
               | (33 .. 126)+ ' ');

        state = (33 .. 126)+ ' ';

        ppid = [0-9]+ @copy_ppid
               ' '@is_ppid_vim;

        main := pid comm state ppid;

        write data;

    }%%

    sprintf(filename, "/proc/%.*s/stat", pid_len, pid);
    fd = open(filename, O_RDONLY);
    if (-1 == fd) {
        return false;
    }

    %% write init;
    bytes_read = read(fd, buf, 128);
    while (0 < bytes_read) {
        char * p = buf;
        char * pe = buf + bytes_read;
        %% write exec;
    }

    close(fd);

    return 0;
}

int main(int argc, const char * const argv[])
{

    struct args_opts_s opts = {0};
    int ret = parse_args(argc, argv, &opts);
    if (-1 == ret) {
        usage(argc, argv);
        return 1;
    }

    if (true == isvim(opts.pid, opts.pid_len)) {
        return 0;
    } else {
        return 1;
    }
}
