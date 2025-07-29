/*
 * MAGIos Memory Functions - MAGI Pattern Blue Implementation
 * Memory management for the MAGI kernel system
 */

#include <stddef.h>
#include <stdint.h>

// MAGI Memory Pool Configuration
#define MAGI_HEAP_SIZE (1024 * 1024) // 1MB heap for MAGI operations
#define MAGI_BLOCK_MAGIC 0xEBA01     // Evangelion Unit-01 signature
#define MAGI_FREE_MAGIC 0xA6CE1      // Angel detection pattern

// Memory block header for MAGI allocation tracking
typedef struct magi_block {
  uint32_t magic;          // Block integrity check
  size_t size;             // Block size excluding header
  struct magi_block *next; // Next block in free list
  uint8_t is_free;         // AT Field status (0=allocated, 1=free)
} magi_block_t;

// MAGI Heap - Static allocation for embedded environment
static uint8_t magi_heap[MAGI_HEAP_SIZE] __attribute__((aligned(16)));
static magi_block_t *magi_free_list = NULL;
static uint8_t magi_heap_initialized = 0;

// Initialize MAGI memory system
static void magi_heap_init(void) {
  if (magi_heap_initialized)
    return;

  // Initialize the first free block covering entire heap
  magi_free_list = (magi_block_t *)magi_heap;
  magi_free_list->magic = MAGI_FREE_MAGIC;
  magi_free_list->size = MAGI_HEAP_SIZE - sizeof(magi_block_t);
  magi_free_list->next = NULL;
  magi_free_list->is_free = 1;

  magi_heap_initialized = 1;
}

// Find suitable free block using first-fit algorithm
static magi_block_t *magi_find_free_block(size_t size) {
  magi_block_t *current = magi_free_list;
  magi_block_t *prev = NULL;

  while (current) {
    if (current->is_free && current->size >= size) {
      // Split block if significantly larger
      if (current->size > size + sizeof(magi_block_t) + 32) {
        magi_block_t *new_block =
            (magi_block_t *)((uint8_t *)current + sizeof(magi_block_t) + size);
        new_block->magic = MAGI_FREE_MAGIC;
        new_block->size = current->size - size - sizeof(magi_block_t);
        new_block->next = current->next;
        new_block->is_free = 1;

        current->size = size;
        current->next = new_block;
      }

      current->magic = MAGI_BLOCK_MAGIC;
      current->is_free = 0;
      return current;
    }
    prev = current;
    current = current->next;
  }

  return NULL; // No suitable block found - AT Field breach!
}

// MAGI malloc implementation
void *malloc(size_t size) {
  if (size == 0)
    return NULL;

  // Align size to 8-byte boundary for MAGI efficiency
  size = (size + 7) & ~7;

  if (!magi_heap_initialized) {
    magi_heap_init();
  }

  magi_block_t *block = magi_find_free_block(size);
  if (!block) {
    return NULL; // Heap exhausted - Pattern Blue failed
  }

  // Return pointer to data area (after header)
  return (uint8_t *)block + sizeof(magi_block_t);
}

// MAGI free implementation
void free(void *ptr) {
  if (!ptr)
    return;

  // Get block header from data pointer
  magi_block_t *block = (magi_block_t *)((uint8_t *)ptr - sizeof(magi_block_t));

  // Verify block integrity
  if (block->magic != MAGI_BLOCK_MAGIC) {
    return; // Corrupted block - Angel contamination detected
  }

  // Mark as free and update magic
  block->magic = MAGI_FREE_MAGIC;
  block->is_free = 1;

  // Coalesce with next block if it's also free
  if (block->next && block->next->is_free) {
    block->size += sizeof(magi_block_t) + block->next->size;
    block->next = block->next->next;
  }

  // Coalesce with previous block if possible
  magi_block_t *current = magi_free_list;
  while (current && current->next != block) {
    current = current->next;
  }

  if (current && current->is_free) {
    current->size += sizeof(magi_block_t) + block->size;
    current->next = block->next;
  }
}

// Memory copy - MAGI data transfer protocol
void *memcpy(void *dest, const void *src, size_t n) {
  unsigned char *d = (unsigned char *)dest;
  const unsigned char *s = (const unsigned char *)src;

  // Optimized copy for aligned addresses
  if (((uintptr_t)d & 3) == 0 && ((uintptr_t)s & 3) == 0) {
    uint32_t *d32 = (uint32_t *)d;
    const uint32_t *s32 = (const uint32_t *)s;

    while (n >= 4) {
      *d32++ = *s32++;
      n -= 4;
    }

    d = (unsigned char *)d32;
    s = (const unsigned char *)s32;
  }

  // Copy remaining bytes
  while (n--) {
    *d++ = *s++;
  }

  return dest;
}

// Memory set - MAGI pattern initialization
void *memset(void *s, int c, size_t n) {
  unsigned char *p = (unsigned char *)s;
  unsigned char byte_val = (unsigned char)c;

  // Optimized set for larger blocks
  if (n >= 4) {
    uint32_t word_val =
        (byte_val << 24) | (byte_val << 16) | (byte_val << 8) | byte_val;

    // Align to 4-byte boundary
    while (((uintptr_t)p & 3) && n > 0) {
      *p++ = byte_val;
      n--;
    }

    // Set 4 bytes at a time
    uint32_t *p32 = (uint32_t *)p;
    while (n >= 4) {
      *p32++ = word_val;
      n -= 4;
    }

    p = (unsigned char *)p32;
  }

  // Set remaining bytes
  while (n--) {
    *p++ = byte_val;
  }

  return s;
}

// Memory move - MAGI safe data transfer
void *memmove(void *dest, const void *src, size_t n) {
  unsigned char *d = (unsigned char *)dest;
  const unsigned char *s = (const unsigned char *)src;

  if (d < s) {
    // Forward copy - standard memcpy behavior
    return memcpy(dest, src, n);
  } else if (d > s) {
    // Backward copy to handle overlap
    d += n - 1;
    s += n - 1;
    while (n--) {
      *d-- = *s--;
    }
  }
  // If d == s, no operation needed

  return dest;
}

// MAGI heap diagnostics function
size_t magi_heap_available(void) {
  if (!magi_heap_initialized)
    return MAGI_HEAP_SIZE;

  size_t available = 0;
  magi_block_t *current = magi_free_list;

  while (current) {
    if (current->is_free) {
      available += current->size;
    }
    current = current->next;
  }

  return available;
}

// MAGI heap integrity check
int magi_heap_check(void) {
  if (!magi_heap_initialized)
    return 1;

  magi_block_t *current = magi_free_list;
  while (current) {
    if (current->magic != MAGI_BLOCK_MAGIC &&
        current->magic != MAGI_FREE_MAGIC) {
      return 0; // Corruption detected - AT Field compromised
    }
    current = current->next;
  }

  return 1; // AT Field integrity maintained
}

// MAGI wrapper functions to avoid Swift reserved symbols
void *magi_alloc(size_t size) { return malloc(size); }

void magi_dealloc(void *ptr) { free(ptr); }
