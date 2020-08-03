#include <stdint.h>
#include <stdbool.h>

struct args_opts_s {
    bool verbose;
    char pid[6];
    uint_fast8_t pid_len;
};

int parse_args(
    const int args,
    const char * const * const argv,
    struct args_opts_s * opts
);
