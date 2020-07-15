runMesaTest.sh runs on a 10 minute cron job timer
This updates a svnsync on the mesa repo.
runMesaTest.sh submits mesa-test.sh for each version not tested yet

We keep track of which versions have been tested by making a folder with the version number as its name. Then we just need to loop between
the name of the highest numbered folder and svn head.

mesa-test.sh checkouts one mesa version builds it
mesa-test.sh then submits a job array for mesa-{single,binary,astero}.sh tests

Each of the mesa-{single,binary,astero} copies the test case into a folder onto a node local hard drive, runs, submits, and cleanups up after that test case

mesa-test.sh submits mesa-test-final which has a dependancy on mesa-{single,binary,astero}.sh
mesa-test-final runs any final cleanup.

mesa_test.sh holds common shell variables 

runMesaDoxygen.sh runs doxygen on mesa

cleanMesaCaches.sh makes sure that we've cleaned up on the local harddrives.
