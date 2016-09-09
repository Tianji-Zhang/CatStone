<TeXmacs|1.99.2>

<style|generic>

<\body>
  <doc-data|<doc-title|Thoughts on Numerical Simulator>>

  <strong|Dealing with Boundary Condition>

  How to implement boundary condition in a numerical domain? We engineers
  usually try to solve this problem in the ordinary mathematical way -
  ``checking whether it is a boundary and then changing the equation
  according to each case''. This can help us solve our current computational
  problems, but very inefficient from the perspective of programming. Our
  capacity to inplement multiple dynamics on our model in the future is not
  usually fully considered. In many cases, we have to write an entirely new
  solver for each case with various physical conditions. If we want to free
  ourselves from coding and have more time on engineering, it is worthwhile
  to take some time considering the extendibility of our simulator,
  especially the implementation of boundary conditions.\ 

  To solve this problem we must think in a numerical or computational way.
  Consider the data structure of numerical methods, it is generally
  represented by some small cell or node elements with their index
  representing the geometry of the domain (e.g, the grids in FD and FV or
  nodes in FE method). Each of them contains unknowns we try to solve, and
  their relations to the unknowns in other cells. Those relations are
  originally represented by the physical equations and boundary conditions we
  want to satisfy (note: I deliberately use ``satisfy'' rather than
  ``solve'', think why?). They are translated to numerical, discretized form
  either by programs or our own calculations, thus we can loop on the
  elements to calculate the physical parameters. Since the physical
  conditions are dependent on the discretized geometry (mesh), we need a
  mapping function to represent the spatial relationship between those cells,
  and then map our discretization of physical unknowns based on the spatial
  relationship.\ 

  Then let's look upon each element of the geometric-physical domain. We have
  been taught multiple concepts on how to dealing with the relationship
  between each element, such as ``implementation for Neumann/Dirichlet
  boundary conditions'' and ``n-order upwind scheme''. If you have some
  concepts on functional programming or functional theory, you will find that
  they are actually the same thing. They try to connect each element with
  either a value, a function, or a series of functions, or another type of
  functions that have similarities on the calculation process (e.g, the input
  parameters, the formulas).\ 

  <strong|WorkFlow>

  To illustrate this relation, we can generate a mapping table as follows:

  1. The discretized geometric representation of the domain (e.g., structured
  or unstructured grid)

  2. The type of the relation (e.g., discretized B.C, upwd scheme and
  source/sink terms). And the geometric elements that this relation should be
  applied, according to the geometric, physical and numerical configuration
  of the user.\ 

  This step is quite important, we need a function or several functions to
  obtain the index of those cells required in the calculation

  <\equation*>
    f: i<rsub|cell>\<times\>i<rsub|type>\<times\>i<rsub|geom>\<rightarrow\>multiple
    lists of i<rsub|cell>
  </equation*>

  Where <math|i> is the index or the identifier.

  The function is actually a list of functions dependent on the geometric
  relation in Step 0. For example, if a 1st-order upwind scheme is applied, a
  <math|list of i<rsub|cell>> should be the single adjacent element that is
  not outside the domain. However, there are multiple directions for an
  element, e.g., four directions for a 2D finite difference or a finite
  element system. In this case, The function <math|f> should iterate itselve
  based on <math|i<rsub|geom>> to obtain all the adjacent elements involved
  in this type of relation.

  3. The variables that applied to this type of relation and mapping the
  actual function for numerical method.

  The system should be defined as follows:

  <tabular|<tformat|<cwith|1|5|1|-1|cell-lborder|0>|<table|<row|<cell|Step
  0>|<cell|>>|<row|<cell|<em|def>>|<cell|<math|<around*|{|i<rsub|cell>|}>
  >,<math|<around*|{|i<rsub|direction>|}>>>>|<row|<cell|<em|list>>|<cell|<math|f<rsub|dir>:i<rsub|direction>
  \<times\> i<rsub|cell>\<rightarrow\>i<rsub|cell><rprime|'>>>>|<row|<cell|>|<cell|<math|f<rsub|dir,iter><rsub|>\<circ\>f<rsub|dir>:<around*|{|i<rsub|direction>|}>
  \<times\> i<rsub|cell>\<rightarrow\><around*|{|i<rsub|cell><rprime|'>|}>>>>|<row|<cell|>|<cell|<math|f<rsub|map>\<circ\>f<rsub|dir>:
  g\<times\><around*|{|i<rsub|cell>|}>\<rightarrow\><around*|{|g<around*|(|i<rsub|cell>|)>|}>>>>|<row|<cell|Step
  1>|<cell|>>|<row|<cell|<em|def>>|<cell|<math|<around*|{|i<rsub|type>|}>>>>|<row|<cell|<em|list>>|<cell|<math|f<rsub|type>:
  i<rsub|direction>\<times\>i<rsub|cell>\<rightarrow\>i<rsub|type>><math|>>>|<row|<cell|>|<cell|<math|f<rsub|geom>:i<rsub|direction>\<times\>
  i<rsub|type>\<times\>i<rsub|cell>\<rightarrow\><around*|{|i<rsub|cell><rprime|'>|}>>>>|<row|<cell|Step
  2>|<cell|>>|<row|<cell|<em|def>>|<cell|<math|<around*|{|i<rsub|eqn>|}>,<around*|{|g<rsub|eqn>|}>>>>|<row|<cell|<em|list>>|<cell|<math|f<rsub|eqn>:i<rsub|type>\<times\>i<rsub|eqn>\<rightarrow\>g<rsub|eqn><around*|(|<around*|{|v<rsub|i,j>|\|>i\<in\><around*|{|i<rsub|cell><rprime|'>|}>,j\<in\><around*|{|i<rsub|var>|}>|)>>>>|<row|<cell|>|<cell|<math|f<rsub|var>:g<rsub|eqn>\<rightarrow\><around*|{|<around*|{|i<rsub|var>|}>,<around*|{|i<rsub|cell><rprime|'>|}>|}>>>>|<row|<cell|Step
  3>|<cell|>>|<row|<cell|>|<cell|<math|f<rsub|solver>:>
  <math|g<rsub|eqn>\<times\><around*|(|f<rsub|map>\<circ\>f<rsub|dir>|)>\<times\><around*|{|v|}><rsup|initial>\<rightarrow\><around*|{|v|}><rsup|final>>
  >>>>>

  If the above system is still two complex, we can understand the solving
  machine as a two-branched flow before we can get
  <math|g<rsub|eqn><around*|(|<around*|{|<around*|\<nobracket\>|v<rsub|i,j>|\|>i\<in\><around*|{|i<rsub|cell><rprime|'>|}>,j=i<rsub|var>|}>|)>>.In
  the first branch, the boundary type is identified from the index of cell
  and geometric direction, and then the function is obtained for our target
  equation. It can be presented as

  <\equation*>
    i<rsub|cell>\<times\>i<rsub|direction>\<rightarrow\>i<rsub|type>;i<rsub|type>\<times\>i<rsub|eqn>\<rightarrow\>g<rsub|eqn>
  </equation*>

  In the second branch, the index of elements is obtained for the variables
  that \ them should be applied for the evaluation process.

  <\equation*>
    i<rsub|direction>\<times\> i<rsub|type>\<times\>i<rsub|cell>\<rightarrow\><around*|{|i<rsub|cell><rprime|'>|}>\<rightarrow\><around*|{|<around*|\<nobracket\>|v<rsub|i,j>|\|>i\<in\><around*|{|i<rsub|cell><rprime|'>|}>,j\<in\><around*|{|i<rsub|var>|}>|}>
  </equation*>

  \;

  <strong|Conclusion>

  1. It is critical to treat numerical system as a set of elements and
  implement the solving scheme on the element level.\ 

  2. BC and upwind schemes are actually the same thing. They reflect the
  relation between some <em|control equations> (or functions) in an element
  with <em|variables in some other elements> in a <em|specific> <em|geometric
  direction>.

  3. Source and sink terms represent the status within the element which is
  irrelevant to other elements.

  <strong|Note>

  In actual practice, the data list to obtain the proper function should be
  sorted in the following order:

  Boundary type, direction index, equation index, cell index

  It violates the order in the table above. However, since the iterator could
  be easily implemented on cell index in many languages, such practice is
  important to save calculation cost.

  <tabular|<tformat|<table|<row|<cell|BCtype>|<cell|1>|<cell|2>|<cell|3>|<cell|4>|<cell|...>>|<row|<cell|>|<cell|cell(direction,
  cell_index_list)>|<cell|>|<cell|>|<cell|>|<cell|>>|<row|<cell|>|<cell|()>|<cell|>|<cell|>|<cell|>|<cell|>>>>>
</body>

<initial|<\collection>
</collection>>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|?>>
  </collection>
</references>