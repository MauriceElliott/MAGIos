/*
 * MAGIos Memory Functions Header - MAGI Pattern Blue Interface
 * Memory management interface for the MAGI kernel system
 */

#ifndef MAGI_MEMORY_FUNCTIONS_H
#define MAGI_MEMORY_FUNCTIONS_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// MAGI Memory Management Functions
void *malloc(size_t size);
void free(void *ptr);

// Standard C Memory Functions
void *memcpy(void *dest, const void *src, size_t n);
void *memset(void *s, int c, size_t n);
void *memmove(void *dest, const void *src, size_t n);

// MAGI Diagnostics Functions
size_t magi_heap_available(void);
int magi_heap_check(void);

// MAGI Wrapper Functions (Swift-safe names)
void *magi_alloc(size_t size);
void magi_dealloc(void *ptr);

#ifdef __cplusplus
}
#endif

#endif // MAGI_MEMORY_FUNCTIONS_H
