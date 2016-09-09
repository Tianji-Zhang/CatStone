<TeXmacs|1.99.2>

<style|generic>

<\body>
  <doc-data|<doc-title|The Auto-Discretizer>>

  <section|Basic Syntax Tree>

  All the expressions should be written in the following form:

  <tabular|<tformat|<table|<row|<cell|\<less\>func\<gtr\>>|<cell|:
  :=>|<cell|(\<less\>op\<gtr\> \<less\>func\<gtr\>
  \<less\>func\<gtr\>)>>|<row|<cell|>|<cell| \ \|>|<cell|(\<less\>div\<gtr\>
  \ \<less\>unknowns\<gtr\>\|\<less\>time\<gtr\>\|\<less\>location\<gtr\>
  \ \<less\>func\<gtr\>)>>|<row|<cell|>|<cell|
  \ \|>|<cell|\<less\>unknowns\<gtr\>\|\<less\>coefs\<gtr\>>>|<row|<cell|>|<cell|
  \ \|>|<cell|\<less\>consts\<gtr\>>>|<row|<cell|>|<cell|
  \ \|>|<cell|\<less\>location\<gtr\>\|\<less\>time\<gtr\>>>|<row|<cell|\<less\>coefs\<gtr\>>|<cell|:
  :=>|<cell|(\<less\>op\<gtr\> \<less\>coefs\<gtr\>
  \<less\>coefs\<gtr\>)>>|<row|<cell|>|<cell|
  \ \|>|<cell|\<less\>unknowns\<gtr\>>>|<row|<cell|>|<cell| \ \|
  >|<cell|\<less\>consts\<gtr\>>>|<row|<cell|>|<cell|
  \ \|>|<cell|\<less\>location\<gtr\>\|\<less\>time\<gtr\>>>|<row|<cell|\<less\>op\<gtr\>>|<cell|:
  :=>|<math|+*> \| <math|-> \| <math|\<times\>> \| <math|<text|>\<div\>> \|
  expt>>>>

  Note: segmented-linear functions are not supported currently.

  <section|The Implementation of Partial Derivation>

  The terms in the expressions should have the index of their located cells
  by default. Those indexes change after partial derivation, so we need
  represent this change in our parser.

  We consider the finite difference method

  <\equation*>
    <frac|\<partial\>F|\<partial\>x>=<frac|F<rsub|l<around*|(|i|)>->F<rsub|r<around*|(|i|)>>|\<Delta\>x<rsub|i>>
  </equation*>

  For second order,

  <\equation*>
    <frac|\<partial\><rsup|2>F|\<partial\>x<rsup|2>>=<frac|\<partial\>|\<partial\>x><around*|(|<frac|F<rsub|l<around*|(|i|)>->F<rsub|r<around*|(|i|)>>|\<Delta\>x<rsub|i>>|)>=<frac|F<rsub|l<around*|(|l<around*|(|i|)>|)>>-F<rsub|r<around*|(|l<around*|(|i|)>|)>>|\<Delta\>x<rsub|l<around*|(|i|)>>\<Delta\>x<rsub|i>>-<frac|F<rsub|l<around*|(|r<around*|(|i|)>|)>>-F<rsub|r<around*|(|r<around*|(|i|)>|)>>|\<Delta\>x<rsub|r<around*|(|i|)>>\<Delta\>x<rsub|i>>
  </equation*>

  We need to consider three conditions:\ 

  1. Upwind scheme for cell-face change;

  2. Cell change, which is shown in the second-order derivation above.

  3. Boundary condition implementation for the above two situations.

  The normal order should be: (1) Cell change and upwind scheme are
  implemented after the entire changing process; (2) B.C related change
  should be updated after each differential operation.

  The generated expressions should be similar except on boundaries.\ 
</body>

<initial|<\collection>
</collection>>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|?>>
    <associate|auto-2|<tuple|2|?>>
    <associate|footnote-1|<tuple|1|?>>
    <associate|footnr-1|<tuple|1|?>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|1<space|2spc>Basic
      Syntax Tree> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|2<space|2spc>The
      Implementation of Partial Derivation>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-2><vspace|0.5fn>
    </associate>
  </collection>
</auxiliary>