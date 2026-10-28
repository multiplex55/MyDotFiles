# Rust ↔ C FFI on Windows: Minimal, Complete DLL Reference

This is a **C DLL called by a Rust executable**, using three functions:

1. `process_fixed`: two **fixed-size arrays of 32,769 `u16` elements**; no length arguments.
2. `exchange_record`: one **C-compatible struct in**, one struct **out**.
3. `process_records`: an **array of structs in**, an array **out**, with runtime element counts.

Rust allocates every input/output buffer. C borrows pointers only while each function runs. No memory is allocated in C or copied automatically when the pointers cross the boundary. This example uses **direct DLL linking** (not runtime lookup/fallback); if you already resolve functions with `GetProcAddress` or `libloading`, use the same C signatures and the function-pointer types listed at the end.

## 0. Requirements and files

- Windows, **64-bit MSVC Rust** (`rustc -vV` should show `host: x86_64-pc-windows-msvc`).
- Visual Studio 2022 C++ Build Tools with MSVC and the Windows SDK.
- Start **Developer PowerShell for VS 2022** configured for **x64**, or start **x64 Native Tools Command Prompt for VS 2022** and enter `powershell` there. Verify `cl` and `cargo` are available.

Create a Rust project with this structure:

```text
ffi_demo/
├── Cargo.toml
├── build.rs
├── native/
│   ├── ffi_demo.h
│   └── ffi_demo.c
└── src/
    └── main.rs
```

In PowerShell, run:

```powershell
cargo new ffi_demo --bin
Set-Location ffi_demo
New-Item -ItemType Directory -Force native | Out-Null
```

Create/replace the five files below with exactly these contents.

## 1. `Cargo.toml`

```toml
[package]
name = "ffi_demo"
version = "0.1.0"
edition = "2024"
build = "build.rs"

[dependencies]
```

There are **no third-party Rust dependencies**.

## 2. `build.rs` — link Rust against the C DLL's import library

```rust
fn main() {
    let native = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("native");
    println!("cargo::rustc-link-search=native={}", native.display());
    println!("cargo::rustc-link-lib=dylib=ffi_demo");
}
```

When MSVC builds the DLL, it also emits `ffi_demo.lib` (the **import library**). Cargo uses it at **link time**; Windows loads `ffi_demo.dll` at **run time**. The `.lib` is **not** a replacement for the `.dll`.

## 3. `native/ffi_demo.h` — C ABI contract (single source of truth)

```c
#ifndef FFI_DEMO_H
#define FFI_DEMO_H

#include <stddef.h>  /* size_t */
#include <stdint.h>  /* uint8_t, uint16_t, uint32_t, int32_t */

#define FIXED_LEN 32769
#define SAMPLE_LEN 4

#ifdef _WIN32
#define FFI_EXPORT __declspec(dllexport)
#else
#define FFI_EXPORT
#endif

typedef struct Record {
    uint32_t id;
    uint16_t samples[SAMPLE_LEN];
    uint8_t enabled;              /* 0 = false; nonzero = true */
} Record;

/* Pointer to an ENTIRE fixed-size array; exactly two parameters. */
FFI_EXPORT int32_t process_fixed(
    const uint16_t (*input)[FIXED_LEN],
    uint16_t (*output)[FIXED_LEN]
);

/* One struct in; one struct out. */
FFI_EXPORT int32_t exchange_record(
    const Record *input,
    Record *output
);

/* Arbitrary number of structs; output_capacity is in RECORDS, not bytes. */
FFI_EXPORT int32_t process_records(
    const Record *input,
    size_t count,
    Record *output,
    size_t output_capacity,
    size_t *written
);

#endif
```

**Why two arguments for `process_fixed`?** `const uint16_t (*input)[32769]` is a pointer to an array of precisely 32,769 elements. Unlike a C parameter written `const uint16_t input[32769]` (which adjusts to `const uint16_t *`), the pointer-to-array type preserves the array length in the C type. Neither form checks the actual memory allocation at runtime; Rust's safe wrapper below requires the exact size at compile time.

## 4. `native/ffi_demo.c` — complete C implementations

```c
#include "ffi_demo.h"

/* Validate expected Windows/MSVC layout. Do NOT use #pragma pack here. */
_Static_assert(sizeof(Record) == 16, "Record size mismatch");
_Static_assert(_Alignof(Record) == 4, "Record alignment mismatch");
_Static_assert(offsetof(Record, id) == 0, "id offset mismatch");
_Static_assert(offsetof(Record, samples) == 4, "samples offset mismatch");
_Static_assert(offsetof(Record, enabled) == 12, "enabled offset mismatch");

FFI_EXPORT int32_t process_fixed(
    const uint16_t (*input)[FIXED_LEN],
    uint16_t (*output)[FIXED_LEN]
) {
    if (input == NULL || output == NULL) return -1;

    for (size_t i = 0; i < FIXED_LEN; ++i) {
        /* Truncation to uint16_t gives wrapping behavior (mod 65536). */
        (*output)[i] = (uint16_t)((uint32_t)(*input)[i] * 2u);
    }
    return 0;
}

FFI_EXPORT int32_t exchange_record(const Record *input, Record *output) {
    if (input == NULL || output == NULL) return -1;

    *output = *input;                    /* Copy field values. */
    output->id = input->id + 1u;
    output->enabled = (uint8_t)(input->enabled == 0); /* Toggle flag. */
    return 0;
}

FFI_EXPORT int32_t process_records(
    const Record *input,
    size_t count,
    Record *output,
    size_t output_capacity,
    size_t *written
) {
    if (written == NULL) return -1;
    *written = 0;
    if (count > output_capacity) return -2;
    if (count != 0 && (input == NULL || output == NULL)) return -3;

    for (size_t i = 0; i < count; ++i) {
        output[i] = input[i];
        for (size_t j = 0; j < SAMPLE_LEN; ++j) {
            output[i].samples[j] =
                (uint16_t)((uint32_t)input[i].samples[j] + 10u);
        }
        output[i].enabled = (uint8_t)(input[i].enabled != 0);
    }
    *written = count;
    return 0;
}
```

Error returns are intentionally simple: `0` success; `-1` invalid required pointer; `-2` insufficient output capacity; `-3` null data with nonzero count. Rust checks both the status and the returned `written` count.

## 5. `src/main.rs` — complete Rust declarations, safe wrappers, and runnable tests

```rust
use std::mem::{align_of, offset_of, size_of};

const FIXED_LEN: usize = 32_769;

#[repr(C)]
#[derive(Debug, Default, Clone, Copy, PartialEq, Eq)]
struct Record {
    id: u32,
    samples: [u16; 4],
    enabled: u8, // C uint8_t, NOT Windows BOOL
}

// The signatures below MUST match the C header, including calling convention.
// This is Rust edition 2024's syntax for foreign declarations.
unsafe extern "C" {
    fn process_fixed(
        input: *const [u16; FIXED_LEN],
        output: *mut [u16; FIXED_LEN],
    ) -> i32;

    fn exchange_record(input: *const Record, output: *mut Record) -> i32;

    fn process_records(
        input: *const Record,
        count: usize,          // C size_t
        output: *mut Record,
        output_capacity: usize, // C size_t, measured in Records
        written: *mut usize,    // C size_t*
    ) -> i32;
}

// These small wrappers are the ONLY places that need unsafe calls.
// Safety assumption: the C implementation obeys the header contract,
// writes no more than the supplied capacity, and retains no pointers.

fn call_process_fixed(
    input: &[u16; FIXED_LEN],
    output: &mut [u16; FIXED_LEN],
) -> Result<(), i32> {
    let status = unsafe { process_fixed(input as *const _, output as *mut _) };
    if status == 0 { Ok(()) } else { Err(status) }
}

fn call_exchange_record(input: &Record, output: &mut Record) -> Result<(), i32> {
    let status = unsafe { exchange_record(input as *const _, output as *mut _) };
    if status == 0 { Ok(()) } else { Err(status) }
}

fn call_process_records(input: &[Record], output: &mut [Record]) -> Result<usize, i32> {
    let mut written: usize = 0;
    let status = unsafe {
        process_records(
            input.as_ptr(),
            input.len(),
            output.as_mut_ptr(),
            output.len(),
            &mut written,
        )
    };
    if status != 0 { return Err(status); }
    if written > output.len() { return Err(-100); } // Defensive ABI check.
    Ok(written)
}

fn main() {
    // Detect a mismatched struct definition BEFORE handing it to C.
    assert_eq!(size_of::<Record>(), 16);
    assert_eq!(align_of::<Record>(), 4);
    assert_eq!(offset_of!(Record, id), 0);
    assert_eq!(offset_of!(Record, samples), 4);
    assert_eq!(offset_of!(Record, enabled), 12);

    // (1) Two exact-length u16 arrays. No pointer/length pairs needed.
    let input: [u16; FIXED_LEN] = std::array::from_fn(|i| i as u16);
    let mut output = [0u16; FIXED_LEN];
    call_process_fixed(&input, &mut output).unwrap();
    assert_eq!(output[100], 200);
    assert_eq!(output[FIXED_LEN - 1], 0); // 32768 * 2 wraps to 0.
    println!("fixed array OK: {} -> {}", input[100], output[100]);

    // (2) One struct in, one struct out.
    let original = Record {
        id: 41,
        samples: [1, 2, 3, 4],
        enabled: u8::from(true),
    };
    let mut changed = Record::default();
    call_exchange_record(&original, &mut changed).unwrap();
    assert_eq!(changed.id, 42);
    assert_eq!(changed.samples, original.samples);
    assert_eq!(changed.enabled, 0);
    println!("struct OK: {changed:?}");

    // (3) Array of structs in/out; count and capacity are element counts.
    let records: [Record; 2] = [
        Record { id: 1, samples: [1, 2, u16::MAX, 4], enabled: 0 },
        Record { id: 2, samples: [5, 6, 7, 8], enabled: 9 },
    ];
    let mut processed = [Record::default(); 2];
    let written = call_process_records(&records, &mut processed).unwrap();
    assert_eq!(written, 2);
    assert_eq!(processed[0].samples, [11, 12, 9, 14]);
    assert_eq!(processed[1].enabled, 1);
    println!("record array OK ({written} written): {processed:?}");

    // The SAME wrapper also accepts Vec<Record> and Vec<Record> output:
    let dynamic_input = vec![original, changed];
    let mut dynamic_output = vec![Record::default(); dynamic_input.len()];
    assert_eq!(
        call_process_records(&dynamic_input, &mut dynamic_output).unwrap(),
        dynamic_input.len()
    );
    println!("Vec<Record> OK");
}
```

## 6. Build and run on Windows (PowerShell)

From the `ffi_demo` directory, in a **VS Developer PowerShell configured for x64**:

```powershell
# Compile the C source as C11 and link a 64-bit DLL + import .lib.
Push-Location native
cl /nologo /W4 /std:c11 /TC /LD /Fe:ffi_demo.dll ffi_demo.c
if ($LASTEXITCODE -ne 0) { throw "C DLL build failed" }
Pop-Location

# Build the Rust application (build.rs locates native/ffi_demo.lib).
cargo build
if ($LASTEXITCODE -ne 0) { throw "Rust build failed" }

# Windows must find the DLL at runtime. Put it beside the executable.
Copy-Item .\native\ffi_demo.dll .\target\debug\ffi_demo.dll -Force
.\target\debug\ffi_demo.exe
```

Expected output (formatting of `Record` uses Rust's Debug formatter):

```text
fixed array OK: 100 -> 200
struct OK: Record { id: 42, samples: [1, 2, 3, 4], enabled: 0 }
record array OK (2 written): [Record { id: 1, samples: [11, 12, 9, 14], enabled: 0 }, Record { id: 2, samples: [15, 16, 17, 18], enabled: 1 }]
Vec<Record> OK
```

For `--release`, use `cargo build --release` and copy the DLL to `target\release` instead. Whenever you rebuild the C DLL, copy its updated `.dll` again. Rebuild the Rust executable too if the **C ABI** (function names or signatures, struct layout) changes.

## 7. ABI cheat sheet (Rust ↔ C)

| Rust | C header | Notes |
|---|---|---|
| `u8`, `u16`, `u32`, `u64` | `uint8_t`, `uint16_t`, `uint32_t`, `uint64_t` | Exact-width integers |
| `i8`, `i16`, `i32`, `i64` | `int8_t`, `int16_t`, `int32_t`, `int64_t` | Exact-width signed integers |
| `f32`, `f64` | `float`, `double` | Matching Windows MSVC representations |
| `usize` | `size_t` | 64-bit on Windows x64; 32-bit on x86 |
| `std::ffi::c_int` | `int` | C's native `int` (32-bit on Windows) |
| `std::ffi::c_long` | `long` | **32-bit on Windows x64**, unlike some Unix platforms |
| `bool` | C99/C11 `_Bool` (`<stdbool.h>` `bool`) | Valid where the actual C declaration uses `_Bool`; **not Windows `BOOL`** |
| `u8` with `0/1` | `uint8_t` | Chosen here for explicit struct flag storage; check `!= 0` |
| `*const T` | `const T *` | Read-only through this pointer |
| `*mut T` | `T *` | Writable pointer |
| `*const [u16; N]` | `const uint16_t (*)[N]` | Pointer to entire fixed-size array |
| `*const T` + `usize` | `const T *` + `size_t` | Slice/Vec data pointer + element count |
| `#[repr(C)] struct` | matching `struct` | Fields, order, alignment, padding must match |
| `std::ffi::c_char` | `char` | Use for C chars; do not equate Rust's Unicode `char` with C `char` |
| `std::ffi::c_void` | `void` (pointer) | `*mut c_void` ↔ `void *` |

**C array declaration distinction:**

```c
void a(const uint16_t x[32769]);      /* actually const uint16_t *x */
void b(const uint16_t (*x)[32769]);   /* pointer to array[32769] */
```

Corresponding Rust parameter types: `a(x: *const u16)` vs. `b(x: *const [u16; 32769])`.

**For your runtime DLL loader**, these are the equivalent callable function-pointer types (you already handle the lookup/fallback):

```rust
type ProcessFixed = unsafe extern "C" fn(
    *const [u16; FIXED_LEN], *mut [u16; FIXED_LEN],
) -> i32;
type ExchangeRecord = unsafe extern "C" fn(*const Record, *mut Record) -> i32;
type ProcessRecords = unsafe extern "C" fn(
    *const Record, usize, *mut Record, usize, *mut usize,
) -> i32;
```

If using those types to load function pointers dynamically, **keep the DLL loaded while using its pointers**. The return type, argument order, pointer constness, and calling convention must match your C definitions. On 32-bit Windows, pay particular attention to `cdecl` vs. `stdcall`: an ordinary C function uses the C calling convention; do not change it to `extern "system"` unless the C declaration actually specifies the Windows system ABI.

## 8. Five FFI rules to keep

1. **Rust references/slices/Vectors are not C ABI structures.** Pass raw pointers to elements, never the `Vec` or slice object itself. The safe wrapper may take `&[T]` or `&mut [T]` and convert using `as_ptr()` / `as_mut_ptr()`.
2. **Fixed length known by the API?** A pointer to `[T; N]` needs no extra length. **Runtime length?** Pass `T*` and an element count. **Different input/output lengths?** Pass counts separately.
3. **The C pointer must be valid, aligned, and point to enough initialized/readable or writable elements for the declared operation.** The examples borrow Rust memory only during the call. C must not free or retain those pointers.
4. **Use `#[repr(C)]` and matching C types for structs.** Do not put `String`, `Vec`, Rust references, Rust enums with implicit layout, or a Rust `bool` where the C header says `uint8_t`/Windows `BOOL` inside shared structs.
5. **Never infer the ABI from a DLL symbol name.** Keep one canonical C header; verify structs with size/alignment/offset tests; keep the C compiler target architecture consistent with Rust. Export presence alone does not prove that its function type matches.

## References (official documentation)

- Rust Reference: [external blocks and `extern "C"`](https://doc.rust-lang.org/reference/items/external-blocks.html)
- Rust Reference: [C-compatible type layout](https://doc.rust-lang.org/reference/type-layout.html#reprc-structs)
- Cargo: [build scripts and native linking](https://doc.rust-lang.org/cargo/reference/build-scripts.html)
- Microsoft: [building a DLL with `/LD`](https://learn.microsoft.com/en-us/cpp/build/reference/md-mt-ld-use-run-time-library?view=msvc-170)
- Microsoft: [enabling C11 with `/std:c11`](https://learn.microsoft.com/en-us/cpp/build/reference/std-specify-language-standard-version?view=msvc-170)
- Microsoft: [linking an executable to a DLL](https://learn.microsoft.com/en-us/cpp/build/linking-an-executable-to-a-dll?view=msvc-170)
