AC_DEFUN(AC_APREQ, [
	AC_ARG_WITH(apache2-apxs,
		[  --with-apache2-apxs  path to apache2's apxs],
		[APACHE2_APXS=$withval],
		[APACHE2_APXS="/usr/local/apache2/bin/apxs"])
	AC_ARG_WITH(perl,
		[  --with-perl  path to perl executable],
		[PERL=$withval],
		[PERL="perl"])
        APU_CONFIG=`$APACHE2_APXS -q APU_BINDIR`/apu-config
        APR_CONFIG=`$APACHE2_APXS -q APR_BINDIR`/apr-config
	APACHE2_INCLUDES=`$APACHE2_APXS -q INCLUDEDIR`
        APACHE2_MODULES=`$APACHE2_APXS -q LIBEXECDIR`
        APACHE2_LIBS=`$APACHE2_APXS -q LIBDIR`
        APR_INCLUDES=`$APR_CONFIG --includedir`
        APU_INCLUDES=`$APU_CONFIG --includedir`
        APR_LIBS=`$APR_CONFIG --link-ld --link-libtool`
        APU_LIBS=`$APU_CONFIG --link-ld --link-libtool`
        AC_SUBST(APU_CONFIG)
        AC_SUBST(APR_CONFIG)
        AC_SUBST(APACHE2_APXS)
	AC_SUBST(APACHE2_INCLUDES)
        AC_SUBST(APACHE2_MODULES)
        AC_SUBST(APACHE2_LIBS)
        AC_SUBST(APR_INCLUDES)
        AC_SUBST(APU_INCLUDES)
        AC_SUBST(APR_LIBS)
        AC_SUBST(APU_LIBS)
        AC_SUBST(PERL)
])

AC_DEFUN(APR_ADDTO,[
  if test "x$$1" = "x"; then
    echo "  setting $1 to \"$2\""
    $1="$2"
  else
    apr_addto_bugger="$2"
    for i in $apr_addto_bugger; do
      apr_addto_duplicate="0"
      for j in $$1; do
        if test "x$i" = "x$j"; then
          apr_addto_duplicate="1"
          break
        fi
      done
      if test $apr_addto_duplicate = "0"; then
        echo "  adding \"$i\" to $1"
        $1="$$1 $i"
      fi
    done
  fi
])

