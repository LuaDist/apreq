/* ====================================================================
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) 2003 The Apache Software Foundation.  All rights
 * reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The end-user documentation included with the redistribution,
 *    if any, must include the following acknowledgment:
 *       "This product includes software developed by the
 *        Apache Software Foundation (http://www.apache.org/)."
 *    Alternately, this acknowledgment may appear in the software itself,
 *    if and wherever such third-party acknowledgments normally appear.
 *
 * 4. The names "Apache" and "Apache Software Foundation" must
 *    not be used to endorse or promote products derived from this
 *    software without prior written permission. For written
 *    permission, please contact apache@apache.org.
 *
 * 5. Products derived from this software may not be called "Apache",
 *    nor may "Apache" appear in their name, without prior written
 *    permission of the Apache Software Foundation.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE APACHE SOFTWARE FOUNDATION OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation.  For more
 * information on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
 */


#include "apreq.h"
#include "apreq_env.h"
#include "apreq_params.h"
#include "apreq_parsers.h"
#include "apreq_cookie.h"
#include "apr_strings.h"
#include "apr_lib.h"
#include "apr_tables.h"

typedef struct env_ctx {
    apr_pool_t         *pool;
    apreq_request_t    *req;
    apreq_jar_t        *jar;
    apr_bucket_brigade *bb;
    int                 loglevel;
    apr_status_t        status;
} env_ctx;

static int dump_table(void *ctx, const char *key, const char *value)
{
    env_ctx *c = (env_ctx *) ctx;
    apreq_log(APREQ_DEBUG 0, c, "%s => %s", key, value);
    printf("\t%s => %s\n", key, value);
    return 1;
}

int main(void)
{
    apreq_request_t *req;
    env_ctx *ctx;
    apr_pool_t *pool;
    if (apr_initialize() != APR_SUCCESS) {
        fprintf(stderr, "apr_initialize failed\n");
        exit(-1);
    }
    if (apr_pool_create(&pool, NULL) != APR_SUCCESS) {
        fprintf(stderr, "apr_pool_create failed\n");
        exit(-1);
    }
    ctx = (env_ctx *) apr_palloc(pool, sizeof(*ctx));
    ctx->loglevel = 0;
    ctx->pool = pool;
    apreq_log(APREQ_DEBUG 0, ctx, "%s", "Creating apreq_request");
    req = apreq_request(ctx, NULL);
    printf("%s", "Content-Type: text/plain\n\n");
    apreq_log(APREQ_DEBUG 0, ctx, "%s", "Fetching the parameters");
    printf("ARGS:\n");
    apr_table_do(dump_table, ctx, req->args, NULL);
    if (req->body) {
        printf("BODY:\n");
        apr_table_do(dump_table, ctx, req->body, NULL);
    }
    
    apreq_log(APREQ_DEBUG 0, ctx, "%s", "Done!");
    return 0;
}
