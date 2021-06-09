#!/usr/bin/env bash

export LC_ALL=C
TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
BUILDDIR=${BUILDDIR:-$TOPDIR}

BINDIR=${BINDIR:-$BUILDDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

TIPCOIND=${BITCOIND:-$BINDIR/tipcoind}
TIPCOINCLI=${BITCOINCLI:-$BINDIR/tipcoin-cli}
TIPCOINTX=${BITCOINTX:-$BINDIR/tipcoin-tx}
TIPCOINQT=${BITCOINQT:-$BINDIR/qt/tipcoin-qt}

[ ! -x $TIPCOIND ] && echo "$TIPCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
TIPVER=($($TIPCOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$TIPCOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $TIPCOIND $TIPCOINCLI $TIPCOINTX $TIPCOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${TIPVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${TIPVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
