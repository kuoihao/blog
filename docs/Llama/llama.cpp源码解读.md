---
date:
    created: 2025-03-08
---
这里记录了对于llama.cpp的源码解读，通过debug以及火焰图完成，主要是优化过程，并非完整的架构解读。

<!-- more-->

代码的版本是b4837，llama.cpp的版本号更新速度比较快，希望其推理框架的基本原则不变吧

### 进入main函数

```cpp
            for (int i = 0; i < (int) embd.size(); i += params.n_batch) {
                int n_eval = (int) embd.size() - i;
                if (n_eval > params.n_batch) {
                    n_eval = params.n_batch;
                }

                LOG_DBG("eval: %s\n", string_from(ctx, embd).c_str());

                if (llama_decode(ctx, llama_batch_get_one(&embd[i], n_eval))) {
                    LOG_ERR("%s : failed to eval\n", __func__);
                    return 1;
                }

                n_past += n_eval;

                LOG_DBG("n_past = %d\n", n_past);
                // Display total tokens alongside total time
                if (params.n_print > 0 && n_past % params.n_print == 0) {
                    LOG_DBG("\n\033[31mTokens consumed so far = %d / %d \033[0m\n", n_past, n_ctx);
                }
            }
```
模型输入 Token 并执行预测：
每次最多处理 params.n_batch 个 Token。
调用 llama_decode() 进行计算。


llama-decode
```cpp
int32_t llama_decode(
        struct llama_context * ctx,
          struct llama_batch   batch) {
    const int ret = llama_decode_impl(*ctx, batch);
    if (ret != 0) {
        LLAMA_LOG_ERROR("%s: failed to decode, ret = %d\n", __func__, ret);
    }

    return ret;
}
```

进入llama_decode_impl()
首先构建计算图
```cpp
        ggml_cgraph * gf = llama_build_graph(lctx, ubatch, false);
```
划分计算图：
```cpp
        ggml_backend_sched_alloc_graph(lctx.sched.get(), gf);
```
计算图计算：
```cpp
llama_graph_compute(lctx, gf, n_threads,threadpool);
```
计算图计算过程：
计算图划分，一直划分到算子
```cpp
ggml_backend_sched_graph_compute_async(lctx.sched.get(), gf);
ggml_backend_sched_compute_splits(sched);
ggml_backend_graph_compute_async(split_backend, &gv);
```
算子选择函数
```cpp
enum ggml_status ggml_backend_graph_compute_async(ggml_backend_t backend, struct ggml_cgraph * cgraph) {
    return backend->iface.graph_compute(backend, cgraph);
}
```

最终在这里计算backend->iface.graph_compute(backend, cgraph);调用了后端的计算接口，ggml-cpu.c中ggml_compute_forward实现了算子选择，在ggml_cpu_extra_compute_forward中的compute_forward函数
具体到我这里，在ggml-cpu-aarch64.cpp,对于乘法命令forward_mul_mat(params, op);在算子为乘法时，最终使用gemv模板使用对应的分块乘法函数,具体在我的例子，ggml_gemv_q4_0_4x8_q8_0(n, s, bs, vx, vy, nr, nc);这是耗时最长的算子






