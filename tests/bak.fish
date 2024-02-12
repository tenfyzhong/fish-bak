set mockdate 2024-02-12T12:14:01
function date
    echo $mockdate
end

set home (mktemp -d)
cd $home

@test 'argparse failed, statuss' (bak -x &>/dev/null) $status -eq 1
@test 'argparse failed, output' (bak -x | string collect) = 'bak: Backup file/directory
Usage: bak [options] <file/directory>

Options:
  -i/--interactive     prompt before overwrite
  -t/--time            add time to backup file name
  -m/--mv              use mv to bak/restore file/directory
  -r/--restore         restore file/directory
  -s/--suffix SUFFIX   special a suffix, default: ".bak"
  -h/--help            print this help message'


@test 'help, status' (bak -h &>/dev/null) $status -eq 0
@test 'help, output' (bak -h | string collect) = 'bak: Backup file/directory
Usage: bak [options] <file/directory>

Options:
  -i/--interactive     prompt before overwrite
  -t/--time            add time to backup file name
  -m/--mv              use mv to bak/restore file/directory
  -r/--restore         restore file/directory
  -s/--suffix SUFFIX   special a suffix, default: ".bak"
  -h/--help            print this help message'


touch hello.txt world.txt
bak *
@test 'bak hello.txt' -f hello.txt.bak -a -f hello.txt
@test 'bak world.txt' -f world.txt.bak -a -f world.txt

rm * -rf
touch hello.txt world.txt
bak -m *
@test 'bak hello.txt' -f hello.txt.bak -a ! -f hello.txt
@test 'bak world.txt' -f world.txt.bak -a ! -f world.txt
bak -r -m *.bak
@test 'bak -r hello.txt' ! -f hello.txt.bak -a -f hello.txt
@test 'bak -r world.txt' ! -f world.txt.bak -a -f world.txt

rm * -rf
touch hello.txt world.txt
bak -m -s backup *
@test 'bak hello.txt' -f hello.txt.backup -a ! -f hello.txt
@test 'bak world.txt' -f world.txt.backup -a ! -f world.txt

rm * -rf
touch hello.txt world.txt
bak -m -t *
@test 'bak hello.txt' -f hello.txt.$mockdate.bak -a ! -f hello.txt
@test 'bak world.txt' -f world.txt.$mockdate.bak -a ! -f world.txt
bak -m -t -r *
@test 'bak hello.txt' ! -f hello.txt.$mockdate.bak -a -f hello.txt
@test 'bak world.txt' ! -f world.txt.$mockdate.bak -a -f world.txt


rm -rf $home
