bact-containers
===============

Recipies for building containers containing bact or other HZB software packages

Cloning the repository and required external repositories
---------------------------------------------------------

* please clone the repository e.g.

.. code:: shell

    git clone https://github.com/hz-b/bact-containers.git


Please install the external respositories this one depends on.

.. code:: shell

   git submodule update --init --recursive


This will checkout private repositories next to repositories
which require large downloads.

HowTo build the containers
--------------------------

* change into directory:


.. code:: shell

   cd recipies



* then type

.. code:: shell

   nice -15 make


please note that make will use `nproc` to find out how many cores
your machine will provide. it will use all of them. (Therfore I
suggest to use nice, so that your interactive work is not
impacted too much).

Running some examples
---------------------

have a look into the `doc`_ directory. Instructions are provided there.

.. _`doc` : doc


BESSY II specifics for container
--------------------------------

Have a look to `BESSYII_specifics`_

.. _`BESSYII_specifics` : doc/bessyii_specifics.rst
