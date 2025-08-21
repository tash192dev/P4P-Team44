cmake_minimum_required(VERSION 3.14)

add_subdirectory(../deeznuts_bsp deeznuts_bsp)

include(../deeznuts_bsp/toolchain.cmake)

project(app_hal)

add_executable(app_hal.elf)

target_sources(app_hal.elf
    PRIVATE
        hello.c
)

target_include_directories(app_hal.elf
    PRIVATE
    PUBLIC
)

target_link_libraries(app_hal.elf
    PRIVATE
        -T "${BspLinkerScript}" -nostdlib
        "${ExtraArchiveLibraries}"
        -Wl,--start-group "${BspLibraryName}" -lc -lstdc++ -lgcc -lm -Wl,--end-group
)

# Create objdump from ELF.
set(objdump app_hal.elf.objdump)
add_custom_command(
    OUTPUT "${objdump}"
    DEPENDS app_hal.elf
    COMMAND "${ToolchainObjdump}" "${ToolchainObjdumpFlags}" app_hal.elf >
            "${objdump}"
    COMMENT "Creating ${objdump}."
    VERBATIM
)
add_custom_target(create-objdump ALL DEPENDS "${objdump}")

# Report space free for stack + heap. Note that the file below is never created
# so the report is always output on build.
set(stack_report_file app_hal.elf.stack_report)
add_custom_command(
    OUTPUT "${stack_report_file}"
    DEPENDS app_hal.elf
    COMMAND niosv-stack-report -p "${ToolchainPrefix}" app_hal.elf
    COMMENT "Reporting memory available for stack + heap in app_hal.elf."
    VERBATIM
)
add_custom_target(niosv-stack-report ALL DEPENDS "${stack_report_file}")
