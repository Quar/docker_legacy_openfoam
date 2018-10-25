OpenFOAM Auto Install Script
===========

Note that this script will try to auto install OpenFoam from souce 
(which means will download source code) and then compile on local machine.
This script is primarily targated at installing old-releases of OpenFOAM
which do not have binary installation packages pre-compiled on APT.

The entire installation time cost approximately 2-6 hours depends on network
bandwidth and CPU memory power.

Those who seeks faster and easier installation for more recent versions
of OpenFOAM, such as OpenFOAM 5 or later should consider following 
instruction on https://openfoam.org/download/5-0-ubuntu/


### Usage

Note that you will have to have administrator privilige in order to properly
trigger following scirpt.

Open Terminal and locate to the folder where the `installOpenFOAM.bash` resides.

```bash
bash ./installOpenFOAM.bash <openfoam_version_nubmer>
```

For example, to install *OpenFoam 2.2.2*:

```bash
bash ./installOpenFOAM.bash 2.2.2
```


You will be asked for `sudo` password once.


Please consider doing installation above within a `tmux` session, to avoid this
installation process from being terminated midway because of lost connection
or system hybernation, especially if you were working through SSH.

