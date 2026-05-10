# Benchmarks Game Go smoke report

- Timestamp: 2026-05-10T08:42:59+00:00
- ish binary: /workspace/projects/ish-arm64/build-arm64-linux/ish
- rootfs: /workspace/projects/ish-arm64/alpine-arm64-fakefs
- timeout: 1200s
- guest workdir: /tmp/benchmarksgame-go-smoke
- Result: 10 / 10 passing

## Selected Go source variants

| Benchmark | Program page | Skipped self-contained alternatives |
|---|---|---|
| binarytrees | binarytrees-go-2.html | — |
| fannkuchredux | fannkuchredux-go-3.html | — |
| fasta | fasta-go-2.html | — |
| knucleotide | knucleotide-go-7.html | — |
| mandelbrot | mandelbrot-go-4.html | — |
| nbody | nbody-go-3.html | — |
| pidigits | pidigits-go-6.html | pidigits-go-4.html,pidigits-go-1.html,pidigits-go-3.html,pidigits-go-2.html |
| regexredux | regexredux-go-3.html | regexredux-go-5.html,regexredux-go-4.html |
| revcomp | revcomp-go-6.html | — |
| spectralnorm | spectralnorm-go-4.html | — |

## Results

| Benchmark | Status | Bytes | Lines | CRC:Size | Time (s) |
|---|---:|---:|---:|---|---:|
| binarytrees | PASS | 144 | 4 | 3398443640:144 | 0.19 |
| fannkuchredux | PASS | 24 | 2 | 3876461884:24 | 0.29 |
| fasta | PASS | 10245 | 171 | 1573388369:10245 | 0.18 |
| knucleotide | PASS | 136 | 15 | 2580809362:136 | 0.18 |
| mandelbrot | PASS | 1211 | 2 | 1840259308:1211 | 0.14 |
| nbody | PASS | 26 | 2 | 980964627:26 | 0.14 |
| pidigits | PASS | 151 | 10 | 3273113594:151 | 0.14 |
| regexredux | PASS | 263 | 13 | 3404323976:263 | 0.35 |
| revcomp | PASS | 10174 | 168 | 2332509513:10174 | 0.20 |
| spectralnorm | PASS | 12 | 1 | 2938823901:12 | 0.21 |

## Raw guest log tail

```text
__BG_BEGIN:binarytrees
__BG_TIME:binarytrees:0.19
__BG_RESULT:binarytrees:PASS:144:4:3398443640:144
__BG_BEGIN:fannkuchredux
__BG_TIME:fannkuchredux:0.29
__BG_RESULT:fannkuchredux:PASS:24:2:3876461884:24
__BG_BEGIN:fasta
__BG_TIME:fasta:0.18
__BG_RESULT:fasta:PASS:10245:171:1573388369:10245
__BG_BEGIN:knucleotide
__BG_TIME:knucleotide:0.18
__BG_RESULT:knucleotide:PASS:136:15:2580809362:136
__BG_BEGIN:mandelbrot
__BG_TIME:mandelbrot:0.14
__BG_RESULT:mandelbrot:PASS:1211:2:1840259308:1211
__BG_BEGIN:nbody
__BG_TIME:nbody:0.14
__BG_RESULT:nbody:PASS:26:2:980964627:26
__BG_BEGIN:pidigits
__BG_TIME:pidigits:0.14
__BG_RESULT:pidigits:PASS:151:10:3273113594:151
__BG_BEGIN:regexredux
__BG_TIME:regexredux:0.35
__BG_RESULT:regexredux:PASS:263:13:3404323976:263
__BG_BEGIN:revcomp
__BG_TIME:revcomp:0.20
__BG_RESULT:revcomp:PASS:10174:168:2332509513:10174
__BG_BEGIN:spectralnorm
__BG_TIME:spectralnorm:0.21
__BG_RESULT:spectralnorm:PASS:12:1:2938823901:12
__BG_ALL_DONE

```

## Notes

- 2026-05-10: an earlier matrix run briefly hit `fatal: bad g in signal handler` at the first Go benchmark. The root cause was iSH sharing `sigaltstack` through the process `sighand`; Linux keeps alternate signal stacks per thread. Go installs one signal stack per M/thread, so cross-thread delivery could run a Go handler on another thread's stack. iSH now stores alternate signal stack state per task/thread, and runtime coverage includes a pthread `sigaltstack` fixture.
- Revalidated after the platform-boundary cleanup that moved host sysinfo/thread-rusage/stat/random/memory-pressure shims behind `platform/platform.h` and fixed guest `/proc` CPU/memory/uptime unit reporting.
