if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/cmake/GetGitRevisionDescription.cmake)
    include(GetGitRevisionDescription)
    git_describe_working_tree(WORKING_TREE_DESCRIPTION)

    string(REGEX MATCH "v([0-9]+)\\.([0-9]+)\\.([0-9]+)[-]*([-0-9a-z]*)$" regex_match ${WORKING_TREE_DESCRIPTION})
    set(VERSION_MAJOR ${CMAKE_MATCH_1})
    set(VERSION_MINOR ${CMAKE_MATCH_2})
    set(VERSION_PATCH ${CMAKE_MATCH_3})
    set(VERSION_TWEAK_ALL ${CMAKE_MATCH_4})

    # In case of not accessed Git Tree WORKING_TREE_DESCRIPTION
    # can be empty. Possible reasons are .git direcory is not exist
    # or the project is a submodule and moved to a different location
    if (${WORKING_TREE_DESCRIPTION} STREQUAL "-128-NOTFOUND")
        message(FATAL_ERROR "Not a Git Repository")
    endif ()

    if (NOT ${VERSION_TWEAK_ALL} STREQUAL "")
        # If working tree is move further from tagged commit or dirty

        string(REGEX MATCH "([0-9]*)-([0-9a-z-]*)$" regex_match ${VERSION_TWEAK_ALL})

        if (NOT ${CMAKE_MATCH_1} STREQUAL "")
            set(VERSION_TWEAK ${CMAKE_MATCH_1})
        else ()
            set(VERSION_TWEAK 0)
        endif ()

    else ()
        # Working tree is all clear
        set(VERSION_TWEAK 0)
    endif ()
else ()
    message(FATAL_ERROR "CMake is failed to get version information")
endif ()
