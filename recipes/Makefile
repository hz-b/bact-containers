#------------------------------------------------------------------------------
# makefile for building containers
#
# Authors: Pierre Schnizer <pierre.schnizer@helmholtz-berlin.de>
#          Waheedullah Sulaiman Khail <waheedullah.sulaiman_khail@helmholtz-berlin.de>
#
# The containers are built in the following manner:
#    1. containers are built, that contain the build environment
#    2. external prerequistes are built from external repositories.
#       a. epics-base
#       b. PyDevice
#    3. containers are built that typically will be used by users
#
# NB: this makefile needs GNU make to work
#------------------------------------------------------------------------------

# needs to be defined by the location of this file
T_DIR_ABS =$(shell cd $(CURDIR)/../ && pwd)
T_DIR=$(T_DIR_ABS)

# a hack ... should load a file if ab
# for datascc
ifeq ($(shell hostname), datascc)
    ifeq ($(shell id -u -n), schnizer)
        T_DIR=/home/schnizer/Devel/github/hz-b/bact-containers
    endif
endif

SRC_DIR=$(T_DIR)/external-repositories/
# containers will be put here
BIN_DIR=$(T_DIR)/bin/
DOWNLOAD_DIR=$(T_DIR)/downloads/
# python wheels are cached here
WHEELS_DIR=$(T_DIR)/wheels
LOCAL_DIR=$(T_DIR)/local
BUILD_DIR=$(T_DIR)/build

NPROC=nproc
# one job per processor
N_JOBS=$(shell nproc)

# does not always work with link
LN_S=cp

APPTAINER=N_JOBS=$(N_JOBS) apptainer
TOUCH=touch
PIP_MODULE=pip
CURL=curl
MKDIR=mkdir
TAR=tar

# soley built to be able to build the other containers
UBUNTU_BUILD_IMG=$(BIN_DIR)/ubuntu-build.sif
# a intermediate container: contains EPICS. Development will
# typically not impact EPICS. Thus final container build times are
# reduced given that these are stacked on this container
EPICS7_IMG=$(BIN_DIR)/epics7-pydevice.sif

# a container with python inside: used for pre download of wheels
# or building wheels locally.
PYTHON_IMG=$(BIN_DIR)/python-container.sif
BACT_IMG=$(BIN_DIR)/bact-container.sif

# Finally: the digital twin containers
# See below for a list of all build containers
DT_IMG=$(BIN_DIR)/pyat-as-twin.sif
DT_SOFTIOC_IMG=$(BIN_DIR)/pyat-as-twin-softioc.sif

# directories of external
epics_DIR=$(SRC_DIR)/epics-base/
pydevice_DIR=$(SRC_DIR)/PyDevice/
dt4acc_DIR=$(SRC_DIR)/dt4acc/
RELEASE_LOCAL=$(SRC_DIR)/RELEASE.local
CONFIG_SITE_LOCAL=$(SRC_DIR)/CONFIG_SITE.local

PYDEV_RELEASE_LOCAL=$(pydevice_DIR)/configure/RELEASE.local

DEBIAN_BULLSEYE_IMG=$(BIN_DIR)/debian_bullseye.sif
DEBIAN_BULLSEYE_KERNEL_RT=$(BIN_DIR)/debian_bullseye_kernel_rt.sif


CONTAINERS=$(PYTHON_IMG)                      \
           $(DT_SOFTIOC_IMG)                  \
           $(UBUNTU_BUILD_IMG)                \
           $(EPICS7_IMG)                      \
           $(BACT_IMG)                        \
           $(BIN_DIR)/bact-archiver-build.sif \
           $(BIN_DIR)/mongo-container.sif

# former twin based on PyDevice
# please notice: the branch of dt4cc must then match
# too
# see external_repositories
#           $(DT_IMG_MINIMAL)                     \

BACT_ARCHIVER_WHEEL_STAMP=$(BUILD_DIR)/bact-archiver-whl.stamp
PIP_WHEEL_DOWNLOAD_STAMP=$(BUILD_DIR)/pip-download-whl.stamp
PIP_WHEEL_STAMP=$(BUILD_DIR)/pip-whl.stamp
BACT2_BESSYII_WHEEL_STAMP=$(BUILD_DIR)/bact-bessyii-whl.stamp
EPICS_BUILD_STAMP=$(BUILD_DIR)/epics-built.stamp
PYDEVICE_BUILD_STAMP=$(BUILD_DIR)/pydevice-built.stamp

EPICS_UTILS=$(BUILD_DIR)/epics-utils.tar.gz
P4P_WHEEL_STAMP = $(BUILD_DIR)/p4p-whl.stamp

STAMPS=$(BACT_ARCHIVER_WHEEL_STAMP) \
       $(PIP_ARCHIVER_WHEEL_STAMP)  \
       $(PIP_WHEEL_DOWNLOAD_STAMP)  \
       $(PIP_WHEEL_STAMP)           \
       $(BACT2_BESSYII_WHEEL_STAMP) \
       $(P4P_WHEEL_STAMP)           \
       $(EPICS_BUILD_STAMP)         \
       $(PYDEVICE_BUILD_STAMP)

# ------------------------------------------------------------------------------


# Some dedicated entry points
all :  $(CONTAINERS)

twin : $(DT_IMG)

twin-minimal : $(DT_IMG_MINIMAL)

echo_t_dir :
	@echo $(CURDIR)

wheels: $(PIP_WHEEL_STAMP)

distclean : clean distclean_prebuilts
	$(RM) $(RMFLAGS) $(CONTAINERS)
	$(RM) $(RMFLAGS) $(STAMPS)

clean : clean_wheels clean_local clean_prebuilts

clean_wheels :
# first the stamp: if something goes wrong there would be an extra
# download not a failed built
	$(RM) $(RMFLAGS) $(BUILD_DIR)/pip-whl.stamp
	$(RM) $(RMFLAGS) $(WHEELS_DIR)/*.whl
	$(RM) $(RMFLAGS) $(WHEELS_DIR)/*.tar.gz

clean_local :
	$(RM) $(RMFLAGS) -r $(LOCAL_DIR)/bin
	$(RM) $(RMFLAGS) -r $(LOCAL_DIR)/lib
	$(RM) $(RMFLAGS) -r $(LOCAL_DIR)/include

clean_prebuilts :
	$(RM) $(RMFLAGS) $(EPICS_BUILD_STAMP)
	@make -C $(epics_DIR) clean
	$(RM) $(RMFLAGS) $(PYDEVICE_BUILD_STAMP)
	make -C $(pydevice_DIR) clean

distclean_prebuilts :
	$(RM) $(RMFLAGS) $(EPICS_BUILD_STAMP)
	@make  -C $(epics_DIR) distclean
	$(RM) $(RMFLAGS) $(PYDEVICE_BUILD_STAMP)
	@make  -C $(pyepics_DIR) distclean


# ------------------------------------------------------------------------------
# the actual work horse

$(BIN_DIR)/%.sif : %.sdef
	$(APPTAINER) build $@ $<


# ------------------------------------------------------------------------------
# containers depending on other containers or further downloads
$(EPICS7_IMG) : $(UBUNTU_BUILD_IMG) $(EPICS_BUILD_STAMP) $(PYDEVICE_BUILD_STAMP) epics7-pydevice.sdef

$(DT_SOFTIOC_IMG) : $(PIP_WHEEL_STAMP) $(P4P_WHEEL_STAMP) $(EPICS_UTILS) $(PYTHON_IMG)

$(DT_IMG_MINIMAL) : $(PIP_WHEEL_STAMP) $(UBUNTU_BUILD_IMG)

$(BACT_IMG) : $(PYTHON_IMG) $(PIP_WHEEL_STAMP)


# $(BIN_DIR)/bact-archiver-build.sif : $(PIP_WHEEL_STAMP)        \
#                                       bact-archiver-build.sdef \
#                                       $(UBUNTU_BUILD_IMG)      \


$(DEBIAN_BULLSEYE_KERNEL_RT) : $(DEBIAN_BULLSEYE_IMG)

# ------------------------------------------------------------------------------
# download wheels

$(PIP_WHEEL_DOWNLOAD_STAMP) : $(T_DIR)/recipes/lists/bact_package_list.txt
	( cd $(T_DIR) \
              && $(PYTHON_IMG) -m $(PIP_MODULE) download -q -r $^ \
                  -d wheels/ --check-build-dependencies           \
              && $(TOUCH) $@ \
       )

# prebuild wheels: so that g++ does not need to be included in last
# build

$(P4P_WHEEL_STAMP) : $(UBUNTU_BUILD_IMG)
	( cd $(T_DIR)/ \
              && $(UBUNTU_BUILD_IMG) -c 'python3 -m $(PIP_MODULE) wheel -w wheels/ external-repositories/p4p/' \
              && $(TOUCH) $@ \
        )

$(PIP_WHEEL_STAMP) : $(PIP_WHEEL_DOWNLOAD_STAMP) $(UBUNTU_BUILD_IMG)
	( cd $(T_DIR) \
              && $(UBUNTU_BUILD_IMG) -c 'python3 -m $(PIP_MODULE) wheel -w wheels/ softIoc' \
              && $(TOUCH) $@ \
        )


# ------------------------------------------------------------
# build epics and the components dependent on it


$(PYDEVICE_BUILD_STAMP) : $(EPICS_BUILD_STAMP) $(PYDEV_RELEASE_LOCAL)
	$(UBUNTU_BUILD_IMG) -c "make -C $(pydevice_DIR) -j $(N_JOBS)" \
         && $(TOUCH) $@

$(PYDEV_RELEASE_LOCAL) : $(RELEASE_LOCAL)
	$(LN_S) $^ $@

$(EPICS_UTILS) : $(EPICS_BUILD_STAMP)
	(\
               cd $(T_DIR) \
            && ( $(MKDIR) -p $(BUILD_DIR)/epics/ )                               \
            && ( $(TAR) -cf- -C external-repositories/epics-base/ dbd/           \
                     bin/linux-x86_64/ lib/linux-x86_64/                         \
                   | $(TAR) -xf- -C $(BUILD_DIR)/epics/ )                        \
	    && mv $(BUILD_DIR)/epics/bin/linux-x86_64/* $(BUILD_DIR)/epics/bin/  \
	    && mv $(BUILD_DIR)/epics/lib/linux-x86_64/* $(BUILD_DIR)/epics/lib/  \
            && rmdir $(BUILD_DIR)/epics/lib/linux-x86_64/                        \
            && rmdir $(BUILD_DIR)/epics/bin/linux-x86_64/                        \
            && ( find $(BUILD_DIR)/epics/lib -name '*.a'  | xargs rm    )        \
            && ( find $(BUILD_DIR)/epics/bin -name '*.pl' | xargs rm    )        \
            && ( find $(BUILD_DIR)/epics/bin -name '*.py' | xargs rm    )        \
            && ( find $(BUILD_DIR)/epics/bin -name 'S99*' | xargs rm    )        \
            && ( find $(BUILD_DIR)/epics/lib -type f      | xargs strip )        \
            && ( find $(BUILD_DIR)/epics/bin -type f -a  ! -name '*.service' | xargs strip ) \
	    &&  $(TAR) -zcf $@ -C $(BUILD_DIR) epics/                            \
        )


$(EPICS_BUILD_STAMP) : $(UBUNTU_BUILD_IMG)
	$(UBUNTU_BUILD_IMG) -c "make -C $(epics_DIR) -j $(N_JOBS)" \
        && $(TOUCH) $@

RELEASE_FILES : $(RELEASE_LOCAL) $(CONFIG_SITE_LOCAL)

$(RELEASE_LOCAL) :
	@echo "Creating $(RELEASE_LOCAL)"
	@echo "# Release.local ... reflecting local build" >  $@
	@echo "HOME_DEVEL=$(SRC_DIR)"                      >> $@
	@echo "EPICS_BASE=$(epics_DIR)"                    >> $@
	@echo "PYDEVICE=$(pydevice_DIR)"                   >> $@
	@echo "#EOF"                                       >> $@


$(CONFIG_SITE_LOCAL) :
	@echo "Creating $(CONFIG_SITE_LOCAL)"
	@echo "# configuring local site                  " >  $@
	@echo "# STATIC_BUILD=YES"                         >> $@
	@echo "#EOF"                                       >> $@

#------------------------------------------------------------
# bact packages to wheels
# bact-archiver
# where is the src placed ?
BACT_ARCHIVER_DIR=$(SRC_DIR)/bact-archiver/
BACT_ARCHIVER_BUILD_IMG=$(BIN_DIR)/bact-archiver-build.sif

$(BACT_ARCHIVER_WHEEL_STAMP) : $(UBUNTU_BUILD_IMG)
	( echo $(T_DIR_ABS);                                               \
          cd $(BACT_ARCHIVER_DIR)                                          \
          && $(UBUNTU_BUILD_IMG) -c "python3 setup.py build_proto_c bdist_wheel -d $(WHEELS_DIR)" \
        ) && $(TOUCH) $@


# bact2-bessyii to avoid entering the password
BACT2_BESSYII_DIR=$(SRC_DIR)/bact2_bessyii/

$(BACT2_BESSYII_WHEEL_STAMP) : $(UBUNTU_BUILD_IMG)
	( echo $(T_DIR_ABS);                                                  \
          cd $(BACT2_BESSYII_DIR)                                             \
          && $(BACT_ARCHIVER_BUILD_IMG) setup.py bdist_wheel -d $(WHEELS_DIR) \
        ) && $(TOUCH) $@
