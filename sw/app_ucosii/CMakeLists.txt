cmake_minimum_required(VERSION 3.14)

add_subdirectory(../bsp_ucosii bsp_ucosii)

include(../bsp_ucosii/toolchain.cmake)

project(app_ucosii)

add_executable(app_ucosii.elf)

target_sources(app_ucosii.elf
    PRIVATE
        hello_ucosii.c
)

target_include_directories(app_ucosii.elf
    PRIVATE
    PUBLIC
)

target_link_libraries(app_ucosii.elf
    PRIVATE
        -T "${BspLinkerScript}" -nostdlib
        "${ExtraArchiveLibraries}"
        -Wl,--start-group "${BspLibraryName}" -lc -lstdc++ -lgcc -lm -Wl,--end-group
)

# Create objdump from ELF.
set(objdump app_ucosii.elf.objdump)
add_custom_command(
    OUTPUT "${objdump}"
    DEPENDS app_ucosii.elf
    COMMAND "${ToolchainObjdump}" "${ToolchainObjdumpFlags}" app_ucosii.elf >
            "${objdump}"
    COMMENT "Creating ${objdump}."
    VERBATIM
)
add_custom_target(create-objdump ALL DEPENDS "${objdump}")

# Report space free for stack + heap. Note that the file below is never created
# so the report is always output on build.
set(stack_report_file app_ucosii.elf.stack_report)
add_custom_command(
    OUTPUT "${stack_report_file}"
    DEPENDS app_ucosii.elf
    COMMAND niosv-stack-report -p "${ToolchainPrefix}" app_ucosii.elf
    COMMENT "Reporting memory available for stack + heap in app_ucosii.elf."
    VERBATIM
)
add_custom_target(niosv-stack-report ALL DEPENDS "${stack_report_file}")
