/*
**  Copyright 2003-2004  The Apache Software Foundation
**
**  Licensed under the Apache License, Version 2.0 (the "License");
**  you may not use this file except in compliance with the License.
**  You may obtain a copy of the License at
**
**      http://www.apache.org/licenses/LICENSE-2.0
**
**  Unless required by applicable law or agreed to in writing, software
**  distributed under the License is distributed on an "AS IS" BASIS,
**  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
**  See the License for the specific language governing permissions and
**  limitations under the License.
*/

#ifndef APREQ_COOKIE_H
#define APREQ_COOKIE_H

#include "apreq.h"
#include "apr_tables.h"

#ifdef  __cplusplus
extern "C" {
#endif 

/**
 * Cookie and Jar functions.
 *
 * @file apreq_cookie.h
 * @brief Cookies and Jars.
 */
/**
 *@defgroup cookies Cookies (request and response)
 *@ingroup LIBRARY
 * @{
 */

/** Cookie Jar */
typedef struct apreq_jar_t {
    apr_table_t   *cookies;     /**< cookie table */
    void          *env;         /**< environment */
} apreq_jar_t;

typedef enum { NETSCAPE, RFC } apreq_cookie_version_t;

#define APREQ_COOKIE_VERSION               NETSCAPE
#define APREQ_COOKIE_LENGTH                4096

/** cookie XXX ... */
typedef struct apreq_cookie_t {

    apreq_cookie_version_t version; /**< RFC or Netscape compliant cookie */

    char           *path;
    char           *domain; 
    char           *port;
    unsigned        secure;

    char           *comment;
    char           *commentURL;
    apr_time_t      max_age;     /**< total duration of cookie: -1 == session */
    apreq_value_t   v;           /**< "raw" cookie value */

} apreq_cookie_t;


#define apreq_value_to_cookie(ptr) apreq_attr_to_type(apreq_cookie_t, \
                                                      v, ptr)
#define apreq_cookie_name(c)  ((c)->v.name)
#define apreq_cookie_value(c) ((c)->v.data)

#define apreq_jar_items(j) apr_table_elts(j->cookies)->nelts
#define apreq_jar_nelts(j) apr_table_elts(j->cookies)->nelts

/**
 * Fetches a cookie from the jar
 *
 * @param jar   The cookie jar.
 * @param name  The name of the desired cookie.
 */

APREQ_DECLARE(apreq_cookie_t *)apreq_cookie(const apreq_jar_t *jar,
                                            const char *name);

/**
 * Adds a cookie by pushing it to the bottom of the jar.
 *
 * @param jar The cookie jar.
 * @param c The cookie to add.
 */

APREQ_DECLARE(void) apreq_add_cookie(apreq_jar_t *jar, 
                                     const apreq_cookie_t *c);

/**
 * Parse the incoming "Cookie:" headers into a cookie jar.
 * 
 * @param env The current environment.
 * @param hdr  String to parse as a HTTP-merged "Cookie" header.
 * @remark "data = NULL" has special behavior.  In this case,
 * apreq_jar(env,NULL) will attempt to fetch a cached object from the
 * environment via apreq_env_jar.  Failing that, it will replace
 * "hdr" with the result of apreq_env_cookie(env), parse that,
 * and store the resulting object back within the environment.
 * This maneuver is designed to mimimize parsing work,
 * since generating the cookie jar is relatively expensive.
 *
 */


APREQ_DECLARE(apreq_jar_t *) apreq_jar(void *env, const char *hdr);

/**
 * Returns a new cookie, made from the argument list.
 * The cookie is allocated from the ctx pool.
 *
 * @param ctx   The current context.
 * @param name  The cookie's name.
 * @param nlen  Length of name.
 * @param value The cookie's value.
 * @param vlen  Length of value.
 */
APREQ_DECLARE(apreq_cookie_t *) apreq_make_cookie(apr_pool_t *pool, 
                                  const char *name, const apr_size_t nlen, 
                                  const char *value, const apr_size_t vlen);

/**
 * Sets the associated cookie attribute.
 * @param p    Pool for allocating the new attribute.
 * @param c    Cookie.
 * @param attr Name of attribute- leading '-' or '$' characters
 *             are ignored.
 * @param alen Length of attr.
 * @param val  Value of new attribute.
 * @param vlen Length of new attribute.
 * @remarks    Ensures cookie version & time are kept in sync.
 */
APREQ_DECLARE(apr_status_t) 
    apreq_cookie_attr(apr_pool_t *p, apreq_cookie_t *c, 
                      const char *attr, apr_size_t alen,
                      const char *val, apr_size_t vlen);


/**
 * Returns a string that represents the cookie as it would appear 
 * in a valid "Set-Cookie*" header.
 *
 * @param c The cookie.
 * @param p The pool.
 */
APREQ_DECLARE(char*) apreq_cookie_as_string(apr_pool_t *p,
                                            const apreq_cookie_t *c);

/**
 * Same functionality as apreq_cookie_as_string.  Stores the string
 * representation in buf, using up to len bytes in buf as storage.
 * The return value has the same semantics as that of apr_snprintf,
 * including the special behavior for a "len = 0" argument.
 *
 * @param c The cookie.
 * @param buf Storage location for the result.
 * @param len Size of buf's storage area. 
 */

APREQ_DECLARE(int) apreq_serialize_cookie(char *buf, apr_size_t len,
                                          const apreq_cookie_t *c);

/**
 * Get/set the "expires" string.  For NETSCAPE cookies, this returns 
 * the date (properly formatted) when the cookie is to expire.
 * For RFC cookies, this function returns NULL.
 * 
 * @param c The cookie.
 * @param time_str If NULL, return the current expiry date. Otherwise
 * replace with this value instead.  The time_str should be in a format
 * that apreq_atoi64t() can understand, namely /[+-]?\d+\s*[YMDhms]/.
 */
APREQ_DECLARE(void) apreq_cookie_expires(apreq_cookie_t *c, 
                                         const char *time_str);

/**
 * Add the cookie to the outgoing "Set-Cookie" headers.
 *
 * @param c The cookie.
 */
APREQ_DECLARE(apr_status_t) apreq_cookie_bake(const apreq_cookie_t *c, 
                                              void *env);

/* XXX: how about baking whole cookie jars, too ??? */

/**
 * Add the cookie to the outgoing "Set-Cookie2" headers.
 *
 * @param c The cookie.
 */
APREQ_DECLARE(apr_status_t) apreq_cookie_bake2(const apreq_cookie_t *c,
                                               void *env);

/**
 *
 *
 */
APREQ_DECLARE(apreq_cookie_version_t) apreq_ua_cookie_version(void *env);

/** @} */

#ifdef __cplusplus
 }
#endif

#endif /*APREQ_COOKIE_H*/


