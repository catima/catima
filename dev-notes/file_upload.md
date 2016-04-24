# File upload for catalogs

File upload is managed using the [refile](https://github.com/refile/refile) gem. Files have a name and an identifier which corresponds to the file name on the disc.
The files are stored in `public/system/refile`.

Image upload is also managed using the [refile](https://github.com/refile/refile) gem.
Additionally, the [refile-mini_magick](https://github.com/refile/refile-mini_magick) gem is used for image processing using [Imagemagick](http://www.imagemagick.org/) which must be installed on the host.
Image processing is done on the fly, using parameters passed in with the URL (not as arguments to the URL, but in the URL itself). Processed images are stored in a temporary directory (e.g. `/tmp`) and regularly flushed.
In a production environment, care must be taken to configure properly the Web server. E.g. in Nginx, we must remove header directives related to `X-Sendfile-Type` etc., such as:

    proxy_set_header X-Sendfile-Type X-Accel-Redirect;
    proxy_set_header X-Accel-Mapping ...;

These directives are usually stored in the virtual host file in `/etc/nginx/sites-available` or a similar location.