Runing beam based alignment measurement using the twin
======================================================


Short summary
-------------

The measurement script is started using e.g.

.. code:: shell

    singularity exec \
        --bind /etc/machine-id:/etc/machine-id,/run/user/:/run/user/ \
          bact-container.sif python3 \
	 /build/bact-bessyii-bluesky/scripts/measure_quad_response.py \
	--catalog-name="" \
	-m Q1M1D1R

This complex command is currently necessary so that the Qt-Toolkit will work.
The live plots use this tool kit. Then the plots are updated while the
script is executed. Use the option `-h` to see how to use this script.

Typically running this script as given above will either fail or not
show interesting results. An in detail description follows below.


A more realistic example
------------------------


Setup
~~~~~




Its recommended to open three separate terminals.

1. One terminal is used to run the model / twin as an epics input output controller (IOC)
2. A second terminal is used to monitor some of the model variables
3. A third terminal is used to execute the measurement script


Please change first into the `bin` directory in all these three terminals.


For starting twin see `start_twin.rst`_

.. _`start_twin.rst` : start_twin.rst


To see what is happening its helpful to monitor some of the epics variables.
To do that execute in the second terminal


Inspecting twin using EPICS command line tools
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: shell

    singularity exec thor-scsi-lib-as-twin.sif /bin/bash


So here we use the shell provided within the container. The epics command line utilites are found
in `/build/epics-base/bin/linux-x86_64/`. Let's shift the quadrupole `Q1m1D1R` by `0.3 mm`.
For that let's run the command

.. code:: shell

   /build/epics-base/bin/linux-x86_64/caput  Pierre:DT:Q1M1D1R:x:set 3e-4


You can see the reaction of the twin in the first terminal where the twin was started. You could
now inspect different properties of the "beam": e.g.

.. code:: shell

   /build/epics-base/bin/linux-x86_64/caget Pierre:DT:beam:orbit:x


The position names of the model are found in the vector

.. code:: shell

   /build/epics-base/bin/linux-x86_64/caget Pierre:DT:beam:names

A list of variables the twin exports are given in  `twin_variables.rst`_

.. _`twin_variables.rst` : twin_variables.rst



Preparing for running the script
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Now let's use the second shell so that we can see what is happening while the twin is running

.. code:: shell

   /build/epics-base/bin/linux-x86_64/camonitor              \
          Pierre:DT:PMUXZR:name                              \
          Pierre:DT:QSPAZR:set                               \
          Pierre:DT:Q1M1D1R:Cm:set Pierre:DT:Q1M1D1R:Cm:rdbk \
          Pierre:DT:Q1M1D1R:im:Imux                          \
          Pierre:DT:Q1M1D1R:im:I                             \
          Pierre:DT:Q1M1D1R:im:mux:active


Here we now monitor the variables:

* the device the muxer selected (1. line)
* the value the muxer power converter is set to (2.line)
* the K  value of the Q1M1D1R as set within the IOC and as
  reported back by the model (line 3)
* the *equivalent* current the main power converter had
  to be changed to achieve the same gradient in
  *this particular quadrupole* (line 4)
* the  *equivalent* current that would run through this
  quadrupole (line 5)
* if the muxer power converter is *considered* connected
  to this particular quadrupole


Running the script
~~~~~~~~~~~~~~~~~~

Now run the script as described in the beginning in the document

What you should see:

* each time the muxer power converter is changed (after every third run)
  the quadrupole current is updated (visible in the second terminal)
* The twin then swiftly calculates a new orbit
* this is read by the script and displayed in the terminal:
  please note that the upper row shows the orbit while the
  lower row shows the difference orbit (i.e. how much it differs
  from a reference orbit). This is not properly working yet
