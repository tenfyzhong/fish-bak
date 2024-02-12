# fish-bak
[![GitHub tag](https://img.shields.io/github/tag/tenfyzhong/fish-bak.svg)](https://github.com/tenfyzhong/fish-bak/tags)
[![CI](https://github.com/tenfyzhong/fish-bak/actions/workflows/test.yml/badge.svg)](https://github.com/tenfyzhong/fish-bak/actions/workflows/test.yml)
A command to bak and restore files

# usage
```
bak: Backup file/directory
Usage: bak [options] <file/directory>

Options:
  -i/--interactive     prompt before overwrite
  -t/--time            add time to backup file name
  -m/--mv              use mv to bak/restore file/directory
  -r/--restore         restore file/directory
  -s/--suffix SUFFIX   special a suffix, default: ".bak"
  -h/--help            print this help message
```

# install
Install using Fisher(or other plugin manager):
```
fisher install tenfyzhong/fish-bak
```

