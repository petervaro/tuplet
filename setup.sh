#!/bin/bash
## INFO ##
## INFO ##

compilers="clang gcc";
builds="devel release";
standards="c99 c11";
tupfile=\
'## INFO ##
## INFO ##

# Include rules
include tuplet/Tuprules.tup

#----- EXAMPLE BUILD ----------------------------------------------------------#
sources = src/main.c

: foreach $(sources) |> !to_cpp  |> $(BUILD_DIR)/cpp-out/%%B.cpp.%%e
: foreach $(sources) |> !analyze |>
: foreach $(sources) |> !to_obj  |> $(BUILD_DIR)/%%B.o {obj}
: {obj}              |> !to_bin  |> $(BINARY_DIR)/%%B {bin}
: {bin}              |> !run_it  |>
';

# If remove build-variants
if [ "$1" == "remove" ] ||
   [ "$1" == "rm" ]     ||
   [ "$1" == "-r" ]     ||
   [ "$1" == "--remove" ];
then
    printf "Removing folders: build-(${compilers// /|})*\n";
    rm -rf $(ls --color=never . | grep -E 'build-(${compilers// /|})*');
# If bake symlinks to tup.config (create standalone files)
elif [ "$1" == "finalize" ] ||
     [ "$1" == "fin" ]      ||
     [ "$1" == "-f" ]       ||
     [ "$1" == "--finalize" ];
then
    printf "Replacing links with targets: build-(${compilers// /|})*/tup.config\n";
    for folder in $(ls --color=never . | grep -E 'build-(${compilers// /|})*');
    do
        cd $folder;
        cp --remove-destination $(readlink tup.config) tup.config;
        cd ..;
    done;
# If clear build directory (for rebuilding the project)
elif [ "$1" == "clean" ] ||
     [ "$1" == "cl" ]    ||
     [ "$1" == "-c" ]    ||
     [ "$1" == "--clean" ];
then
    printf "Cleaning build folder: build-(${compilers// /|})*/*\n";
    for folder in build-*;
    do
        for file in $folder/*;
        do
            if [ "$file" != "$folder/tup.config" ];
            then
                rm -rf "$file";
            fi;
        done;
    done;
# If create build-variants
else
    for compiler in $compilers;
    do
        for build in $builds;
        do
            for standard in $standards;
            do
                config="$compiler-$build-$standard";
                folder="build-$config";

                # If folder already exists
                if [ -d $folder ]
                then
                    printf "Folder exists: $folder\n";
                    continue;
                fi;

                # If folder does not exist, create it
                printf "Create folder: $folder\n";
                mkdir $folder;

                # Create symlink
                printf "Create config: $folder/tup.config\n";
                ln -s ../tuplet/configs/$config.config $folder/tup.config;
            done;
        done;
    done;

    # If Tuofile does not exist, create a new one
    if [ ! -f Tupfile ];
    then
        printf "Create file: Tupfile\n";
        printf "$tupfile" > Tupfile;
    fi;
fi;

# If everythign went fine
exit;
