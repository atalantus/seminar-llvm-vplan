cmake_minimum_required(VERSION 3.18)

project(llvm-vplan)

set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)

set(CMAKE_CXX_STANDARD 20)
add_compile_options(-Wall -Wextra -Wvla)

set(CMAKE_CXX_FLAGS_RELEASE "-O3")

set(CMAKE_VERBOSE_MAKEFILE ON)

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
        simple_loop_ir
        COMMAND ${CMAKE_CXX_COMPILER} -O1 -S -emit-llvm -Rpass=loop-vectorize -Rpass-missed=loop-vectorize -Rpass-analysis=loop-vectorize -fsave-optimization-record ${CMAKE_CURRENT_SOURCE_DIR}/simple_loop.cpp -o ${CMAKE_BINARY_DIR}/simple_loop.ll
        DEPENDS simple_loop.cpp
)

add_custom_target(
        simple_loop_ir_cc1
        COMMAND ${CMAKE_CXX_COMPILER} -cc1 -O1 -S -emit-llvm -Rpass=loop-vectorize -Rpass-missed=loop-vectorize -Rpass-analysis=loop-vectorize ${CMAKE_CURRENT_SOURCE_DIR}/simple_loop.cpp -o ${CMAKE_BINARY_DIR}/simple_loop.ll
        DEPENDS simple_loop.cpp
)