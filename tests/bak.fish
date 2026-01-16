# Ensure we're testing the local version of bak
set -p fish_function_path (dirname (status filename))/../functions

set mockdate 2024-02-12T12:14:01
function date
    echo $mockdate
end

set testhome (mktemp -d)
cd $testhome

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

mkdir testdir
bak -m testdir/
@test 'bak -m testdir' -d testdir.bak -a ! -d testdir

mkdir testdir2
bak -m testdir2
@test 'bak -m testdir2' -d testdir2.bak -a ! -d testdir2

# Test: backup directory when .bak already exists (should replace, not nest)
rm -rf *
mkdir testdir3
touch testdir3/file1.txt
bak testdir3
@test 'first bak testdir3' -d testdir3.bak -a -f testdir3.bak/file1.txt

# Modify original and backup again
touch testdir3/file2.txt
bak testdir3
@test 'second bak testdir3 exists' -d testdir3.bak
@test 'second bak testdir3 has file2' -f testdir3.bak/file2.txt
@test 'second bak testdir3 not nested' ! -d testdir3.bak/testdir3

# Test: backup directory with -m when .bak already exists
rm -rf *
mkdir testdir4
touch testdir4/file1.txt
bak testdir4
mkdir testdir4
touch testdir4/file2.txt
bak -m testdir4
@test 'bak -m testdir4 exists' -d testdir4.bak
@test 'bak -m testdir4 has file2' -f testdir4.bak/file2.txt
@test 'bak -m testdir4 not nested' ! -d testdir4.bak/testdir4
@test 'bak -m testdir4 original removed' ! -d testdir4

# Test: restore directory when original already exists (should replace, not nest)
rm -rf *
mkdir testdir5.bak
touch testdir5.bak/file1.txt
mkdir testdir5
touch testdir5/old.txt
bak -r testdir5.bak
@test 'restore testdir5 exists' -d testdir5
@test 'restore testdir5 has file1' -f testdir5/file1.txt
@test 'restore testdir5 not nested' ! -d testdir5/testdir5.bak
@test 'restore testdir5 backup still exists' -d testdir5.bak

# Test: restore directory with -m when original already exists
rm -rf *
mkdir testdir6.bak
touch testdir6.bak/file1.txt
mkdir testdir6
touch testdir6/old.txt
bak -r -m testdir6.bak
@test 'restore -m testdir6 exists' -d testdir6
@test 'restore -m testdir6 has file1' -f testdir6/file1.txt
@test 'restore -m testdir6 not nested' ! -d testdir6/testdir6.bak
@test 'restore -m testdir6 backup removed' ! -d testdir6.bak

rm -rf $testhome
