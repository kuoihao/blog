---
date:
    created: 2025-03-29
---


这里记录了关于为`ggml_gemv_q4_0_4x8_q8_0`函数添加sve计算方式的过程

<!-- more -->

sve 算子
```cpp
#if ! ((defined(_MSC_VER)) && ! defined(__clang__)) && defined(__aarch64__) && defined(__ARM_FEATURE_SVE) 
    //only 128bits support
    if (ggml_cpu_has_sve() && ggml_cpu_get_sve_cnt() == 16) {

        //这里准备一个用于调换数组1,2号元素顺序的mask,以及8bit,16bit,32bit的mask
        uint32_t indices[] = {0, 2, 1, 3}; 
        svuint32_t index_vec = svld1_u32(svptrue_b32(), indices);
        const svbool_t pg_b8 = svptrue_b8();
        const svbool_t pg_b16 = svptrue_b16();
        const svbool_t pg_b32 = svptrue_b32();

        const block_q4_0x4 * b_ptr = (const block_q4_0x4 *) vx; 
        for (int c = 0; c < nc; c += ncols_interleaved) {
            const block_q8_0 * a_ptr = (const block_q8_0 *) vy;
            svfloat32_t acc= svdup_n_f32(0.0f);
            for (int b = 0; b < nb; b++) {
                //与neon相同的取数过程，利用指针偏移和svld1,为128bit寄存器填充16个int8_t
                const svint8_t b0 = svld1_s8(pg_b8,(const int8_t *) b_ptr->qs);
                const svint8_t b1 = svld1_s8(pg_b8,(const int8_t *) b_ptr->qs + 16);
                const svint8_t b2 = svld1_s8(pg_b8,(const int8_t *) b_ptr->qs + 32);
                const svint8_t b3 = svld1_s8(pg_b8,(const int8_t *) b_ptr->qs + 48);

                svfloat16_t bd = svld1_f16(pg_b16, (const __fp16 *)b_ptr->d);//取出f16共8个，但只有前四个有用
                svfloat16_t ad = svdup_n_f16(*(const __fp16 *) &a_ptr->d);//取出f16复制8次
                svfloat32_t scale = svmul_f32_x(pg_b32,svcvt_f32_f16_x(pg_b16, ad),svcvt_f32_f16_x(pg_b16, svzip1(bd, bd)));
                //先通过zip把bd的数据每个复制2次，[A,B,C,D]=>[A,A,B,B,C,C,D,D],这样寄存器中只保留前四个数据，再和ad的数据都转化为f32,四个f32相乘得到缩放系数，相对于原有的4个f16相乘，这里多算了
    
                //与neon相同的取数过程，利用指针偏移和svdup,为128bit寄存器填充2个64bit数，每个64bit中包含8个int8,2个64bit相同
                const svint8_t a0 =svreinterpret_s8_u64(svdup_n_u64(*((const uint64_t *)a_ptr->qs)));
                const svint8_t a1 =svreinterpret_s8_u64(svdup_n_u64(*((const uint64_t *)a_ptr->qs+1)));
                const svint8_t a2 =svreinterpret_s8_u64(svdup_n_u64(*((const uint64_t *)a_ptr->qs+2)));
                const svint8_t a3 =svreinterpret_s8_u64(svdup_n_u64(*((const uint64_t *)a_ptr->qs+3)));

                svint32_t ret0 = svdup_n_s32(0);
                svint32_t ret1 = svdup_n_s32(0);
    
                //与neon相同的dot指令，每四个对应的int8数据相乘加到一个int32中
                ret0 = svdot_s32(ret0, b0 << 4, a0);
                ret1 = svdot_s32(ret1, b1 << 4, a0);
                ret0 = svdot_s32(ret0, b2 << 4, a1);
                ret1 = svdot_s32(ret1, b3 << 4, a1);
    
                ret0 = svdot_s32(ret0, b0 & 0xf0U, a2);
                ret1 = svdot_s32(ret1, b1 & 0xf0U, a2);
                ret0 = svdot_s32(ret0, b2 & 0xf0U, a3);
                ret1 = svdot_s32(ret1, b3 & 0xf0U, a3);

                //由于sve没有neon的水平相加指令，即[A,B,C,D][E,F,G,H]=>[A+B,C+D,E+F,G+H];
                //sve2的成对相加是[A,B,C,D][E,F,G,H]=>[A+B,E+F,C+D,G+H];所以需要sve调换顺序。

                // uint32_t indices[] = {0, 2, 1, 3}; 
                // svuint32_t index_vec = svld1_u32(svptrue_b32(), indices);
                svint32_t ret = svtbl_s32(svaddp_s32_m(pg_b32, ret0, ret1),index_vec);


                //这里还记录了2种只使用sve命令的实现水平相加效果的命令
                // svint32_t ret = svadd_s32_m(svptrue_b32(), svuzp1_s32(ret0, ret1), svuzp2_s32(ret0, ret1));
                // svint32_t ret = svadd_s32_m(svptrue_b32(), svzip1_s32(ret0, ret1), svzip2_s32(ret0, ret1)); 

                //与neon相同的mla过程，将ret结果和缩放系数相乘，还原为f32
                acc = svmla_f32_x(pg_b32,acc,svcvt_f32_s32_x(pg_b32,ret>>4),scale);
                a_ptr++;
                b_ptr++;
            }
            //与neon相同的过程，将数据存储回指针中
            svst1_f32(pg_b32,s, acc);
            s += ncols_interleaved;
        }
        return;
    } 
#endif // #if ! ((defined(_MSC_VER)) && ! defined(__clang__)) && defined(__aarch64__) && defined(__ARM_FEATURE_SVE2)
```


原neon算子

```cpp
#if ! ((defined(_MSC_VER)) && ! defined(__clang__)) && defined(__aarch64__) && defined(__ARM_NEON) && defined(__ARM_FEATURE_DOTPROD)
    if (ggml_cpu_has_neon() && ggml_cpu_has_dotprod()) {
        const block_q4_0x4 * b_ptr = (const block_q4_0x4 *) vx;

        for (int c = 0; c < nc; c += ncols_interleaved) {
            const block_q8_0 * a_ptr = (const block_q8_0 *) vy;
            float32x4_t acc = vdupq_n_f32(0);
            for (int b = 0; b < nb; b++) {
                //取数过程
                int8x16_t b0 = vld1q_s8((const int8_t *) b_ptr->qs);
                int8x16_t b1 = vld1q_s8((const int8_t *) b_ptr->qs + 16);
                int8x16_t b2 = vld1q_s8((const int8_t *) b_ptr->qs + 32);
                int8x16_t b3 = vld1q_s8((const int8_t *) b_ptr->qs + 48);
                float16x4_t bd = vld1_f16((const __fp16 *) b_ptr->d);//取出4个f16


                int8x16_t a0 = (int8x16_t) vld1q_dup_s64((const int64_t *) a_ptr->qs);
                int8x16_t a1 = (int8x16_t) vld1q_dup_s64((const int64_t *) a_ptr->qs + 1);
                int8x16_t a2 = (int8x16_t) vld1q_dup_s64((const int64_t *) a_ptr->qs + 2);
                int8x16_t a3 = (int8x16_t) vld1q_dup_s64((const int64_t *) a_ptr->qs + 3);
                float16x4_t ad = vld1_dup_f16((const __fp16 *) &a_ptr->d);//取出1个f16,复制4次

                int32x4_t ret0 = vdupq_n_s32(0);
                int32x4_t ret1 = vdupq_n_s32(0);

                //计算过程
                ret0 = vdotq_s32(ret0, b0 << 4, a0);
                ret1 = vdotq_s32(ret1, b1 << 4, a0);
                ret0 = vdotq_s32(ret0, b2 << 4, a1);
                ret1 = vdotq_s32(ret1, b3 << 4, a1);

                ret0 = vdotq_s32(ret0, b0 & 0xf0U, a2);
                ret1 = vdotq_s32(ret1, b1 & 0xf0U, a2);
                ret0 = vdotq_s32(ret0, b2 & 0xf0U, a3);
                ret1 = vdotq_s32(ret1, b3 & 0xf0U, a3);

                //水平相加
                int32x4_t ret = vpaddq_s32(ret0, ret1);

                //利用scale将int32转换为f32
                acc = vfmaq_f32(acc, vcvtq_n_f32_s32(ret, 4),
                        vmulq_f32(vcvt_f32_f16(ad), vcvt_f32_f16(bd)));//这里是先计算了4个f16相乘，再计算和int32数据的相乘
                a_ptr++;
                b_ptr++;
            }
            //储存过程
            vst1q_f32(s, acc);
            s += ncols_interleaved;
        }
        return;
    }
#endif // #if ! ((defined(_MSC_VER)) && ! defined(__clang__)) && defined(__aarch64__) && defined(__ARM_NEON) && defined(__ARM_FEATURE_DOTPROD)
```

