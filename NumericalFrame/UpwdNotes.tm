<TeXmacs|1.99.2>

<style|generic>

<\body>
  <doc-data|<doc-title|A Problem with Upwind Scheme>>

  <\example>
    The basic upwind scheme for flux in hyperbolic transport problem
  </example>

  For a species transport equation

  <math|C<rsub|i><rsup|n+1>=C<rsub|i><rsup|
  n>-<around*|[|F<rsub|l<around*|(|i|)>>-F<rsub|r<around*|(|i|)>>|]>>

  Actually,

  <math|F<rsub|l<around*|(|i|)>>=<around*|{|<tabular|<tformat|<table|<row|<cell|u
  <rsub|l<around*|(|i|)>>C<rsub|i-1>>|<cell|if>|<cell|u<rsub|l<around*|(|i|)>>\<gtr\>0>>|<row|<cell|u
  <rsub|l<around*|(|i|)>>C<rsub|i>>|<cell|if>|<cell|u<rsub|l<around*|(|i|)>>\<less\>0>>>>>|\<nobracket\>>>

  <math|u<rsub|l<around*|(|i|)>>=<frac|1|2><around*|(|u<rsub|i-1>+u<rsub|i>|)>>

  So, what is the strict definition of <math|l>?

  <\example>
    The second-order upwind scheme for flux in a black-oil model \ 
  </example>

  <math|T<rsub|l<around*|(|i|)>>=<around*|\<nobracket\>|<frac|A|\<Delta\>x>
  <frac|k|\<mu\>>|\|><rsub|l<around*|(|i|)>>>

  The original index is <math|i-<frac|1|2>> but for the purpose of robustness
  we change it in the form of a function.

  We still could not figure out what the index really means, because

  <math|A<rsub|l<around*|(|i|)>>=A<rsub|i-1>=A<rsub|i+1>>

  <math|\<Delta\>x<rsub|l<around*|(|i|)>>=<around*|\||x<rsub|i>-x<rsub|x-1>|\|>>

  <math|\<mu\><rsub|l<around*|(|i|)>>=<frac|1|2><around*|(|\<mu\><rsub|i-1>+\<mu\><rsub|i>|)>>

  <math|k<rsub|l<around*|(|i|)>>=<around*|{|<tabular|<tformat|<table|<row|<cell|k<rsub|i-1>+k<rsub|i-2>-k<rsub|i>>|<cell|if>|<cell|p<rsub|i>\<less\>p<rsub|i-1>>>|<row|<cell|k<rsub|i>+k<rsub|i-2>-k<rsub|i-1>>|<cell|if>|<cell|p<rsub|i>\<gtr\>p<rsub|i-1>>>>>>|\<nobracket\>>>

  So, the <math|l> is actually a very complex function, it should be
  formally, generally defined as

  <\scm>
    (define (l i target-variable self-variable control-variable upwd_scheme
    BCs))
  </scm>

  The variables are arrays. Generally, <math|l> could be defined as an array
  of functions with diffent index i. In this case, boundary conditions can be
  also implemented with more convenience.

  The B.C. is actually a special case, where the function returns something
  also based on the actual geometry and user setups on the specially-used
  discretize scheme.

  <section*|Recommendation>

  I suggest to use a data structure based on index. \ All the symbols in the
  system should be classified into two levels:

  <strong|1. Independent Unknowns>: the variables we need to solve.

  <strong|2. Intermediate Coefficients>: the coefficients we need to evaluate
  in the non-linear system, such as flux and relative permeability. They
  appear in the original equations and must be defined by users as functions
  of independent unknowns.
</body>

<initial|<\collection>
</collection>>

<\references>
  <\collection>
    <associate|auto-1|<tuple|2|?>>
    <associate|auto-2|<tuple|1|?>>
    <associate|auto-3|<tuple|2|?>>
    <associate|footnote-1|<tuple|1|?|..\\..\\..\\AppData\\Roaming\\TeXmacs\\texts\\scratch\\no_name_3.tm>>
    <associate|footnr-1|<tuple|1|?|..\\..\\..\\AppData\\Roaming\\TeXmacs\\texts\\scratch\\no_name_3.tm>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|table>
      <tuple|normal|Coefficients of evaluation terms in example 1. For
      example 2, three such tables are required for each phase equation (oil,
      water and gas).|<pageref|auto-2>>

      <tuple|normal|Intermediate functions in each cell.|<pageref|auto-3>>
    </associate>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|Recommendation>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>
    </associate>
  </collection>
</auxiliary>