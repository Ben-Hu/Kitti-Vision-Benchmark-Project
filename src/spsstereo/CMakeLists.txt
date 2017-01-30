#Project
cmake_minimum_required(VERSION 2.4)
project(spsstereo)

# Flags
set(CMAKE_CXX_FLAGS_RELEASE "-Wall -O3 -msse4.2 -m64")
if (APPLE)
set(CMAKE_CXX_FLAGS_RELEASE "-Wall -O3 -msse4.2 -stdlib=libc++ -m64")
endif (APPLE)
set(CMAKE_BUILD_TYPE Release)

# SPS-Stereo
file(GLOB SPSSTEREO_SRC_FILES "*.cpp")
add_executable(spsstereo ${SPSSTEREO_SRC_FILES})
target_link_libraries(spsstereo png)
