.. vim: ft=rst

####################################
Modeling groups with dummy variables
####################################

****************************
Introduction and definitions
****************************

.. nbplot::

    >>> #: Import numerical and plotting libraries
    >>> import numpy as np
    >>> # Print to four digits of precision
    >>> np.set_printoptions(precision=4, suppress=True)
    >>> import numpy.linalg as npl
    >>> import matplotlib.pyplot as plt

We return to the psychopathy of students from Berkeley and MIT.

We get psychopathy questionnaire scores from another set of 5 students from
Berkeley:

.. nbplot::

    >>> #: Psychopathy scores from UCB students
    >>> ucb_psycho = np.array([2.9277, 9.7348, 12.1932, 12.2576, 5.4834])

We do the same for another set of 5 students from MIT:

.. nbplot::

    >>> #: Psychopathy scores from MIT students
    >>> mit_psycho = np.array([7.2937, 11.1465, 13.5204, 15.053, 12.6863])

Concatenate these into a ``psychopathy`` vector:

.. nbplot::

    >>> #: Concatenate UCB and MIT student scores
    >>> psychopathy = np.concatenate((ucb_psycho, mit_psycho))

We will use the general linear model to a two-level (UCB, MIT) single factor
(student college) analysis of variance on these data.

Our model is that the Berkeley student data are drawn from some distribution
with a mean value that is characteristic for Berkeley: $y_i = \mu_{Berkeley} +
e_i$ where $i$ corresponds to a student from Berkeley.  There is also a
characteristic but possibly different mean value for MIT: $\mu_{MIT}$:

.. math::

    \newcommand{\yvec}{\vec{y}}
    \newcommand{\xvec}{\vec{x}}
    \newcommand{\evec}{\vec{\varepsilon}}
    \newcommand{Xmat}{\boldsymbol X}
    \newcommand{\bvec}{\vec{\beta}}
    \newcommand{\bhat}{\hat{\bvec}}
    \newcommand{\yhat}{\hat{\yvec}}

    y_i = \mu_{Berkeley} + e_i  \space\mbox{if}\space 1 \le i \le 5

    y_i = \mu_{MIT} + e_i \space\mbox{if}\space 6 \le i \le 10

We saw in `introduction to the general linear model`_ that we can encode this
group membership with dummy variables.  There is one dummy variable for each
group.  The dummy variables are *indicator* variables, in that they have 1 in
the row corresponding to observations in the group, and zero elsewhere.

We will compile[ a design matrix $\Xmat$ and use the matrix formulation of the
general linear model to do estimation and testing:

.. math::

   \yvec = \Xmat \bvec + \evec

************
ANOVA design
************

Create the design matrix for this ANOVA, with dummy variables corresponding to the UCB and MIT student groups:

.. nbplot::

    >>> #- Create design matrix for UCB / MIT ANOVA
    >>> n = len(psychopathy)
    >>> X = np.zeros((n, 2))
    >>> X[:5, 0] = 1  # UCB indicator
    >>> X[5:, 1] = 1  # MIT indicator
    >>> X
    array([[ 1.,  0.],
           [ 1.,  0.],
           [ 1.,  0.],
           [ 1.,  0.],
           [ 1.,  0.],
           [ 0.,  1.],
           [ 0.,  1.],
           [ 0.,  1.],
           [ 0.,  1.],
           [ 0.,  1.]])

Remember that, when $\Xmat^T \Xmat$ is invertible, our least-squares parameter
estimates $\bhat$ are given by:

.. math::

    \bhat = (\Xmat^T \Xmat)^{-1} \Xmat^T \yvec

First calculate $\Xmat^T \Xmat$. Are the columns of this design orthogonal?

.. nbplot::

    >>> #- Calculate transpose of design with itself.
    >>> #- Are the design columns orthogonal?
    >>> X.T.dot(X)
    array([[ 5.,  0.],
           [ 0.,  5.]])

Calculate the inverse of $\Xmat^T \Xmat$.

.. nbplot::

    >>> #- Calculate inverse of transpose of design with itself.
    >>> iXtX = npl.inv(X.T.dot(X))
    >>> iXtX
    array([[ 0.2,  0. ],
           [ 0. ,  0.2]])

.. admonition:: Question

    What is the relationship of the values on the diagonal of $(\Xmat^T
    \Xmat)^{-1}$ and the number of values in each group?

.. solution-start

    Call the number of students in each group $q$.  The diagonals of $\Xmat^T
    \Xmat$ are, for each column $\vec{w}$: $\sum_i {w_i^2}$, which reduces to
    $q=5$, the number of ones in each column.  Because $\Xmat^T \Xmat$ is
    diagonal, the inverse is:

    .. math::

        (\Xmat^T \Xmat)^{-1} =
        \begin{bmatrix}
        \frac{1}{p} 0 \\
        0 \frac{1}{p} \\
        \end{bmatrix}

    The diagonal values in $(\Xmat^T \Xmat)^{-1}$ are therefore the reciprocal
    of the number of values in each group.

.. solution-replace-code

    """ What is the relationship of the values on the diagonal of the inverse
    of X.T.dot(X) and the number of values in each group?

    """

.. solution-end

Now calculate the second half of $(\Xmat^T \Xmat)^{-1} \Xmat^T \yvec$:
$\vec{p} = \Xmat^T \yvec$.

.. nbplot::

    >>> #- Calculate transpose of design matrix multiplied by data
    >>> XtY = X.T.dot(psychopathy)

.. admonition:: Question

    What is the relationship of each element in this
    vector to the values of ``ucb_psycho`` and ``mit_psycho``?

.. solution-start

    The dot product of the dummy variables resolves to the sum of the values
    for which the dummy vector value is 1 (and therefore not 0). Therefore the
    values are just the sums of the values in ``ucb_psycho`` and
    ``mit_psycho`` respectively:

    >>> XtY
    array([ 42.5967,  59.6999])
    >>> # The apparent difference is just in the display of the numbers
    >>> np.sum(psychopathy[:5])
    42.5966999...
    >>> np.sum(psychopathy[5:])
    59.6999

.. solution-replace-code

    """
    What is the relationship of each element in this
    vector to the values of ``ucb_psycho`` and ``mit_psycho``?
    """

.. solution-end

Now calculate $\bhat$ using $(\Xmat^T \Xmat)^{-1} \Xmat^T \yvec$:

.. nbplot::

    >>> #- Calculate beta vector
    >>> B = iXtX.dot(XtY)
    >>> B
    array([  8.5193,  11.94  ])

Compare this vector to the means of the values in ``ucb_psycho`` and
``mit_psycho``:

.. nbplot::

    >>> #- Compare beta vector to means of each group
    >>> ucb_psycho.mean()
    8.51933...
    >>> mit_psycho.mean()
    11.93998...

.. admonition:: Question

    Using your knowledge of the parts of $(\Xmat^T \Xmat)^{-1} \Xmat^T \yvec$,
    explain the relationship of the values in $\bhat$ to the means of
    ``ucb_psycho`` and ``mit_psycho``.

.. solution-start

    We found that $\Xmat^T \yvec$ contains the sums for ``ucb_psych`` and
    ``mit_psycho`` respectively.  $(\Xmat^T \Xmat)^{-1}$ is diagonal with
    entries $\frac{1}{q}$ where $q = 5$ is the number of observations in each
    group.  Therefore the entries in $\bhat$ are:

    .. math::

        \frac{1}{q} \sum_i{v_i}

    for each vector $\vec{v}$ ``ucb_psycho``, ``mit_psycho``, which is also
    the formula for the mean.

.. solution-replace-code

    r""" Using your knowledge of the parts of (X.T X)^{-1} X y, explain the
    relationship of the values in $\bhat$ to the means of of ``ucb_psycho``
    and ``mit_psycho``.

    """

.. solution-end

*********************************
Hypothesis testing with contrasts
*********************************

Remember the student's t statistic from the general linear model [#col-vec]_:

.. math::

    \newcommand{\cvec}{\vec{c}}
    t = \frac{\cvec^T \bhat}
    {\sqrt{\hat{\sigma}^2 \cvec^T (\Xmat^T \Xmat)^+ \cvec}}

Let's consider the top half of the t statistic, $c^T \bhat$.

Our hypothesis is that the mean psychopathy score for MIT students,
$\mu_{MIT}$, is higher than the mean psychopathy score for Berkeley students,
$\mu_{Berkeley}$.  What contrast vector $\cvec$ do we need to apply to $\bhat$
to express the difference between these means?  Apply this contrast vector to
$\bhat$ to get the top half of the t statistic?

.. nbplot::

    >>> #- Contrast vector to express difference between UCB and MIT
    >>> #- Resulting value will be high and positive when MIT students have
    >>> #- higher psychopathy scores than UCB students
    >>> c = np.array([-1, 1])
    >>> top_of_t = c.dot(B)
    >>> top_of_t
    3.42064...

Now the bottom half of the t statistic.  Remember this is
$\sqrt{\hat{\sigma}^2 \cvec^T (\Xmat^T \Xmat)^+ \cvec}$.

First we generate $\hat{\sigma^2}$ from the residuals of the model.

Calculate the fitted values and the residuals given the $\bhat$ that you have
already.

.. nbplot::

    >>> #- Calculate the fitted and residual values
    >>> fitted = X.dot(B)
    >>> residuals = psychopathy - fitted

Remember from `worked example of GLM` that we want an unbiased estimator for
$\sigma^2$, and therefore $\sigma$.  For the case of a single regressor, this
involved dividing the sum of squares of the residuals by $n - 1$ where $n$ is
the number of rows in the design.  Now we can generalize this $n - 1$ measure
to designs with more than one column.  The general rule is that we divide the
sum of squares by $n - m$ where $m$ is the number of *independent$ columns in
the design matrix.  Specifically, $m$ is the `matrix rank`_ of the design
$\Xmat$.  $m$ can also be called the *degrees of freedom* consumed by the
design.  $n - m$ is the *degrees of freedom of the error*.

.. nbplot::

    >>> #- Calculate the degrees of freedom consumed by the design
    >>> m = npl.matrix_rank(X)
    >>> #- Calculated the degrees of freedom of the error
    >>> df_error = n - m
    >>> df_error
    8

Calculate the unbiased *variance* estimate $\hat{\sigma^2}$ by dividing the
sums of squares of the residuals by the degrees of freedom of the error.

.. nbplot::

    >>> #- Calculate the unbiased variance estimate
    >>> var_hat = np.sum(residuals ** 2) / df_error
    >>> var_hat
    13.04946...

Now the calculate second part of the t statistic denominator,  $\cvec^T (\Xmat^T
\Xmat)^+ \cvec$. You already know that $\Xmat^T \Xmat$ is invertible, and you
have its inverse above, so you can use the inverse instead of the more general
pseudo-inverse.

.. nbplot::

    >>> #- Calculate c (X.T X) c.T
    >>> c_iXtX_ct = c.dot(npl.inv(X.T.dot(X))).dot(c)
    >>> c_iXtX_ct
    0.40000...

For extra points:

.. admonition:: Question

    What is the relationship of $\cvec^T (\Xmat^T \Xmat)^{-1} \cvec$ to the
    number of observations in each group?

.. solution-start

    Answer: we already know that:

    .. math::

        (\Xmat^T \Xmat)^{-1} =
        \begin{bmatrix}
        \frac{1}{p} 0 \\
        0 \frac{1}{p} \\
        \end{bmatrix}

    With contrast $c = [-1, 1]$ we get:

    .. math::

        \cvec^T (\Xmat^T \Xmat)^{-1} \cvec = 

.. solution-end

.. rubric:: Footnotes

.. [#col-vec] Assume the default that for any $\vec{v}$, $\vec{v}$ is a
   column vector, and therefore that $\vec{v}^T$ is a column vector.

