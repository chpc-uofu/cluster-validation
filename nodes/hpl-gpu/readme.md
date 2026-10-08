# NVIDIA HPL

Part of [NVIDIA HPC Benchmarks](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/hpc-benchmarks), this runs the High Performance Linpack (HPL) on an NVIDIA GPU. The binary is obtained from the container.

Singularity is required to run the container, along with an NVIDIA Container Registry account and its API key, to get the container.

### Running

If the script is run via SLURM, a correct account/partition, GPU gres and host memory equal or larger to that on the GPU need to be added, e.g
```
sbatch -A notchpeak-shared-short -p notchpeak-shared-short --gres=gpu:t4:1 --mem=16G run1gpu.slr
```

To run interactively, execute the script through bash:
```
bash run1gpu.slr
```
In this case the first GPU will be picked up to run on.

Correct execution will show the Gflops score at the end:
```
T/V                N    NB     P     Q               Time                 Gflops
--------------------------------------------------------------------------------
WR03L2L2       31680   288     1     1              92.09              2.302e+02 
```

### Pulling the container

Pulling the container is complicated since it requires authentication. It is necessary to pull it if one clones the GitHub repository since we don't store the container image file in the repository.

Roughly follow [this page](https://www.pugetsystems.com/labs/hpc/how-to-setup-nvidia-docker-and-ngc-registry-on-your-workstation-part-4-accessing-the-ngc-registry-1115/) to get an nvcr.io account and API key. nvcr.io accepts a standard NVIDIA account (from its developer hub), though key generation must be accessed through this [direct URL](https://ngc.nvidia.com/setup).

Once the key is ready, do the following in Bash:
```
module load singularity
export SINGULARITY_DOCKER_USERNAME='$oauthtoken'
export SINGULARITY_DOCKER_PASSWORD=
singularity pull --docker-login hpc-benchmarks:21.4-hpl.sif docker://nvcr.io/nvidia/hpc-benchmarks:21.4-hpl
```
In the `Docker password` prompt put the API Key.
