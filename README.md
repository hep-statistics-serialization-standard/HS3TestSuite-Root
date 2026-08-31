# HS3TestSuite — RooFit reference backend

Build recipe for the RooFit reference-backend Docker image used by [HS3TestSuite](https://github.com/hep-statistics-serialization-standard/HS3TestSuiteCode).
Not a library — it produces a container with ROOT/RooFit plus the two things the suite's fixture-generation CI looks for, as specified by the [reference-backend contract](https://github.com/hep-statistics-serialization-standard/HS3TestSuiteCode/blob/master/docs/reference-backend-contract.md).

| File | Role |
| --- | --- |
| `root.Dockerfile` | Base image, ROOT from a pinned commit (slow) |
| `root-release.Dockerfile` | Base image, official ROOT binary release (fast) |
| `roofit.Dockerfile` | The product: base + backend plugin + `generate-fixtures` |
| `roofit_backend.py` | RooFit implementation of the backend contract |
| `generate-fixtures.sh` | The `generate-fixtures` executable CI requires |

## The two seams

**`generate-fixtures` on `$PATH`.** CI starts a job container from the image reference in a fixture's `metadata.json: reference_backend`, then `docker exec`s `generate-fixtures <fixture-dir>`. 
GitHub Actions never runs a job container's `ENTRYPOINT`, so this must be a real executable. It writes `expected.json` and *extends* `manifest.json` — both into the fixture dir it is handed, so point trial runs at a throwaway copy of a suite checkout, never the real one. 
The wrapper just forwards to the suite's own tool, vendored in the workspace at `.hs3suite/`, so `GITHUB_WORKSPACE` must be set. Since `reference_backend` is used directly as an image ref, pin `...@sha256:...` rather than a tag.

**The `hs3suite_backend` plugin.** Upstream does `from hs3suite_backend import HS3TestSuiteBackend`, falling back to its builtin on ImportError. `roofit.Dockerfile` installs `roofit_backend.py` as `/opt/hs3testsuite/hs3suite_backend.py` and puts that dir on `PYTHONPATH`. 
**Both names are load-bearing** — rename the installed module or the class and it silently falls back to the builtin (the upstream `except` is bare).

## Editing `roofit_backend.py`

- `twice_delta_nll_scan` reports `2 * (NLL(point) - NLL(reference))`; the subtraction cancels backend-dependent constant NLL offsets. The NLL is built once and re-evaluated by mutating vars in place; `EvalBackend("legacy")` and `NumCPU(1)` are pinned.
- `suppress_root_output()` dups fds 1/2 to `/dev/null`, because ROOT's C++ diagnostics bypass `RooMsgService` and `redirect_stdout` alike. New ROOT calls that print go inside.
- `importJSON`/`exportJSON` signal failure by *returning false*. `upconvert` must raise, never write a partial file — its `output_path` is moved over the fixture on clean return.
- `RooConstVar` parameters are skipped with a note, not raised on: HS3 legitimately serializes fixed values that way.

## Build

```bash
docker build -f root-release.Dockerfile -t root-release:6.40.02 .   # or root.Dockerfile
docker build -f roofit.Dockerfile -t hs3testsuite-roofit:<tag> .
```

`roofit.Dockerfile` pins its base in the `FROM` line (`stalbrec/root:e3a793`) — to use another base, edit that line or retag. Tags follow the ROOT identity built against, since fixtures pin the exact image that generated them. Both bases set `CLING_STANDARD_PCH=none` deliberately; don't drop it.
