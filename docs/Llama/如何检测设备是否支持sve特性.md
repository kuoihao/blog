---
date:
    created: 2025-02-28
---

本文记录了如何检测设备是否支持sve/sve2特性

<!-- more-->

### 官方的一个验证代码
#### 1. 通过读取sve向量长度来判断是否支持sve

[网址](https://learn.arm.com/learning-paths/servers-and-cloud-computing/sve/sve_basics/)

```cpp
#include <stdio.h>
#include <arm_sve.h>

#ifndef __ARM_FEATURE_SVE
#warning "Make sure to compile for SVE!"
#endif

int main()
{
    printf("SVE vector length is: %ld bytes\n", svcntb());
}
```


#### 2. 通过hwcaps向内核空间的传递参数
   
```cpp
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/auxv.h>

#ifndef HWCAP_SVE
#define HWCAP_SVE (1 << 22)  
#endif

#ifndef HWCAP2_SVE2
#define HWCAP2_SVE2 (1 << 1)  
#endif

int main() {
    uint64_t hwcap = getauxval(AT_HWCAP);
    uint64_t hwcap2 = getauxval(AT_HWCAP2);

    if (hwcap & HWCAP_SVE)
        printf("SVE is supported!\n");
    else
        printf("SVE is NOT supported.\n");

    if (hwcap2 & HWCAP2_SVE2)
        printf("SVE2 is supported!\n");
    else
        printf("SVE2 is NOT supported.\n");

    return 0;
}
```

参考[cpufeature hwcaps](https://github.com/torvalds/linux/blob/master/arch/arm64/include/uapi/asm/hwcap.h)
```cpp

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/auxv.h>

// 定义所有 HWCAP 特性
#define HWCAP_FP		(1 << 0)
#define HWCAP_ASIMD		(1 << 1)
#define HWCAP_EVTSTRM		(1 << 2)
#define HWCAP_AES		(1 << 3)
#define HWCAP_PMULL		(1 << 4)
#define HWCAP_SHA1		(1 << 5)
#define HWCAP_SHA2		(1 << 6)
#define HWCAP_CRC32		(1 << 7)
#define HWCAP_ATOMICS		(1 << 8)
#define HWCAP_FPHP		(1 << 9)
#define HWCAP_ASIMDHP		(1 << 10)
#define HWCAP_CPUID		(1 << 11)
#define HWCAP_ASIMDRDM		(1 << 12)
#define HWCAP_JSCVT		(1 << 13)
#define HWCAP_FCMA		(1 << 14)
#define HWCAP_LRCPC		(1 << 15)
#define HWCAP_DCPOP		(1 << 16)
#define HWCAP_SHA3		(1 << 17)
#define HWCAP_SM3		(1 << 18)
#define HWCAP_SM4		(1 << 19)
#define HWCAP_ASIMDDP		(1 << 20)
#define HWCAP_SHA512		(1 << 21)
#define HWCAP_SVE		(1 << 22)
#define HWCAP_ASIMDFHM		(1 << 23)
#define HWCAP_DIT		(1 << 24)
#define HWCAP_USCAT		(1 << 25)
#define HWCAP_ILRCPC		(1 << 26)
#define HWCAP_FLAGM		(1 << 27)
#define HWCAP_SSBS		(1 << 28)
#define HWCAP_SB		(1 << 29)
#define HWCAP_PACA		(1 << 30)
#define HWCAP_PACG		(1UL << 31)
#define HWCAP_GCS		(1UL << 32)
#define HWCAP_CMPBR		(1UL << 33)
#define HWCAP_FPRCVT		(1UL << 34)
#define HWCAP_F8MM8		(1UL << 35)
#define HWCAP_F8MM4		(1UL << 36)
#define HWCAP_SVE_F16MM		(1UL << 37)
#define HWCAP_SVE_ELTPERM	(1UL << 38)
#define HWCAP_SVE_AES2		(1UL << 39)
#define HWCAP_SVE_BFSCALE	(1UL << 40)
#define HWCAP_SVE2P2		(1UL << 41)
#define HWCAP_SME2P2		(1UL << 42)
#define HWCAP_SME_SBITPERM	(1UL << 43)
#define HWCAP_SME_AES		(1UL << 44)
#define HWCAP_SME_SFEXPA	(1UL << 45)
#define HWCAP_SME_STMOP		(1UL << 46)
#define HWCAP_SME_SMOP4		(1UL << 47)

// 定义所有 HWCAP2 特性
#define HWCAP2_DCPODP		(1 << 0)
#define HWCAP2_SVE2		(1 << 1)
#define HWCAP2_SVEAES		(1 << 2)
#define HWCAP2_SVEPMULL		(1 << 3)
#define HWCAP2_SVEBITPERM	(1 << 4)
#define HWCAP2_SVESHA3		(1 << 5)
#define HWCAP2_SVESM4		(1 << 6)
#define HWCAP2_FLAGM2		(1 << 7)
#define HWCAP2_FRINT		(1 << 8)
#define HWCAP2_SVEI8MM		(1 << 9)
#define HWCAP2_SVEF32MM		(1 << 10)
#define HWCAP2_SVEF64MM		(1 << 11)
#define HWCAP2_SVEBF16		(1 << 12)
#define HWCAP2_I8MM		(1 << 13)
#define HWCAP2_BF16		(1 << 14)
#define HWCAP2_DGH		(1 << 15)
#define HWCAP2_RNG		(1 << 16)
#define HWCAP2_BTI		(1 << 17)
#define HWCAP2_MTE		(1 << 18)
#define HWCAP2_ECV		(1 << 19)
#define HWCAP2_AFP		(1 << 20)
#define HWCAP2_RPRES		(1 << 21)
#define HWCAP2_MTE3		(1 << 22)
#define HWCAP2_SME		(1 << 23)
#define HWCAP2_SME_I16I64	(1 << 24)
#define HWCAP2_SME_F64F64	(1 << 25)
#define HWCAP2_SME_I8I32	(1 << 26)
#define HWCAP2_SME_F16F32	(1 << 27)
#define HWCAP2_SME_B16F32	(1 << 28)
#define HWCAP2_SME_F32F32	(1 << 29)
#define HWCAP2_SME_FA64		(1 << 30)
#define HWCAP2_WFXT		(1UL << 31)
#define HWCAP2_EBF16		(1UL << 32)
#define HWCAP2_SVE_EBF16	(1UL << 33)
#define HWCAP2_CSSC		(1UL << 34)
#define HWCAP2_RPRFM		(1UL << 35)
#define HWCAP2_SVE2P1		(1UL << 36)
#define HWCAP2_SME2		(1UL << 37)
#define HWCAP2_SME2P1		(1UL << 38)
#define HWCAP2_SME_I16I32	(1UL << 39)
#define HWCAP2_SME_BI32I32	(1UL << 40)
#define HWCAP2_SME_B16B16	(1UL << 41)
#define HWCAP2_SME_F16F16	(1UL << 42)
#define HWCAP2_MOPS		(1UL << 43)
#define HWCAP2_HBC		(1UL << 44)
#define HWCAP2_SVE_B16B16	(1UL << 45)
#define HWCAP2_LRCPC3		(1UL << 46)
#define HWCAP2_LSE128		(1UL << 47)
#define HWCAP2_FPMR		(1UL << 48)
#define HWCAP2_LUT		(1UL << 49)
#define HWCAP2_FAMINMAX		(1UL << 50)
#define HWCAP2_F8CVT		(1UL << 51)
#define HWCAP2_F8FMA		(1UL << 52)
#define HWCAP2_F8DP4		(1UL << 53)
#define HWCAP2_F8DP2		(1UL << 54)
#define HWCAP2_F8E4M3		(1UL << 55)
#define HWCAP2_F8E5M2		(1UL << 56)
#define HWCAP2_SME_LUTV2	(1UL << 57)
#define HWCAP2_SME_F8F16	(1UL << 58)
#define HWCAP2_SME_F8F32	(1UL << 59)
#define HWCAP2_SME_SF8FMA	(1UL << 60)
#define HWCAP2_SME_SF8DP4	(1UL << 61)
#define HWCAP2_SME_SF8DP2	(1UL << 62)
#define HWCAP2_POE		(1UL << 63)

// 定义一个结构体来关联特性宏和特性名称
typedef struct {
    uint64_t flag;
    const char *name;
    int is_hwcap2;  // 标记是否为 HWCAP2 特性
} Feature;

// 定义 HWCAP 特性数组
Feature hwcap_features[] = {
    {HWCAP_FP, "FP", 0},
    {HWCAP_ASIMD, "ASIMD", 0},
    {HWCAP_EVTSTRM, "EVTSTRM", 0},
    {HWCAP_AES, "AES", 0},
    {HWCAP_PMULL, "PMULL", 0},
    {HWCAP_SHA1, "SHA1", 0},
    {HWCAP_SHA2, "SHA2", 0},
    {HWCAP_CRC32, "CRC32", 0},
    {HWCAP_ATOMICS, "ATOMICS", 0},
    {HWCAP_FPHP, "FPHP", 0},
    // 可以继续添加其他 HWCAP 特性
};

// 定义 HWCAP2 特性数组
Feature hwcap2_features[] = {
    {HWCAP2_DCPODP, "DCPODP", 1},
    {HWCAP2_SVE2, "SVE2", 1},
    {HWCAP2_SVEAES, "SVEAES", 1},
    {HWCAP2_SVEPMULL, "SVEPMULL", 1},
    {HWCAP2_SVEBITPERM, "SVEBITPERM", 1},
    {HWCAP2_SVESHA3, "SVESHA3", 1},
    {HWCAP2_SVESM4, "SVESM4", 1},
    {HWCAP2_FLAGM2, "FLAGM2", 1},
    {HWCAP2_FRINT, "FRINT", 1},
    {HWCAP2_SVEI8MM, "SVEI8MM", 1},
    // 可以继续添加其他 HWCAP2 特性
};

int main() {
    uint64_t hwcap = getauxval(AT_HWCAP);
    uint64_t hwcap2 = getauxval(AT_HWCAP2);

    // 检查 HWCAP 特性
    for (size_t i = 0; i < sizeof(hwcap_features) / sizeof(hwcap_features[0]); i++) {
        if (hwcap & hwcap_features[i].flag) {
            printf("%s\n", hwcap_features[i].name);
        }
    }

    // 检查 HWCAP2 特性
    for (size_t i = 0; i < sizeof(hwcap2_features) / sizeof(hwcap2_features[0]); i++) {
        if (hwcap2 & hwcap2_features[i].flag) {
            printf("%s\n", hwcap2_features[i].name);
        }
    }

    return 0;
}

```



#### 3. arm sve2教程
[教程地址](https://learn.arm.com/learning-paths/mobile-graphics-and-gaming/android_sve2/part1/) 
[源码](https://github.com/dawidborycki/Arm.SVE2)


#### 4. 工具地址

https://gitee.com/kuoihao/testcode/repository/archive/master.zip

```bash
git clone https://gitee.com/kuoihao/testcode.git
```