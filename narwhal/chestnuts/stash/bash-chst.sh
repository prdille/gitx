#####
##### bash
##### shell
##### chestnuts
#####

### remove spaces in the names of files
$ for f in *\ *; do mv "$f" "${f// /_}"; done
