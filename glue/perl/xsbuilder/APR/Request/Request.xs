static XS(apreq_xs_parse)
{
    dXSARGS;
    apreq_handle_t *req;
    apr_status_t s;
    const apr_table_t *t;

    if (items != 1 || !SvROK(ST(0)))
        Perl_croak(aTHX_ "Usage: APR::Request::parse($req)");

    req = apreq_xs_sv2handle(aTHX_ ST(0));

    XSprePUSH;
    EXTEND(SP, 3);
    s = apreq_jar(req, &t);
    PUSHs(sv_2mortal(apreq_xs_error2sv(aTHX_ s)));
    s = apreq_args(req, &t);
    PUSHs(sv_2mortal(apreq_xs_error2sv(aTHX_ s)));
    s = apreq_body(req, &t);
    PUSHs(sv_2mortal(apreq_xs_error2sv(aTHX_ s)));
    PUTBACK;
}



MODULE = APR::Request     PACKAGE = APR::Request

SV*
encode(in)
    SV *in
  PREINIT:
    STRLEN len;
    char *src;
  CODE:
    src = SvPV(in, len);
    RETVAL = newSV(3 * len);
    SvCUR_set(RETVAL, apreq_encode(SvPVX(RETVAL), src, len));
    SvPOK_on(RETVAL);

  OUTPUT:
    RETVAL

SV*
decode(in)
    SV *in
  PREINIT:
    STRLEN len;
    apr_size_t dlen;
    char *src;
  CODE:
    src = SvPV(in, len);
    RETVAL = newSV(len);
    apreq_decode(SvPVX(RETVAL), &dlen, src, len); /*XXX needs error-handling */
    SvCUR_set(RETVAL, dlen);
    SvPOK_on(RETVAL);
  OUTPUT:
    RETVAL

SV*
read_limit(req, val=NULL)
    APR::Request req
    SV *val
  PREINIT:
    /* nada */
  CODE:
    if (items == 1) {
        apr_status_t s;
        apr_uint64_t bytes;
        s = apreq_read_limit_get(req, &bytes);     
        if (s != APR_SUCCESS) {
            SV *sv = ST(0), *obj = ST(0);
            APREQ_XS_THROW_ERROR(r, s, 
                   "APR::Request::read_limit", "APR::Request::Error");
            RETVAL = &PL_sv_undef;
        }
        else {
            RETVAL = newSVuv(bytes);
        }
    }
    else {
        apr_status_t s = apreq_read_limit_set(req, SvUV(val));
        if (s != APR_SUCCESS) {
            if (GIMME_V == G_VOID) {
                SV *sv = ST(0), *obj = ST(0);
                APREQ_XS_THROW_ERROR(r, s, 
                    "APR::Request::read_limit", "APR::Request::Error");
            }
            RETVAL = &PL_sv_no;
        }
        else {
            RETVAL = &PL_sv_yes;
        }
    }

  OUTPUT:
    RETVAL

SV*
brigade_limit(req, val=NULL)
    APR::Request req
    SV *val
  PREINIT:
    /* nada */
  CODE:
    if (items == 1) {
        apr_status_t s;
        apr_size_t bytes;
        s = apreq_brigade_limit_get(req, &bytes);     
        if (s != APR_SUCCESS) {
            SV *sv = ST(0), *obj = ST(0);
            APREQ_XS_THROW_ERROR(r, s, 
                   "APR::Request::brigade_limit", "APR::Request::Error");
            RETVAL = &PL_sv_undef;
        }
        else {
            RETVAL = newSVuv(bytes);
        }
    }
    else {
        apr_status_t s = apreq_brigade_limit_set(req, SvUV(val));
        if (s != APR_SUCCESS) {
            if (GIMME_V == G_VOID) {
                SV *sv = ST(0), *obj = ST(0);
                APREQ_XS_THROW_ERROR(r, s, 
                    "APR::Request::brigade_limit", "APR::Request::Error");
            }
            RETVAL = &PL_sv_no;
        }
        else {
            RETVAL = &PL_sv_yes;
        }
    }

  OUTPUT:
    RETVAL


SV*
temp_dir(req, val=NULL)
    APR::Request req
    SV *val
  PREINIT:
    /* nada */
  CODE:
    if (items == 1) {
        apr_status_t s;
        const char *path;
        s = apreq_temp_dir_get(req, &path);     
        if (s != APR_SUCCESS) {
            SV *sv = ST(0), *obj = ST(0);
            APREQ_XS_THROW_ERROR(r, s, 
                   "APR::Request::temp_dir", "APR::Request::Error");
            RETVAL = &PL_sv_undef;
        }
        else {
            RETVAL = (path == NULL) ? &PL_sv_undef : newSVpv(path, 0);
        }
    }
    else {
        apr_status_t s = apreq_temp_dir_set(req, SvPV_nolen(val));
        if (s != APR_SUCCESS) {
            if (GIMME_V == G_VOID) {
                SV *sv = ST(0), *obj = ST(0);
                APREQ_XS_THROW_ERROR(r, s, 
                    "APR::Request::temp_dir", "APR::Request::Error");
            }
            RETVAL = &PL_sv_no;
        }
        else {
            RETVAL = &PL_sv_yes;
        }
    }

  OUTPUT:
    RETVAL

SV*
jar_status(req)
    APR::Request req
  PREINIT:
    const apr_table_t *t;

  CODE:
    RETVAL = apreq_xs_error2sv(aTHX_ apreq_jar(req, &t));

  OUTPUT:
    RETVAL

SV*
args_status(req)
    APR::Request req
  PREINIT:
    const apr_table_t *t;

  CODE:
    RETVAL = apreq_xs_error2sv(aTHX_ apreq_args(req, &t));

  OUTPUT:
    RETVAL

SV*
body_status(req)
    APR::Request req
  PREINIT:
    const apr_table_t *t;

  CODE:
    RETVAL = apreq_xs_error2sv(aTHX_ apreq_body(req, &t));

  OUTPUT:
    RETVAL

SV*
disable_uploads(req, pool)
    APR::Request req
    APR::Pool pool
  PREINIT:
    apreq_hook_t *h;
    apr_status_t s;
  CODE:
    h = apreq_hook_make(pool, apreq_hook_disable_uploads, NULL, NULL);
    s = apreq_hook_add(req, h);
    RETVAL = apreq_xs_error2sv(aTHX_ s);

  OUTPUT:
    RETVAL