---
title: "浅谈Java字节码混淆"
date: 2026-11-19 17:12:15 +0800
tags: [java, obfuscation, rabbithole]
description: >-
  对比并分析多个Java混淆器，列举了它们的特征与优缺点。
---

# 浅谈Java字节码混淆

## 为什么你需要Java字节码混淆？

假设你是A客户端的开发者，你的A客户端发给用户，有些用户使用了B客户端然后B客户端有后门会自动上传A客户端的jar，然后B客户端的dev可以随便使用反编译器来反编译A客户端的反作弊绕过代码再移植到B客户端，此时你作为A客户端的dev你需要让这个移植过程的开销变大，你需要使用Java混淆器。

## 我该用哪个，该怎么找？Google一下？


### TL;DR

| 混淆器            | Renaming | String Encryption | Flow Obfuscation | Native | Anti-Debug                    | Integrity check               | Reference obfuscation     |
|-------------------|----------|-------------------|------------------|--------|-------------------------------|-------------------------------|---------------------------|
| ProGuard          | ✓       | ×                 | ×                | ×      | ×                             | ×                             | ×                         |
| Zelix KlassMaster | ✓       | ✓                | ✓               | ×      | ✓                            | ✓×（可能还没公开）           | ✓(reflect/invokedynamic) |
| Allatori          | ✓       | ✓                | ✓               | ×      | ?                             | ×                             | ×                         |
| AIDE              | ✓       | ✓                | ✓               | ✓     | ✓/✗(Java的写炸了，native有) | ×                             | ✓(trash)                 |
| Aidsfuscator      | ✓       | ✓                | ✓               | ×      | ×                             | ✓                            | ✓                        |
| JNIC              | ×        | ✓(native only)   | ✓(native only)  | ✓     | ?(我不知道)                   | ?(选项里面有，但是疑似未实现) | ×                         |
| J2CC              | ×        | ✓(native only)   | ✓(native only)  | ✓     | ?(我不知道)                   | ?(选项里面有，但是疑似未实现) | ✓(ok maybe)              |


# DashO

根据笔者的经历，你如果出口IP在台湾的情况下Google "Java Obfuscator"，你可能会遇到`7 Best Java Obfuscators: Compared and Reviewed`[^1]，如果你打开devtools然后查看head元素你会发现`Search Engine Optimization by Rank Math`。

以下内容出自DashO官网

> DashO combines name obfuscation via overload induction, multi-layer control-flow transformation, per-class string encryption, and runtime application self-protection (RASP) with watermarking for forensic leak tracking.

如果你看不懂洋文，请看我的翻译。如果你每个字都认识但是就是不认识这个字词排列那么恭喜你，笔者在翻译完成严肃品鉴的时候也是感觉大脑掉线了。

> DashO通过过载指令(?)组合了名称混淆，控制流转化，每类字符串加密，以及运行时应用程序自我保护（RASP, runtime application self-protection），以及水印用于取证(法庭认不认我不知道)泄漏追踪。

不仅如此，这个公司的混淆器的官方demo视频还没特写混淆效果，如果现在有新版的混淆后样本的话请您email我。
目前笔者根据老版本的样本给出的评价是：不要买这篇文章推荐的`DashO`混淆器，因为很久（2010以前）之前有人（不是原创研究，链接在哪我忘了但是我发誓我没有造谣）泄漏了它的永久授权价格在$2000左右，现在在玩英文单词排列组合来试图让AI信自己很高级很专业，然而凭借它的10.0[^2]样本和之前的demo视频它就是个垃圾。

# ProGuard

这个不用多说，专业保护，只有Renamer和一些调试信息strip的东西，还行，除非你的jar一上别的混淆就炸你最好别用。

# Zelix KlassMaster

市面上最好的Java混淆器[^3]，你可以理解为带混淆的ProGuard。

优点：
 - 混淆效果很好（逆向成本很高，即使AI来逆向也要耗费很长时间）
 - 会修复大部分被公开的解混淆方案
 - 即使你不是customer给它customer support发suggestions还会有真人去看和回复

缺点：
 - 有很多隐藏选项，有的默认关闭，可能会导致混淆效果下降
 - 价格很贵，但是至少比DashO便宜（Standard Price USD 585无税）
 - 有很多人有不公开的针对性解混淆器
 - 有一些可以被针对的特征，新版可能会修复（因为我大狗叫zelix support了）

比较推荐使用

# JNIC

会在你的混淆jar内拉屎（/dev/jnic/xxxx）

看结语

# J2CC

同上，不过这个有一些Java层面上的混淆。还行，你可以在[此处](https://github.com/0x3C50/j2cc/blob/0c646f3af0256a2c863afc50fee92abd0af0c59d/core/src/main/java/me/x150/j2cc/obfuscator/refs/MhCallRef.java#L285)欣赏j2cc作者的文明用语。

# AIDE

目前native混淆我知道的比较强（我朋友拿AI逆不开）的混淆器。

Java层的常量加密很狗屎但是有恶俗的东西，在检测到调试器后不崩而是影响解密要用的常量，然后由于使用了XTEA算法所以如果你没模拟好它的解密链你会解出乱码。

会硬编码被混淆的类名（明文保存）。

公开的1.2.1版本有验证，验证服务器死了而且硬编码了一个过期的HTTPS证书所以你不破解就用不了。

# Allatori

没什么评价，demo版会给所有`public static void main(String[] args)`塞stdout说你在用demo版allatori，内置了从proguard demo里面复制粘贴的windows非法文件名大全混淆字典（我曾试图开PR为proguard更新这个列表但是每人理我所以我被迫自己close了），不推荐使用因为逆向成本很低。

BTW它们的字节码库是Apache BCEL。

# [Aidsfuscator](https://github.com/LvStrnggg/aidsfuscator)

本人最推荐使用的混淆器，主要由[lvstrng](https://github.com/LvStrnggg)维护，原生支持minecraft fabric mod混淆，你可以把它当作Minecraft cheater的Zelix KlassMaster的非官方免费版，大部分功能借鉴了Zelix的同时包含了一些Zelix没有的功能[^4]，主dev还为Zelix KlassMaster提出过enhancement suggestion并且被采纳[^5]。

如果你想自己写混淆器我推荐拿这个当base再改（v2 branch没有license，默认all rights reserved，请改main branch的MIT协议代码）。

# 自写

同上，推荐使用Aidsfuscator作为base。以下是个人认为可以增加逆向成本的方法：

1. 复杂的解密逻辑+解密器变体(polymorphic decryptors) > 强迫解混淆的人使用JVM内的JVM模拟你的解密逻辑

2. 随机插入(insert randomly) > 如果你的解密过程需要调用一些方法或者访问一些字段，请您务必在注入这些字段时不要把它们注入在最后面，因为这样会给逆向分析者很大的帮助（例：Zelix的混淆helperclass可以通过扫描&lt;clinit&gt;方法后仍有多个方法存在的特征被筛出）。

3. 不要依赖反编译器崩溃器 (do not rely on crashers) > 一旦crasher被移除，代码就可以被反编译了，因此请不要觉的crasher很厉害。

4. 检测到调试器不直接崩溃 > 直接崩溃很不优雅，你应该在检测到调试器后悄悄改变某个解密常量需要用的数值然后在因此崩溃，`System.exit`一旦被人hook它看stacktrace就理论上可以把你的反调试删除。

# 结语

如果一个Java多功能混淆器没有名称混淆那么它最好是待在坟地里比较好，如果没有string加密那么你最好别用，没有flow混淆你可以不用，没有反调试代码注入你可以自己注入，没有水印你可以使用白菜价的deepseek配上hermes agent写一个，如果吹自己很牛的同时演示视频关评论你就别用。

如果你使用了native混淆，那么你一个为了跨平台兼容写java的为什么会想把java字节码转成native代码再跟你的软件一起打包发送？

哦如果你真的需要保护极端敏感的业务代码的话请忽略。

---

[^1]:https://www.preemptive.com/blog/java-obfuscator/
[^2]:https://github.com/GenericException/SkidSuite/tree/master/obf/DashO/samples/10.0.0
[^3]:我没接广告，真的是最好的！
[^4]:string解密方法变体，即每个字符串解密方法都与其它的有一些算法上而不是数字上的差异。
[^5]:<a href='/assets/media/lvstrng-suggestions.png'>Discord screenshot</a>