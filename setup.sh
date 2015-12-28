#!/bin/bash
## INFO ##
## INFO ##

compilers="clang gcc";
builds="devel release";
tupfile="\
## INFO ##
## INFO ##

# Include rules
include tuplet/Tuprules.tup

#----- EXAMPLE BUILD ----------------------------------------------------------#
sources = src/main.c

: foreach \$(sources) |> !to_cpp  |> \$(BUILD_DIR)/cpp-out/%B.cpp.%e
: foreach \$(sources) |> !analyze |>
: foreach \$(sources) |> !to_obj  |> \$(BUILD_DIR)/%B.o {obj}
: {obj}              |> !to_bin  |> \$(BINARY_DIR)/%B {bin}
: {bin}              |> !run_it  |>
";

# If remove build-variants
if [ "$1" == "remove" ];
then
    printf "Removing folders: build-*\n";
    rm -rf build-*;
# If create build-variants
else
    for compiler in $compilers;
    do
        for build in $builds;
        do
            config=$compiler-$build
            folder=build-$config;

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

    # If Tuofile does not exist, create a new one
    if [ ! -f Tupfile ];
    then
        printf "Create file: Tupfile\n";
        printf "$tupfile" > Tupfile;
    fi;
fi;

# If everythign went fine
exit;
