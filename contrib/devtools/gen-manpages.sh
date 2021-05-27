#!/usr/bin/env bash

export LC_ALL=C
TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
BUILDDIR=${BUILDDIR:-$TOPDIR}

BINDIR=${BINDIR:-$BUILDDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

TIPCOIND=${BITCOIND:-$BINDIR/tipcoind}
MONACOINCLI=${BITCOINCLI:-$BINDIR/tipcoin-cli}
MONACOINTX=${BITCOINTX:-$BINDIR/monacoin-tx}
MONACOINQT=${BITCOINQT:-$BINDIR/qt/tipcoin-qt}

[ ! -x $TIPCOIND ] && echo "$TIPCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
MONAVER=($($MONACOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$TIPCOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $TIPCOIND $MONACOINCLI $MONACOINTX $MONACOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${MONAVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${MONAVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
