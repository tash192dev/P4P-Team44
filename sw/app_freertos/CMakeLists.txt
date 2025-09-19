cmake_minimum_required(VERSION 3.14)

add_subdirectory(../bsp_freertos bsp_freertos)

include(../bsp_freertos/toolchain.cmake)

project(app_freertos)

add_executable(app_freertos.elf)

target_sources(app_freertos.elf
    PRIVATE
        hello_freertos.c
)

target_include_directories(app_freertos.elf
    PRIVATE
    PUBLIC
)

target_link_libraries(app_freertos.elf
    PRIVATE
        -T "${BspLinkerScript}" -nostdlib
        "${ExtraArchiveLibraries}"
        -Wl,--start-group "${BspLibraryName}" -lc -lstdc++ -lgcc -lm -Wl,--end-group
)

# Create objdump from ELF.
set(objdump app_freertos.elf.objdump)
add_custom_command(
    OUTPUT "${objdump}"
    DEPENDS app_freertos.elf
    COMMAND "${ToolchainObjdump}" "${ToolchainObjdumpFlags}" app_freertos.elf >
            "${objdump}"
    COMMENT "Creating ${objdump}."
    VERBATIM
)
add_custom_target(create-objdump ALL DEPENDS "${objdump}")

# Report space free for stack + heap. Note that the file below is never created
# so the report is always output on build.
set(stack_report_file app_freertos.elf.stack_report)
add_custom_command(
    OUTPUT "${stack_report_file}"
    DEPENDS app_freertos.elf
    COMMAND niosv-stack-report -p "${ToolchainPrefix}" app_freertos.elf
    COMMENT "Reporting memory available for stack + heap in app_freertos.elf."
    VERBATIM
)
add_custom_target(niosv-stack-report ALL DEPENDS "${stack_report_file}")
