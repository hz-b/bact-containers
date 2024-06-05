# needs to be defined by the location of this file
T_DIR_ABS =$(shell cd $(CURDIR)/../ && pwd)
T_DIR=$(T_DIR_ABS)

# for datascc
ifeq ($(shell hostname), 'datascc')
    ifeq ($(shell id -u -n), 'schnizer')
        T_DIR=/home/schnizer/Devel/github/hz-b/bact-containers
    endif
endif

SRC_DIR=$(T_DIR)/external-repositories/
# containers will be put here
BIN_DIR=$(T_DIR)/bin/
# python wheels are cached here
WHEELS_DIR=$(T_DIR)/wheels
LOCAL_DIR=$(T_DIR)/local
BUILD_DIR=$(T_DIR)/build

NPROC=nproc
# one job per processor
N_JOBS=$(shell nproc)

APPTAINER=N_JOBS=$(N_JOBS) apptainer
TOUCH=touch
PIP_MODULE=pip

# does not always work with link
LN_S=cp

# soley built to be able to build the other containers
UBUNTU_BUILD_IMG=$(BIN_DIR)/ubuntu-build.sif
EPICS7_IMG=$(BIN_DIR)/epics7-pydevice.sif
PYTHON_IMG=$(BIN_DIR)/python-container.sif
DT_IMG=$(BIN_DIR)/pyat-as-twin.sif
DT_IMG_MINIMAL=$(BIN_DIR)/pyat-as-twin-minimal.sif

epics_DIR=$(SRC_DIR)/epics-base/
pydevice_DIR=$(SRC_DIR)/PyDevice/
dt4acc_DIR=$(SRC_DIR)/dt4acc/
RELEASE_LOCAL=$(SRC_DIR)/RELEASE.local
CONFIG_SITE_LOCAL=$(SRC_DIR)/CONFIG_SITE.local

PYDEV_RELEASE_LOCAL=$(pydevice_DIR)/configure/RELEASE.local

CONTAINERS=$(PYTHON_IMG)                         \
           $(UBUNTU_BUILD_IMG)                   \
           $(EPICS7_IMG)                         \
           $(DT_IMG)                             \
           $(DT_IMG_MINIMAL)                     \
           $(BIN_DIR)/bact-archiver-build.sif    \
           $(BIN_DIR)/bact-container.sif         \
           $(BIN_DIR)/mongo-container.sif


BACT_ARCHIVER_WHEEL_STAMP=$(BUILD_DIR)/bact-archiver-whl.stamp
PIP_WHEEL_STAMP=$(BUILD_DIR)/pip-whl.stamp
BACT2_BESSYII_WHEEL_STAMP=$(BUILD_DIR)/bact-bessyii-whl.stamp
EPICS_BUILD_STAMP=$(BUILD_DIR)/epics-built.stamp
PYDEVICE_BUILD_STAMP=$(BUILD_DIR)/pydevice-built.stamp
DT4ACC_BUILD_STAMP=$(BUILD_DIR)/dt4acc-built.stamp

STAMPS=$(BACT_ARCHIVER_WHEEL_STAMP) \
       $(PIP_ARCHIVER_WHEEL_STAMP)  \
       $(BACT2_BESSYII_WHEEL_STAMP) \
       $(EPICS_BUILD_STAMP)         \
       $(PYDEVICE_BUILD_STAMP)

# Some dedicated entry points

all : echo_t_dir $(CONTAINERS)

twin : $(DT_IMG)

twin-minimal : $(DT_IMG_MINIMAL)

echo_t_dir :
	@echo $(CURDIR)

wheels: $(PIP_WHEEL_STAMP)

distclean : clean
	$(RM) $(RMFLAGS) $(CONTAINERS)
	$(RM) $(RMFLAGS) $(STAMPS)

clean : clean_wheels clean_local clean_wheels

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
	@make clean -C $(epics_DIR)
	$(RM) $(RMFLAGS) $(PYDEVICE_BUILD_STAMP)
	@make clean -C $(pydevice_DIR)


$(BIN_DIR)/%.sif : %.sdef
	$(APPTAINER) build $@ $<


# ------------------------------------------------------------------------------
# containers depending on other containers or further downloads

$(DT_IMG) : $(DT4ACC_BUILD_STAMP) $(EPICS7_IMG)

$(DT_IMG_MINIMAL) : $(DT4ACC_BUILD_STAMP)

$(EPICS7_IMG) : $(EPICS_BUILD_STAMP) $(PYDEVICE_BUILD_STAMP) epics7-pydevice.sdef


$(BIN_DIR)/bact-archiver-build.sif : $(PIP_WHEEL_STAMP)         \
                                       bact-archiver-build.sdef \
                                       $(UBUNTU_BUILD_IMG)      \


$(BIN_DIR)/bact-container.sif : bact-container.sdef               \
                                  $(BIN_DIR)/python-container.sif \
                                  $(BACT_ARCHIVER_WHEEL_STAMP)    \
                                  $(BACT2_BESSYII_WHEEL_STAMP)    \
                                  $(PIP_WHEEL_STAMP)

# ------------------------------------------------------------------------------
# download wheels

$(PIP_WHEEL_STAMP) : $(T_DIR)/recipes/lists/bact_package_list.txt
	( cd $(T_DIR) \
              && $(PYTHON_IMG) -m $(PIP_MODULE) download -q -r $^ \
                  -d wheels/ --check-build-dependencies \
              && $(TOUCH) $@ \
       )

# ------------------------------------------------------------
# build epics

$(DT4ACC_BUILD_STAMP) : $(PYDEVICE_BUILD_STAMP) $(CONFIG_SITE_LOCAL)
	$(UBUNTU_BUILD_IMG) -c "make -C $(dt4acc_DIR) -j $(N_JOBS)" \
         && $(TOUCH) $@

$(PYDEVICE_BUILD_STAMP) : $(EPICS_BUILD_STAMP) $(UBUNTU_BUILD_IMG) $(PYDEV_RELEASE_LOCAL)
	$(UBUNTU_BUILD_IMG) -c "make -C $(pydevice_DIR) -j $(N_JOBS)" \
         && $(TOUCH) $@

$(PYDEV_RELEASE_LOCAL) : $(RELEASE_LOCAL)
	$(LN_S) $^ $@

$(EPICS_BUILD_STAMP) : $(UBUNTU_BUILD_IMG)
	$(UBUNTU_BUILD_IMG) -c "make -C $(epics_DIR) -j $(N_JOBS)" \
        && $(TOUCH) $@


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
	@echo "STATIC_BUILD=YES"                           >> $@
	@echo "#EOF"                                       >> $@

#------------------------------------------------------------
# bact packages to wheels
# bact-archiver
# where is the src placed ?
BACT_ARCHIVER_DIR=$(SRC_DIR)/bact-archiver/
BACT_ARCHIVER_BUILD_IMG=$(BIN_DIR)/bact-archiver-build.sif

$(BACT_ARCHIVER_WHEEL_STAMP) : $(BACT_ARCHIVER_BUILD_IMG)
	( echo $(T_DIR_ABS);                                               \
          cd $(BACT_ARCHIVER_DIR)                                          \
          && $(BACT_ARCHIVER_BUILD_IMG) setup.py build_proto_c bdist_wheel -d $(WHEELS_DIR) \
        ) && $(TOUCH) $@


# bact2-bessyii to avoid entering the password
BACT2_BESSYII_DIR=$(SRC_DIR)/bact2_bessyii/

$(BACT2_BESSYII_WHEEL_STAMP) : $(BACT_ARCHIVER_BUILD_IMG)
	( echo $(T_DIR_ABS);                                                  \
          cd $(BACT2_BESSYII_DIR)                                             \
          && $(BACT_ARCHIVER_BUILD_IMG) setup.py bdist_wheel -d $(WHEELS_DIR) \
        ) && $(TOUCH) $@
