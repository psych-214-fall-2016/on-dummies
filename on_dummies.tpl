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
sum of squares by $n - m$ where $m$ is the number of *independent columns in
the design matrix.  Specifically,* $m$ *is the `matrix rank`_ of the design* 
$\Xmat$.  $m$ can also be called the *degrees of freedom* consumed by the
design.*  $n - m$ *is the *degrees of freedom of the error*.

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

.. admonition:: Question

    What is the relationship of $\cvec^T (\Xmat^T \Xmat)^{-1} \cvec$ to $p$
    |--| the number of observations in each group?

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

        \cvec^T (\Xmat^T \Xmat)^{-1} \cvec = \frac{2}{p}

.. solution-replace-code

    """ What is the relationship of ``c.dot(npl.inv(X.T.dot(X)).dot(cvec)`` to
    ``p`` - the number of observations in each group?
    """

.. solution-end

.. admonition:: Question

    Now imagine your UCB and MIT are groups are not equal.  $n$ is constant,
    the number of students. Call $b$ the number of Berkeley students in the
    $n=10$, where $b \in [1, 2, ... 9]$.  Write the number of MIT students ad
    $n - b$.  Using your answer above, derive a formula for the result of
    $\cvec^T (\Xmat^T \Xmat)^{-1} \cvec$ in terms of $r$ and $n$. $\cvec$ is
    the contrast you chose above.  If all other things remain equal, such as
    the $\hat{\sigma^2}$ and $\cvec^T \bvec$, then what value of $r$ should
    you chose to give the largest value for your t statistic?

.. solution-start

    Answer: we now have:

    .. math::

        (\Xmat^T \Xmat)^{-1} =
        \begin{bmatrix}
        \frac{1}{r} 0 \\
        0 \frac{1}{n-r} \\
        \end{bmatrix}

    With contrast $c = [-1, 1]$ we get:

    .. math::

        \cvec^T (\Xmat^T \Xmat)^{-1} \cvec = \frac{1}{r} + \frac{1}{n-r}

    To investigate, we make a Python function returning the result for a given
    ``r`` and ``n``, and evalulate for the possible values of ``r``:

    .. nbplot::

        >>> def two_group_ct_ixtx_c(r, n):
        ...    return 1. / r + 1 / (n - r)
        ...
        >>> two_group_ct_ixtx_c(np.arange(1, 9), 10)

.. solution-code-replace

    """ Using your answer above, derive a formula for the result of
    ``c.dot(npl.inv(X.T.dot(X)).dot(c)``.  in terms of ``r`` and ``n``. ``c``
    is the contrast you chose above.  If all other things remain equal, such
    as the sigma estimate and the top half of the t statistic, then what value
    of ``r`` should you chose to give the largest value for your t statistic?
    """

.. solution-end


*********************************
Hypothesis testing: F-tests 
*********************************


T-test tests a linear combinaison of the $\beta$, they would test if the mean of the first group is greater than the mean of the second group ($\beta_1 - \beta_2$) or the opposite, but in any case these tests are *signed*. 

In many instance, we do not know the direction of the test. Or we have to test the influence of several regressors on the data. In this cases, an F-test is more appropriate. 

The simplest and generally most useful way of thinking of F test is to think as the test between two models: one which contains the regressor or factor that we want to test for (refered as the full model with design matrix $X$), and one which doesnt (the reduced model $X_0$). In the example above, what is our reduced model $X_0$ ?

The *reduced* model is the model here is simply a model where there is no difference between the group means: only the mean of the data is modelled, so, one column of $n$ values. 


To test whether the model containing two columns is better, we compute the difference between the estimation of the noise variance between the models (variance estimated with X versus variance estimated with X0), normalized by the estimation of the noise (residual) variance under the full model $X$. This is :

    .. math::

        \begin{eqnarray} 
        F_{\nu_1, \nu_2} & = & \frac{(\hat\epsilon_0^t \hat\epsilon_0 - \hat\epsilon^T\hat\epsilon)/ \nu_{1} }{\hat\epsilon^T\hat\epsilon/\nu_{2}} \\ 
        & = & \frac{(\textrm{SSR}(X_0) - \textrm{SSR}(X))/\nu_1}{\textrm{SSR}(X)/\nu_2}
        \end{eqnarray}


SSR here stands for "Sum of square of the residuals". 

What are ${\nu_1, \nu_2}$?   ${\nu_2}$ we have already encountered. This is the degrees of freedom of the *error*, that we have seen is $n - 2$. What is  ${\nu_1}$ ? It's something related. You remember that the degree of freedom of the residuals (the one we used to estimate the variance of the error) is $n-m$ with $n$ the number of observations, and $m$ the number of linearly independent columns in the design (the number of things to estimate). Here, we are looking at the difference between two design, and this degrees of freedom will simply be this number $m$ minus the number of linearly independent columns in $X_0$, here 1. 



.. admonition:: Question

    Make the alternative model $X_0$. Compute the degrees of freedom ${\nu_1}$. 
    Compute the extra sum of squares and the F statistics. How is it related to
    the t-statistics that you had above ?
    
.. solution-start

    Answer: we already know that $\nu_2$ == n-m

    You should get $\nu_1$ == 1: compute the rank of $X_0$ (this is one), rank of $X$
    (this is 2), hence the numerator of the F statistics is 1. 
    And the relation?  the F-statistics should be the square of the t-statistics.
        

.. solution-replace-code

    """ 
    Some solution code here
    """

.. solution-end






.. rubric:: Footnotes

.. [#col-vec] Assume the default that for any $\vec{v}$, $\vec{v}$ is a
   column vector, and therefore that $\vec{v}^T$ is a row vector.














