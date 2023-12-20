Variables used or exported by the twin
======================================

It is assumed that the twin was started with the prefix *Pierre:DT*.
This is the default. If the dimension of the variable was chosen
by the twin the dimension will be the corresponding plane
SI unit (e.g. `m` for a distance instead of using `mm`)


Location names of the elements
------------------------------

The location names of the elements are given by

* `Pierre:DT:beam:names`


Orbit
-----

The orbit can be inspected using

* `Pierre:DT:beam:orbit:x`
* `Pierre:DT:beam:orbit:y`

for the x and y plane. The units of these variables are `m`.

The variable

* `Pierre:DT:beam:orbit:eps`

allows specfifing the precision that the orbit finder shall use.
The variable

* `Pierre:DT:beam:orbit:found`

will be true, if an orbit was found. It can be false if

* an orbit is currently calculated,
* the orbit finder did not find an orbit.


The fixed point the orbit finder found is given by

* `Pierre:DT:beam:orbit:fixed_point`


Twiss Parameters and working point
----------------------------------

The Twiss parameters are given in the variables

* `Pierre:DT:beam:alpha:x`
* `Pierre:DT:beam:alpha:y`
* `Pierre:DT:beam:beta:x`
* `Pierre:DT:beam:beta:y`
* `Pierre:DT:beam:nu:x`
* `Pierre:DT:beam:nu:y`


The working point can be inspected using

* `Pierre:DT:beam:working_point:x`
* `Pierre:DT:beam:working_point:y`

for the Floquet coordinates. Its fractional contribution is given
by

* `Pierre:DT:beam:working_point:frac_x`
* `Pierre:DT:beam:working_point:frac_y`

The reading as provided by the tune measurement of the BESSY II
machine  is given by

* `Pierre:DT:TUNEZR:rdH`
* `Pierre:DT:TUNEZR:rdV`

Magnet strength
---------------

The strength of each magnet can be inspected. It is illustrated for
the magnet `Q1M1D1R` below

* `Pierre:DT:Q1M1D1R:Cm:set` value the twin is set to
* `Pierre:DT:Q1M1D1R:Cm:rdbk` the value that the calculation engine uses.

These both values should be the same except when a value change is executed.

The following values below are not considered as part of the API, but can
be useful for inpection

* `Pierre:DT:Q1M1D1R:im:I` is the equivalent current: typically this is
  the same current as the current the power converter the magnet is
  hooked up to.
* `Pierre:DT:Q1M1D1R:im:dItest` allows to apply a current correction
  to this magnet. This value is set to 0 by default.

* `Pierre:DT:Q1M1D1R:im:Imux` reflects the *equivalent* current the
   muxer applies to the magnet: i.e. it is the current the muxer
   would need to apply if it is directly feeding its current to
   the main coil windings of this particular magnet.




Moving magnets in the twin
--------------------------

Moving magnets in the twin is quite easier than in the real machine.
Just apply the offset (in Meters) to the corresponding magnet

So for the magnet Q1M1D1R this would be the variables

* for the x plane:

  * `Pierre:DT:Q1M1D1R:x:set`:
      This allows setting the offset of this magnet.

  * `Pierre:DT:Q1M1D1R:x:rdbk`
      This allows inspecting which offset the magnet has in the model.

* for the y plane:

  * `Pierre:DT:Q1M1D1R:y:set`
  * `Pierre:DT:Q1M1D1R:y:rdbk`

* for the roll:

  * `Pierre:DT:Q1M1D1R:roll:set`
  * `Pierre:DT:Q1M1D1R:roll:rdbk`

.. todo:: check the dimension of the roll. It should be radians


**NB**: please do not apply a offset shift of roughly more than 0.3 mm
for a quadrupole. The orbit finder can be expected to fail to
find an orbit. Then all further calculations will be invalid.

The offsets are currently implemented for all quadrupoles.


Inspecting the twin itself
--------------------------

The twin itself provides some variables that allows inspecting
interals. These variables are not conisdered as part of tHe API and
are subject to change.

The time of calculation for orbit and twiss are given in

* `Pierre:DT:beam:orbit:calc_time`
* `Pierre:DT:beam:twiss:calc_time`


The following variables show if the twin is doing calculations.

* `Pierre:DT:dt:calcs`
* `Pierre:DT:dt:delayed-calcs`

Twiss and orbit calculations are delayed by a little extra time: e.g.
setting a lot of values to many different magnets can be performed before
a new orbit or twiss function is calculated.
