# Install script for directory: /Users/rvjansen/apps/oorexx-code-0/samples/unix/api/callrexx

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/Users/rvjansen/Applications/ooRexx5")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "RELEASE")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/rvjansen/Applications/ooRexx5/bin/callrexx1")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/Users/rvjansen/Applications/ooRexx5/bin" TYPE EXECUTABLE FILES "/Users/rvjansen/apps/oorexx-code-0/bin/callrexx1")
  if(EXISTS "$ENV{DESTDIR}/Users/rvjansen/Applications/ooRexx5/bin/callrexx1" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/Users/rvjansen/Applications/ooRexx5/bin/callrexx1")
    execute_process(COMMAND /usr/bin/install_name_tool
      -delete_rpath "/Users/rvjansen/apps/oorexx-code-0/lib"
      "$ENV{DESTDIR}/Users/rvjansen/Applications/ooRexx5/bin/callrexx1")
    execute_process(COMMAND /usr/bin/install_name_tool
      -add_rpath "@executable_path/../lib"
      "$ENV{DESTDIR}/Users/rvjansen/Applications/ooRexx5/bin/callrexx1")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/strip" "$ENV{DESTDIR}/Users/rvjansen/Applications/ooRexx5/bin/callrexx1")
    endif()
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/rvjansen/Applications/ooRexx5/bin/callrexx2")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/Users/rvjansen/Applications/ooRexx5/bin" TYPE EXECUTABLE FILES "/Users/rvjansen/apps/oorexx-code-0/bin/callrexx2")
  if(EXISTS "$ENV{DESTDIR}/Users/rvjansen/Applications/ooRexx5/bin/callrexx2" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/Users/rvjansen/Applications/ooRexx5/bin/callrexx2")
    execute_process(COMMAND /usr/bin/install_name_tool
      -delete_rpath "/Users/rvjansen/apps/oorexx-code-0/lib"
      "$ENV{DESTDIR}/Users/rvjansen/Applications/ooRexx5/bin/callrexx2")
    execute_process(COMMAND /usr/bin/install_name_tool
      -add_rpath "@executable_path/../lib"
      "$ENV{DESTDIR}/Users/rvjansen/Applications/ooRexx5/bin/callrexx2")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/strip" "$ENV{DESTDIR}/Users/rvjansen/Applications/ooRexx5/bin/callrexx2")
    endif()
  endif()
endif()

