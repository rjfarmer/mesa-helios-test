runMesaTest.sh runs on a 10 minute cron job timer

This fetches all new commits made to the repo.

Then for each commit we spawn a slurm job thats runs mesa-test.sh

Each mesa-test.sh clones one version from git, and runs the test suite for that version in parallel.

mesa-run-test-suite.sh runs one test case, by copying the test case to a local folder.
It can handle all types (star,binary, and astero) of test cases

mesa-test.sh then submits mesa-test-final which has a dependancy on all the mesa-run-test-suite.sh scripts that where submitted
mesa-test-final runs any final cleanup, namely deleteing MESA_DIR

mesa_test.sh holds common shell variables 

cleanMesaCaches.sh makes sure that we've cleaned up on the local hard drives.
