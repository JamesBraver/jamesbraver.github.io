---
title: "Java受信任lookup使用中的坑"
date: 2026-11-14 09:00:00 +0800
tags: [java, chinese]
description: >-
  记录了使用MethodHandles$Lookup.defineClass时遇到的特性
---

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.19.1/dist/katex.min.css" integrity="sha384-WwGtaC6ywCHxA5cstpj/3+xIZvTez8dq2IcBQaXRkenHZ7FVVq1ZROtURwfbtTlG" crossorigin="anonymous">
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.19.1/dist/katex.min.js" integrity="sha384-a1WQdjRj162i159OYq041X6I4K8NenkrI09LlPmiHg0YOb7CR+wJOraXwK9abpnE" crossorigin="anonymous"></script>
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.19.1/dist/contrib/auto-render.min.js" integrity="sha384-bjyGPfbij8/NDKJhSGZNP/khQVgtHUE5exjm4Ydllo42FwIgYsdLO2lXGmRBf5Mz" crossorigin="anonymous"
    onload="renderMathInElement(document.body);"></script>
<script>
// Source - https://stackoverflow.com/a/1033448
// Posted by Matchu, modified by community. See post 'Timeline' for change history
// Retrieved 2026-11-14, License - CC BY-SA 4.0

window.addEventListener('load', function () {
katex.render("2(2 ^ {32}) + 1 + 5", document.querySelector('text[id=katex-render]'), {"displayMode":true,"leqno":false,"fleqn":false,"throwOnError":true,"errorColor":"#cc0000","strict":"warn","output":"htmlAndMathml","trust":false,"macros":{"\\f":"#1f(#2)"}})
})

</script>
<script>
console.log('很明显你打开了devtools然后我在这里要告诉你我使用的是JDK25，所以请不要揣测我在2026年还在用JDK8写java混淆器')
</script>

<noscript>Please enable JavaScript for a better experience, there are no advertising scripts for this blog I swear on my grandpa's grave</noscript>

# 记笔者使用MethodHandles$Lookup.defineClass时遇到的特性

有一天，笔者在为自己的混淆器编写8589934598 \(<text id="katex-render">
<span class="katex-display"><span class="katex"><span class="katex-mathml"><math xmlns="http://www.w3.org/1998/Math/MathML" display="block"><semantics><mrow><mn>2</mn><mo stretchy="false">(</mo><msup><mn>2</mn><mn>32</mn></msup><mo stretchy="false">)</mo><mo>+</mo><mn>1</mn><mo>+</mo><mn>5</mn></mrow><annotation encoding="application/x-tex">2(2 ^ {32}) + 1 + 5</annotation></semantics></math></span><span class="katex-html" aria-hidden="true"><span class="katex-base"><span class="katex-strut" style="height: 1.1141em; vertical-align: -0.25em;"></span><span class="mord">2</span><span class="mopen">(</span><span class="mord"><span class="mord">2</span><span class="msupsub"><span class="vlist-t"><span class="vlist-r"><span class="vlist" style="height: 0.8641em;"><span class="" style="top: -3.113em; margin-right: 0.05em;"><span class="pstrut" style="height: 2.7em;"></span><span class="katex-sizing reset-size6 size3 mtight"><span class="mord mtight"><span class="mord mtight">32</span></span></span></span></span></span></span></span></span><span class="mclose">)</span><span class="mspace" style="margin-right: 0.2222em;"></span><span class="mbin">+</span><span class="mspace" style="margin-right: 0.2222em;"></span></span><span class="katex-base"><span class="katex-strut" style="height: 0.7278em; vertical-align: -0.0833em;"></span><span class="mord">1</span><span class="mspace" style="margin-right: 0.2222em;"></span><span class="mbin">+</span><span class="mspace" style="margin-right: 0.2222em;"></span></span><span class="katex-base"><span class="katex-strut" style="height: 0.6444em;"></span><span class="mord">5</span></span></span></span></span></text>\)个string解密用常量变异指令时发现了手动填充变体的ASM指令和硬编写计算方法是一个会让代码变得非常他妈的臃肿的做法，
于是想到了实时define class再让JVM计算的[Mensa](https://www.mensa.org/)级解决方案，然后在大脑内运行了transformers并加载了a114-2b模型推理出了如下代码(仅展示主要片段):
```java
private static Class<?> generateCalculatorClass(Algorithms algorithm, int saltSeed) throws IllegalAccessException {

    String className = calculatorClassName(algorithm, saltSeed);

    ClassNode classNode = new ClassNode();
    classNode.version = V1_8;
    classNode.name = className;
    classNode.access = ACC_PUBLIC | ACC_FINAL | ACC_SYNTHETIC;
    classNode.superName = "java/lang/Object";

    MethodNode methodNode = new MethodNode(ACC_PUBLIC | ACC_STATIC, "calculate", "(II)I", null, null);

    Local local = Local.alloc(methodNode, int.class);

    InsnList instructions = new InsnList();


    instructions.add(new VarInsnNode(ILOAD, 0));
    instructions.add(local.store());

    instructions.add(algorithm.insns(local, saltSeed));
    instructions.add(new InsnNode(IRETURN));

    methodNode.instructions = instructions;
    classNode.methods.add(methodNode);

    byte[] bytes = ASMUtils.classToBytes$noContext(classNode);

    return FuckJVMRestrictions.getTrustedLookup().defineClass(bytes);
}
```

此时笔者为了炫酷所以把calculatorClassName方法的返回String加入了前缀`a114/`，然后在使用
[IMPL_LOOKUP](https://github.com/openjdk/jdk8u/blob/b661ee6ff840d6922aa7424a4d8f24760b21cf26/jdk/src/share/classes/java/lang/invoke/MethodHandles.java#L672)
的情况下遇到了如下报错:

```stderr
java.lang.IllegalArgumentException: a114/PolymorphCalculator_LOWBIAS32 not in same package as lookup class
	at java.base/java.lang.invoke.MethodHandleStatics.newIllegalArgumentException(MethodHandleStatics.java:177)
	at java.base/java.lang.invoke.MethodHandles$Lookup.validateAndFindInternalName(MethodHandles.java:2173)
	at java.base/java.lang.invoke.MethodHandles$Lookup.makeClassDefiner(MethodHandles.java:2207)
	at java.base/java.lang.invoke.MethodHandles$Lookup.defineClass(MethodHandles.java:1753)
	at obfuscator.utils.Algorithms.generateCalculatorClass(Algorithms.java:302)
	at obfuscator.utils.Algorithms.getCalculatorClass(Algorithms.java:317)
	at obfuscator.utils.Algorithms.calculate(Algorithms.java:332)
	at obfuscator.transform.impl.data.EnhancedStringEncryptTransformer.encode(EnhancedStringEncryptTransformer.java:478)
```

笔者采用了如下解决方案:

1. 把`FuckJVMRestrictions.getTrustedLookup()` 换成 `MethodHandles.lookup()`
2. 把prefix换成`Algorithms.class.getPackageName().a114$dotToSlash() + "/"`

再次运行，没有问题，混淆产物也没有字符串解密失败的情况。