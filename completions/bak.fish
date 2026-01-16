complete bak -s i -l interactive -d 'prompt before overwrite'
complete bak -s t -l time -d 'add time to backup name'
complete bak -s m -l mv -d 'use mv to bak/restore file/directory'
complete bak -s r -l restore -d 'restore file/directory'
complete bak -r -f -s s -l suffix -d 'special a suffix, default: .bak'
complete bak -s h -l help -d 'print this help message'

# When -r/--restore option is present, only complete .bak files
complete bak -n '__fish_contains_opt -s r restore' -f -a '(__fish_complete_suffix .bak)'

# When -r/--restore option is not present, complete files except .bak files
function __bak_complete_non_bak_files
    set -l token (commandline -ct)
    for f in $token*
        string match -qv "*.bak" -- $f
        and printf '%s\n' $f
    end
end
complete bak -n 'not __fish_contains_opt -s r restore' -f -a '(__bak_complete_non_bak_files)'
