# needs to be defined by the location of this file
T_DIR_ABS=$(shell cd .. && pwd)
T_DIR=$(T_DIR_ABS)
#T_DIR=/home/schnizer/Devel/github/thor-scsi-lib-container
SRC_DIR=$(T_DIR)/external-repositories/
BIN_DIR=$(T_DIR)/bin/
WHEELS_DIR=$(T_DIR)/wheels
LOCAL_DIR=$(T_DIR)/local
BUILD_DIR=$(T_DIR)/build

NPROC=nproc
# one job per processor
N_JOBS=$(shell nproc)

APPTAINER=N_JOBS=$(N_JOBS) apptainer
TOUCH=touch
PIP_MODULE=pip
CMAKE=cmake

# soley built to be able to build the other containers
UBUNTU_BUILD_IMG=$(BIN_DIR)/ubuntu-build.sif
EPICS7_IMG=$(BIN_DIR)/epics7-pydevice.sif
PYTHON_IMG=$(BIN_DIR)/python-container.sif

CONTAINERS=$(PYTHON_IMG)                         \
           $(UBUNTU_BUILD_IMG)                   \
           $(EPICS7_IMG)                         \
           $(BIN_DIR)/bact-archiver-build.sif    \
           $(BIN_DIR)/thor-scsi-lib-as-twin.sif  \
           $(BIN_DIR)/bact-container.sif         \
           $(BIN_DIR)/mongo-container.sif

thor_scsi_DIR=$(SRC_DIR)/thor-scsi-lib/
thor_scsi_build_DIR=$(BUILD_DIR)/thor-scsi-lib/
gtpsa_DIR=$(SRC_DIR)/gtpsa-cpp/
gtpsa_build_DIR=$(BUILD_DIR)/gtpsa/


BACT_ARCHIVER_WHEEL_STAMP=$(BUILD_DIR)/bact-archiver-whl.stamp
PIP_WHEEL_STAMP=$(BUILD_DIR)/pip-whl.stamp
BACT2_BESSYII_WHEEL_STAMP=$(BUILD_DIR)/bact-bessyii-whl.stamp
GTPSA_BUILD_STAMP=$(BUILD_DIR)/gtpsa-build.stamp
GTPSA_WHEEL_STAMP=$(BUILD_DIR)/gtpsa-whl.stamp
THOR_SCSI_BUILD_STAMP=$(BUILD_DIR)/thor-scsi-build.stamp
THOR_SCSI_WHEEL_STAMP=$(BUILD_DIR)/thor-scsi-whl.stamp

STAMPS=$(BACT_ARCHIVER_WHEEL_STAMP) \
       $(PIP_ARCHIVER_WHEEL_STAMP)  \
       $(BACT2_BESSYII_WHEEL_STAMP) \
       $(GTPSA_BUILD_STAMP)         \
       $(GTPSA_WHEEL_STAMP)         \
       $(THOR_SCSI_BUILD_STAMP)     \
       $(THOR_SCSI_WHEEL_STAMP)

all : $(CONTAINERS)

wheels: $(PIP_WHEEL_STAMP)

distclean : clean
	$(RM) $(RMFLAGS) $(CONTAINERS)
	$(RM) $(RMFLAGS) $(STAMPS)

clean : clean_prebuilts clean_wheels clean_local

clean_prebuilts :
	$(RM) $(RMFLAGS) -r $(gtpsa_build_DIR)
	$(RM) $(RMFLAGS) -r $(thor_scsi_build_DIR)

clean_wheels :
	$(RM) $(RMFLAGS) $(WHEELS_DIR)/*.whl
	$(RM) $(RMFLAGS) $(WHEELS_DIR)/*.tar.gz

clean_local :
	$(RM) $(RMFLAGS) -r $(LOCAL_DIR)/bin
	$(RM) $(RMFLAGS) -r $(LOCAL_DIR)/lib
	$(RM) $(RMFLAGS) -r $(LOCAL_DIR)/include

$(BIN_DIR)/%.sif : %.sdef
	$(APPTAINER) build $@ $<


# ------------------------------------------------------------------------------
# containers depending on other containers or further downloads

$(BIN_DIR)/bact-archiver-build.sif : $(PIP_WHEEL_STAMP)         \
                                       bact-archiver-build.sdef \
                                       $(UBUNTU_BUILD_IMG)      \


$(BIN_DIR)/bact-container.sif : bact-container.sdef               \
                                  $(BIN_DIR)/python-container.sif \
                                  $(BACT_ARCHIVER_WHEEL_STAMP)    \
                                  $(BACT2_BESSYII_WHEEL_STAMP)    \
                                  $(PIP_WHEEL_STAMP)

$(BIN_DIR)/thor-scsi-lib-as-twin.sif : thor-scsi-lib-as-twin.sdef     \
                                         $(EPICS7_IMG)                \
                                         $(BACT2_BESSYII_WHEEL_STAMP) \
                                         $(GTPSA_WHEEL_STAMP)         \
                                         $(THOR_SCSI_WHEEL_STAMP)     \
                                         $(PIP_WHEEL_STAMP)


# ------------------------------------------------------------------------------
# download wheels

$(PIP_WHEEL_STAMP) : lists/bact_package_list.txt
	$(PYTHON_IMG) -m $(PIP_MODULE) download -r $< -d $(WHEELS_DIR) --check-build-dependencies \
	&& $(TOUCH) $@

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

#-----------------------------------------------------------------------------
# thor-scsi and gtpsa
# need to go to pyat ?

$(GTPSA_BUILD_STAMP) : $(EPICS7_IMG)
	(                                                  \
          cd $(gtpsa_DIR)                                  \
          && $(EPICS7_IMG) -c "mkdir -p $(gtpsa_build_DIR)"             \
          && $(EPICS7_IMG) -c "$(CMAKE) -B $(gtpsa_build_DIR) ."        \
          && $(EPICS7_IMG) -c "make -C $(gtpsa_build_DIR) -j $(N_JOBS)" \
          && $(EPICS7_IMG) -c "$(CMAKE) --install $(gtpsa_build_DIR) --prefix $(LOCAL_DIR)" \
        ) && $(TOUCH) $@

$(GTPSA_WHEEL_STAMP) : $(GTPSA_BUILD_STAMP) $(EPICS7_IMG)
	(                                                \
          cd $(gtpsa_DIR)/python                         \
	  && gtpsa_PREFIX=$(LOCAL_DIR) $(EPICS7_IMG) -c "python3 setup.py bdist_wheel -d $(WHEELS_DIR)" \
	) && $(TOUCH) $@


$(THOR_SCSI_BUILD_STAMP) : $(EPICS7_IMG) $(GTPSA_BUILD_STAMP)
	(                                                                      \
          cd $(thor_scsi_DIR)                                                  \
          && $(EPICS7_IMG) -c "mkdir -p $(thor_scsi_build_DIR)"                \
          && $(EPICS7_IMG) -c "gtpsa_DIR=$(LOCAL_DIR) $(CMAKE) -B $(thor_scsi_build_DIR) ."     \
          && $(EPICS7_IMG) -c "make -C  $(thor_scsi_build_DIR) -j $(N_JOBS)"                    \
          && $(EPICS7_IMG) -c "$(CMAKE) --install $(thor_scsi_build_DIR) --prefix $(LOCAL_DIR)" \
        ) && $(TOUCH) $@

$(THOR_SCSI_WHEEL_STAMP) : $(THOR_SCSI_BUILD_STAMP) $(EPICS7_IMG) $(GTPSA_WHEEL_STAMP)
	(                                                                          \
          cd $(thor_scsi_DIR)/python                                               \
	  && gtpsa_PREFIX=$(LOCAL_DIR) thor_scsi_PREFIX=$(LOCAL_DIR) $(EPICS7_IMG) -c "python3 setup.py bdist_wheel -d $(WHEELS_DIR)" \
	) && $(TOUCH) $@
