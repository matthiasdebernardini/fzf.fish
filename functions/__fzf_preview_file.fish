# helper function for __fzf_search_current_dir
function __fzf_preview_file --description "Prints a preview for the given file based on its file type." --argument-names file_path
    # -d displays information about the directories themselves instead of the contents of the directories
    # -o displays long format without group id. We want long format because it gives the file type as the very first character
    # Executing ls with command because users may have ls aliased to exa
    set file_type_char (command ls -o -d "$file_path" | string sub --length 1)

    # For more on file symbols outputted by ls long format, see https://linuxconfig.org/identifying-file-types-in-linux
    # For more on file types, see https://en.wikipedia.org/wiki/Unix_file_types
    switch $file_type_char
        case - # regular file
            bat --style=numbers --color=always "$file_path"
        case d # directory
            # Setting CLICOLOR_FORCE forces colors to be enabled even to a non-terminal output
            CLICOLOR_FORCE=true ls -a "$file_path"
        case l # symlink
            # notify user and recurse on the target of the symlink, which can be any of these file types
            set target_path (realpath $file_path)

            set_color yellow
            echo "'$file_path' is a symlink to '$target_path'."
            set_color normal

            __fzf_preview_file "$target_path"
        case c
            __fzf_report_file_type "$file_path" "character device file"
        case b
            __fzf_report_file_type "$file_path" "block device file"
        case s
            __fzf_report_file_type "$file_path" "socket"
        case p
            __fzf_report_file_type "$file_path" "named pipe"
        case "" # occurs when ls fails, e.g. with bad file descriptors
            set_color red
            echo 'ls command failed.' >&2
            set_color normal
            exit 1
        case "*"
            echo "Unexpected file symbol $file_type_char. Please open an issue at https://github.com/patrickf3139/fzf.fish." >&2
    end
end
