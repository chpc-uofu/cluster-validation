# HPL tests for whole clusters validation

The subdirectories contain SLURM script and template HPL input file to submit HPL job to validate whole sections of clusters after the downtime.

Every partition directory includes a `submit.sh` symbolic link to the shared wrapper. It determines the idle-node count and, when possible, selects an active reservation that Slurm confirms is usable for the exact submission. Each run must be launched from its own directory because the `HPL.dat` input file is generated in the working directory.

```
(cd np_guest && ./submit.sh)
(cd np_gen && ./submit.sh)
(cd kp_guest && ./submit.sh)
(cd kp_gen && ./submit.sh)
(cd lp_guest && ./submit.sh)
(cd lp_gen && ./submit.sh)
(cd grn_guest && ./submit.sh)
(cd grn_gen && ./submit.sh)
```

Additional `sbatch` options can follow the command, for example `./submit.sh --time=4:00:00`. General partitions submit with `--account=chpc`; the Notchpeak, Kingspeak, and Lonepeak guest partitions use `--account=owner-guest`. The Granite general wrapper submits with `--partition=granite --qos=granite --account=chpc`; the Granite guest wrapper submits with `--partition=granite-guest --qos=granite-guest --account=chpc`. Unlike the other wrappers, Granite requires its QoS to be supplied explicitly. The wrapper only applies a reservation after `sbatch --test-only` confirms it is active, matches the partition, and is usable by the submitter and account for the request.

Upon successful completion, the `.err` file should be empty and the `.out` file should contain HPL output, e.g.
```
================================================================================
T/V                N    NB     P     Q               Time                 Gflops
--------------------------------------------------------------------------------
WR11C2R4      445440   192    29    40            3630.54             1.6230e+04
```
