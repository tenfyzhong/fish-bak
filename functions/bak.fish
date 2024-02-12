function bak --description "Backup file/directory"
    argparse 'i/interactive' 't/time' 'm/mv' 'r/restore' 's/suffix=' 'h/help' -- $argv 2>/dev/null
    if test $status -ne 0
        _bak_help
        return 1
    end

    if set -q _flag_help 
        _bak_help
        return 0
    end

    set -f suffix $_flag_suffix
    if test -z $suffix
        set suffix 'bak'
    end

    set -f pattern '.'$suffix'$'
    set -f baksuffix $suffix
    if set -q _flag_t
        set -l now $(date +%Y-%m-%dT%H:%M:%S)
        set baksuffix "$now.$suffix"
        set pattern '\.\d{4}\-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.'$suffix'$'
    end

    for f in $argv
        if test ! -e $f 
            echo "bak can't bak $f: No such file or directory"
            continue
        end
        if set -q _flag_restore
            set -l match (string match -r $pattern $f)
            if test -z $match
                continue
            end
            set -l endpos (math -(string length $match))
            set -f new (string sub -e $endpos $f)
        else
            set -f new (printf $f.$baksuffix)
        end

        if test -e $new; and set -q _flag_i
            read -n 1 -P "confirm to overwrite <$new> [y/n]:" confirm
            if test "$confirm" != 'y' -a "$confirm" != 'Y'
                continue
            end
        end
        if set -q _flag_mv
            mv -f $f $new
        else
            cp -rf $f $new
        end
    end
end

function _bak_help
    printf %s\n \
        'bak: Backup file/directory' \
        'Usage: bak [options] <file/directory>' \
        '' \
        'Options:' \
        '  -i/--interactive     prompt before overwrite' \
        '  -t/--time            add time to backup file name' \
        '  -m/--mv              use mv to bak/restore file/directory' \
        '  -r/--restore         restore file/directory' \
        '  -s/--suffix SUFFIX   special a suffix, default: ".bak"' \
        '  -h/--help            print this help message'
end
