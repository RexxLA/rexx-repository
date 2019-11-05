# Install script for directory: /Users/rvjansen/apps/oorexx-code-0/samples/native.api/call.example

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

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xSamplesx" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api/stackOverflow")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api" TYPE EXECUTABLE PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ FILES "/Users/rvjansen/apps/oorexx-code-0/bin/stackOverflow")
  if(EXISTS "$ENV{DESTDIR}/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api/stackOverflow" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api/stackOverflow")
    execute_process(COMMAND /usr/bin/install_name_tool
      -delete_rpath "/Users/rvjansen/apps/oorexx-code-0/lib"
      "$ENV{DESTDIR}/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api/stackOverflow")
    execute_process(COMMAND /usr/bin/install_name_tool
      -add_rpath "@executable_path/../lib"
      "$ENV{DESTDIR}/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api/stackOverflow")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/strip" "$ENV{DESTDIR}/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api/stackOverflow")
    endif()
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xSamplesx" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api/stackOverflow.cpp")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api" TYPE FILE PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ FILES "/Users/rvjansen/apps/oorexx-code-0/samples/native.api/call.example/stackOverflow.cpp")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xSamplesx" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api/runRexxProgram")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api" TYPE EXECUTABLE PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ FILES "/Users/rvjansen/apps/oorexx-code-0/bin/runRexxProgram")
  if(EXISTS "$ENV{DESTDIR}/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api/runRexxProgram" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api/runRexxProgram")
    execute_process(COMMAND /usr/bin/install_name_tool
      -delete_rpath "/Users/rvjansen/apps/oorexx-code-0/lib"
      "$ENV{DESTDIR}/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api/runRexxProgram")
    execute_process(COMMAND /usr/bin/install_name_tool
      -add_rpath "@executable_path/../lib"
      "$ENV{DESTDIR}/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api/runRexxProgram")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/strip" "$ENV{DESTDIR}/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api/runRexxProgram")
    endif()
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xSamplesx" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api/runRexxProgram.cpp")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api" TYPE FILE PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ FILES "/Users/rvjansen/apps/oorexx-code-0/samples/native.api/call.example/runRexxProgram.cpp")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xSamplesx" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api/HelloWorld.rex")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api" TYPE PROGRAM PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ FILES "/Users/rvjansen/apps/oorexx-code-0/samples/native.api/call.example/HelloWorld.rex")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xSamplesx" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api/backward.fnc")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api" TYPE PROGRAM PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ FILES "/Users/rvjansen/apps/oorexx-code-0/samples/native.api/call.example/backward.fnc")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xSamplesx" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api/tooRecursiveTrapped.rex")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api" TYPE PROGRAM PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ FILES "/Users/rvjansen/apps/oorexx-code-0/samples/native.api/call.example/tooRecursiveTrapped.rex")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xSamplesx" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api/tooRecursiveUnhandled.rex")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api" TYPE PROGRAM PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ FILES "/Users/rvjansen/apps/oorexx-code-0/samples/native.api/call.example/tooRecursiveUnhandled.rex")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xSamplesx" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api/ReadMe.txt")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api" TYPE FILE PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ FILES "/Users/rvjansen/apps/oorexx-code-0/samples/native.api/call.example/ReadMe.txt")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xSamplesx" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api/Makefile.linux")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/Users/rvjansen/Applications/ooRexx5/share/ooRexx/native.api" TYPE FILE FILES "/Users/rvjansen/apps/oorexx-code-0/samples/native.api/call.example/Makefile.linux")
endif()

