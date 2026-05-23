##
# FreshrFridge — TuyaOpen app for T5 AI board (3.5" LCD)
##

set(APP_PATH ${CMAKE_CURRENT_LIST_DIR})
get_filename_component(APP_NAME ${APP_PATH} NAME)

file(GLOB_RECURSE APP_SRC
    ${APP_PATH}/src/*.c
)

set(APP_INC
    ${APP_PATH}/include
    ${APP_PATH}/src
)

set(APP_OPTIONS "-Wall" "-DLV_LVGL_H_INCLUDE_SIMPLE")

add_library(${EXAMPLE_LIB})

target_sources(${EXAMPLE_LIB}
    PRIVATE
    ${APP_SRC}
)

target_include_directories(${EXAMPLE_LIB}
    PRIVATE
    ${APP_INC}
)

target_compile_options(${EXAMPLE_LIB}
    PRIVATE
    ${APP_OPTIONS}
)
