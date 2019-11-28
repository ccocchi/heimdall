#include <ruby/ruby.h>

static __thread uint64_t transaction_allocations;

void increment_allocations() {
  transaction_allocations++;
}

static VALUE
get_allocations_count() {
  return ULL2NUM(transaction_allocations);
}
