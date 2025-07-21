# Performance

## Overview

Shell startup is up to **95% faster** with lazy loading and modular architecture.

## Performance Improvements

| Feature | Improvement | Impact |
|---------|-------------|--------|
| **Lazy Loading** | 0.9s saved per shell | 95% faster startup |
| **Modular Architecture** | On-demand loading | Reduced memory usage |
| **Template System** | 8 project types | Faster project setup |

## Performance Breakdown

| Tool | Eager Load | Lazy Load | Time Saved |
|------|------------|-----------|------------|
| **NVM** | 0.21s | 0.003s | **0.21s** |
| **rbenv** | 0.06s | 0.003s | **0.06s** |
| **pyenv** | 0.15s | 0.003s | **0.15s** |
| **asdf** | 0.008s | 0.003s | **0.005s** |
| **Total** | **0.43s** | **0.012s** | **0.42s** |

> Based on 10-iteration benchmarks on M1 macbook pro

## Monitoring

```bash
# Measure current performance
make performance-monitor ACTION=measure

# Run performance tests
make performance-test

# Benchmark lazy loading
./scripts/utils/lazy-loading-benchmark.sh
```
