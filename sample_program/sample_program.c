// Copyright (c) eBPF for Windows contributors
// SPDX-License-Identifier: MIT

// Compile with:
// clang -target bpf -O2 -Werror -c sample_program.c -o sample_program.o

#include "bpf_endian.h"
#include "bpf_helpers.h"

SEC("bind")
int
func(bind_md_t* ctx)
{
    return 0;
}
