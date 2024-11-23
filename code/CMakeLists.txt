cmake_minimum_required(VERSION 3.18)

project(llvm-vplan)

set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)

set(CMAKE_CXX_STANDARD 20)
add_compile_options(-Wall -Wextra -Wvla)

set(CMAKE_CXX_FLAGS_RELEASE "-O3")

find_package(LLVM 19.1 REQUIRED CONFIG)
add_definitions(${LLVM_DEFINITIONS})
include_directories(${LLVM_INCLUDE_DIRS})
link_directories(${LLVM_LIBRARY_DIRS})
message(STATUS "LLVM_INCLUDE_DIRS = ${LLVM_INCLUDE_DIRS}")
message(STATUS "LLVM_INSTALL_PREFIX = ${LLVM_INSTALL_PREFIX}")

add_definitions(${LLVM_DEFINITIONS})
set(LLVM_LIBS LLVM)

add_executable(sl simple_loop.cpp)

add_custom_target(
        ir
        COMMAND ${CMAKE_CXX_COMPILER} -O1 -ffast-math -march=native -S -emit-llvm -fsave-optimization-record ${CMAKE_CURRENT_SOURCE_DIR}/simple_loop.cpp -o ${CMAKE_BINARY_DIR}/simple_loop.ll
        DEPENDS simple_loop.cpp
)

add_custom_target(
        ir_cc1
        COMMAND ${CMAKE_CXX_COMPILER} -cc1 -target-cpu znver4 -O1 -S -emit-llvm ${CMAKE_CURRENT_SOURCE_DIR}/simple_loop.cpp -o ${CMAKE_BINARY_DIR}/simple_loop_cc1.ll
        DEPENDS simple_loop.cpp
)