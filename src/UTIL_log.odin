package src

import os "core:os"
import fmt "core:fmt"
import log "core:log"
import time "core:time"
import strings "core:strings"

UTIL_get_current_log_file_name_A :: proc() -> string {
    log_ext := "info.log"

    ret := UTIL_create_filepath_A(APP_LOG_PATH, log_ext)

    return ret
}

UTIL_init_logger_A :: proc() {
    when ODIN_OS == .WASI do return
    
    log_path := UTIL_get_current_log_file_name_A()

    // these 3 modes create the file if it doesnt exist, erases data if it does,
    // and then only allows the logger to write into it
    when ODIN_OS == .Linux || ODIN_OS == .Darwin {
        // 0o644 is a default file permission for unix that allows users to read the file
        file, err := os.open(
            path = log_path,
            flags = os.O_WRONLY | os.O_CREATE | os.O_TRUNC,
            mode = 0o644
        )
    } else when ODIN_OS == .Windows {
        file, err := os.open(log_path, os.O_WRONLY | os.O_CREATE | os.O_TRUNC)
    }
    
    delete(log_path)
    if err != nil {
        fmt.printfln("ERROR on opening log file: %s", os.error_string(err))
        APP_shutdown()
    }

    APP_logger = log.create_file_logger(file, log.Level.Info)
    APP_logger_init_flag = true
}