---
title: web缓存小记
date: 2019-03-09 18:24:13
tags: web
---

缓存分类：

1. 浏览器缓存
2. CDN 缓存
3. 代理服务器缓存
4. 数据库缓存

浏览器缓存分为强缓存和协商缓存，强缓存不用发送请求到服务端，使用过期时间来判断是否取本地缓存，如果本地缓存到期后，使用协商缓存，如果服务器端认为缓存资源仍有效，则返回304告诉浏览器继续使用本地的缓存。

强缓存在network里状态码200（from disk cache/ from memroy cache）

协商缓存状态码为304 not modified

### 1. 强缓存

- **Cache-Control**
    1. **`max-age`** 设置缓存最大的有效时间，以秒为单位，例：`Cache-Control: max-age=2592000`，在这个时间以内，即使服务器端资源发生了变化，浏览器也不会从服务器重新请求。
    2. `s-maxage` 用于共享缓存（CDN缓存），在设置时间内，即使CDN内容发生了变化，浏览器也不会去请求最新，这个设置会覆盖`max-age`和`expries` 。
    3. `public`可以在多用户之间共享的缓存。
    4. `private`私有缓存，不能被共享，在有http认证的情况下，大多数都为这个值。
    5. `no-cache` 并不是不缓存，而是表示每次请求必须先与服务器确认返回的响应是否发生了变化，然后再处理响应，如果同时存在`E-tag`属性，就会发起此验证。如果要设置不缓存，需要加入额外参数，例：`Cache-Control: private, no-cache, max-age=0`，或者同时设置Expries为一个过去的时间。
    6. `no-store` 表示禁止缓存，每次都强制去服务器请求资源。
    7. `must-revalidate` 表示如果页面过期，则去服务器取。
- **Expries**

    缓存过期时间，存在于响应头中，和`Last-modified`配合使用，表示一个服务器端具体的时间点，值等于max-age加上请求的时间，在这个时间内浏览器可以直接缓存数据，不用再次请求，但是优先级低于`Cache-Control`，如果同时存在，会被覆盖。

    ![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/c09913cb-949c-4006-9b59-de00be0a6ac3/untitled?AWSAccessKeyId=ASIAT73L2G45ECIIVWNE&Expires=1552213598&Signature=7ttKzYJE4p%2FiU6RNDFno9OzOg4M%3D&response-content-disposition=filename%20%3D%22untitled%22&x-amz-security-token=FQoGZXIvYXdzELf%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaDL%2F3v9ikx%2BYwRiru%2FCK3AxYC3kKDKiXSEUaf4S5mIQhMc%2FitdhN%2F1TNUcGgrG0Bh5bhf8Ln2AH4qqUF%2By0jDL%2F9wwOb7EhTCce4CvixGC2EApdi53IrPSUmKVOgctksdJ2XsmHZAKxXthfMsBA6GF1J5u4YJ27uv%2BCEN0B915qF8BIHoJORYBEoJ8TASmbTU5awuP5i8oI3OcnoNUYaNZ2mNoUHyMJxwMVF4hNh%2F%2BDmFu6JvDzCM8zs435L21Y2mXao46wE%2FmItr224l2lFmdO0U3H5ZDHP7TgoIRU6iojpBFzXhFDX2k8TA5XwDntmtiQDkbjbS%2BVFZIiiNRMv26vFCeq7Izl4tKD6I9aCaOkF3G7vNEZuPrSmozDfPKiTp0ucURCabDulL%2BKUpsmDgtpE9tWpcuSaUm37NlsimolXOYP0V5qbymTQvSfF4qhOwrKIs6jSobN%2FjDRTGvVJpet12cgXddZzCEex8AN1pIgwsYRnmNMDH5N8pPkvwTboTiMaXxm043WYz835l6cgOGAPb9B04T9lbK0nZ3Xb8Q%2BN55c8F%2B9Qn80mP89en33dwduYt1KS02TkkU9LkssY%2F6y3ni62ERo8ovqeN5AU%3D)

- Cache-Control是HTTP1.1 的新的属性，默认优先级较高

### 2. 协商缓存

- **Last-Modified**

    服务器端文件修改的最后时间，配合`Cache-Control`使用，用来检查服务端资源是否更新。发起检查时，请求头里用`If-Modified-Since` 询问该时间点以后资源是否更新，如果没有更新，响应状态码为304，继续使用缓存，如果有更新则取服务器最新资源，响应码为200。

- **ETag**

    一串hash值，类似于指纹，由服务器产生并返回，标识资源状态，浏览器会检测是否存在此属性，在下一次请求时使用`If-None-Match` ，服务器根据资源核对hash值，如果没发生改变，则返回304（并在响应头附加缓存时间戳`max-age=xxx`）。

- 为什么有Last-Modified还要有ETag？因为有时候资源确实改变了，但是修改时间并没有发生改变，而且Last-Modified是精确到秒，如果很频繁的资源改动并不适用，而ETag是基于内容的hash。

### 3. 最佳实践

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/eca9dc56-084b-4fbf-b4a2-2b800861142f/untitled?AWSAccessKeyId=ASIAT73L2G45FISWG66G&Expires=1552213632&Signature=6NW2kDyldadBcWN4f5tDVcJJ9zc%3D&response-content-disposition=filename%20%3D%22untitled%22&x-amz-security-token=FQoGZXIvYXdzELf%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaDIoAvE3%2BvrM8JHt0hSK3A%2Bhoo%2Bo7lF2NBNj4MCOv2q1H4FCseBz0D9SqNo6rIQmtR32gjzg%2B5VvXipOoLB8HFJMB7lEmYbHgegrrx4%2B5Z%2Fbv0WFHPAF9zQ99%2B1JSCAK1YeV44p7pmWJ5iiT5LkuY2OyoXL%2FRjGHT1Pe1QoxRCjrHl3LerdJv0bj2em6dQZvkQB1iohJx1iA%2B%2FViTLIH5B%2Bn%2BPaELXrxl5jwVNrBmreJ4ljHNincSIrTYnRh27EMI%2BCzYKgrV7z4%2FzI3rjB6PQAe8r13RpGdH9ooEbz%2Fb3X%2FU5iLqiVVkJQzR%2FHgmvKqMBsW4DwGtfKFECwNTYiVT9PUMB4SksmX6RRuS9oy8w8IN5s1K5%2F02KLyc6QnfiOwFfMo442ZlRTQEZqyhi%2Bin0Y%2BJ05cq05J657%2B6%2FzA8rwW6iw7XA6b1xkDx0Ewr0nlAPoqQUmrB5I72RgoV61FjYz%2FiZRzjXFbYLxCxOqE5d%2F2W%2B8z%2FrEbE37Z0BFeGxJfQKNte8zZ6ICMyB5ZVVZaVpWQQfygYH4xHXPo2jSRHdLE7bDS%2BM0sF2GbYuBpnF8IefU%2BFTo%2Fn6IKkbwOow3Yx2H2Iol%2FFHkgo2ayN5AU%3D)

> [http://www.alloyteam.com/2016/03/discussion-on-web-caching/](http://www.alloyteam.com/2016/03/discussion-on-web-caching/)

> [https://developers.google.com/web/fundamentals/performance/optimizing-content-efficiency/http-caching?hl=zh-cn](https://developers.google.com/web/fundamentals/performance/optimizing-content-efficiency/http-caching?hl=zh-cn)
