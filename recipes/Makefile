# needs to be defined by the location of this file
T_DIR_ABS=$(shell cd .. && pwd)
T_DIR=$(T_DIR_ABS)
#T_DIR=/home/schnizer/Devel/github/thor-scsi-lib-container
BUILD_DIR=$(T_DIR)/build/
SRC_DIR=$(T_DIR)/src/
APPTAINER=apptainer
TOUCH=touch
PIP3=pip3
WHEELS_DIR=$(T_DIR)/wheels

# soley build to be able to build the other containers
UBUNTU_BUILD_IMG=$(BUILD_DIR)/ubuntu-build.sif

CONTAINERS=$(BUILD_DIR)/python-container.sif       \
	   $(UBUNTU_BUILD_IMG)                     \
	   $(BUILD_DIR)/bact-archiver-build.sif    \
           $(BUILD_DIR)/thor-scsi-lib-as-twin.sif  \
	   $(BUILD_DIR)/bact-container.sif

BACT_ARCHIVER_WHEEL_STAMP=bact-archiver-whl.stamp
PIP_ARCHIVER_WHEEL_STAMP=pip-archiver-whl.stamp
STAMPS=$(BACT_ARCHIVER_WHEEL_STAMP) $(PIP_ARCHIVER_WHEEL_STAMP)
all : $(CONTAINERS)


bact-container.sdef : $(BUILD_DIR)/python-container.sif $(BACT_ARCHIVER_WHEEL_STAMP) $(PIP_ARCHIVER_WHEEL_STAMP)

$(BUILD_DIR)/bact-archiver-build.sif : $(UBUNTU_BUILD_IMG)


thor-scsi-lib-as-twin.sdef : $(BUILD_DIR)/epics7-pydevice.sif

$(BUILD_DIR)/%.sif : %.sdef
	$(APPTAINER) build $@ $<

clean :
	$(RM) $(RMFLAGS) $(STAMPS)
	$(RM) $(RMFLAGS) $(CONTAINERS)

# ------------------------------------------------------------------------------
# special builds ....
# the build image to use

$(PIP_ARCHIVER_WHEEL_STAMP) : lists/bact_package_list.txt
	$(PIP3) download -r $< -d $(WHEELS_DIR)
	$(TOUCH) $@

#------------------------------------------------------------
# bact-archiver
# where is the src
BACT_ARCHIVER_DIR=$(SRC_DIR)/bact-archiver/
BACT_ARCHIVER_BUILD_IMG=$(BUILD_DIR)/bact-archiver-build.sif

# good to have the file, but the name depends on the version
# thus this needs to be adjusted for each version etc...
# solution: get it into pypi
BACT_ARCHIVER_WHEEL=$(BACT_ARCHIVER_DIR)/dist/bact_archiver-0.2.0-cp310-cp310-linux_x86_64.whl

$(BACT_ARCHIVER_WHEEL_STAMP) : $(BACT_ARCHIVER_BUILD_IMG)
	( echo $(T_DIR_ABS);                                               \
          cd $(BACT_ARCHIVER_DIR)                                          \
          && $(BACT_ARCHIVER_BUILD_IMG) setup.py build_proto_c bdist_wheel -d $(WHEELS_DIR) \
        ) && $(TOUCH) $@
