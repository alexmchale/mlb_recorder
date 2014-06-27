MLB Audio Recorder
------------------

Two components:

1. The program that downloads the audio stream to file

    a. One process downloads the audio stream to disk
    b. The other process monitors the disk to see if the download has stalled out

2. The web app that provides a player for the audio streams

    a. Monitors disk to see what games and files are available
    b. Provides an interface that makes it look like it's all one file
