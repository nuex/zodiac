# zodiac

ZODIAC is a static website generator powered by sh and awk. The core features of zodiac are:

* utliization of existing tools (i.e. awk, sh, find, etc.)
* supports using plain html
* built-in support for markdown
* a simple, easy to use templating system
* supports custom helpers written in awk
* configuration, meta, helpers, etc. can be added as you need them
* convert your markup using any external command that accepts a UNIX-style pipe (smu, asciidoc, discount, rst2html, etc)

## SYNOPSIS

    zod projectdir targetdir

## INSTALL

    git clone git://github.com/nuex/zodiac.git
    
Edit the config.mk file to customize the install paths. `/usr/local` is the default install prefix.

Run the following (as root if necessary):

    make install

## DESCRIPTION

A typical Zodiac project will look something like this:

    site/
      index.md
      index.meta
      main.layout
      global.meta
      projects/
        project-1.md
        project-1.meta
        project-2.md
        project-2.meta
      cv.md
      cv.meta
      stylesheets/
        style.css

And it's output could look like this:

    site/
      index.html
      projects/
        project-1.html
        project-2.html
      cv.html
      stylesheets/
        style.css

### Meta

`.meta` files contain a key / value pair per line. A key and its value must be separated by a ": ". A metafile looks like this:

    this: that
    title: Contact
    author: Me

Each page can have its own meta file. The only requirement is that the meta file is in the same directory as the page, has the same name as the page and has the `.meta` file extension.

The optional `global.meta` file contains data that is available to all of your site's pages, like a site title.

Page metadata will always override global metadata of the same key.

### Templates

Templates come in two forms, page templates and layout templates. Metadata can be bound to templates by using the `{{key}}` notation in your pages and layout files.

Page templates can have any extension that zodiac can convert. Out of the box, page templates can have an `md`, `htm`, or `html` extension. Other extensions and markup types can be supported if they are configured in the `.zod/config` file in the project directory.

The `main.layout` file wraps HTML content around a page template.  A `main.layout` file could look something like this:

    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <link rel="stylesheet" href="/stylesheets/style.css" />
        <title>{{page_title}}</title>
      </head>
      <body>
        <header>
          <h1><a href="/">{{site_title}}</a></h1>
        </header>
        <article>
          {{{yield}}}
        </article>
        <footer>
          <p>powered by static files, compiled by <a href="http://nu-ex.com/projects/zodiac">zodiac</a>.</p>
        </footer>
      </body>
    </html>

`{{{yield}}}` is a special tag that renders the page content within the layout. `{{{yield}}}` can only be used in the `main.layout` file.

### Helpers

The `helpers.awk` file is an awk script that can make custom data available to your templates. You also have access to the page and global data. Here is a peak at the script included in the examples folder:

    { helpers = "yes" }

    function load_helpers() {
      # your custom data settings
      data["page_title"] = page_title()
    }

    # your custom functions
    function page_title(  title) {
      if (data["title"]) {
        title = data["title"] " - " data["site_title"]
      } else {
        title = data["site_title"]
      }
      return title
    }

Just be sure to set the data array in the `load_helpers()` function at the top of the script to make your custom data available to the template.

### Config

For more control over the parsing and conversion process, a `.zod/config` file can be created within your project directory. Here is a sample config:

    [parse]
    htm,html

    [parse_convert]
    md      smu
    txt     asciidoc -s -

    [ignore]
    Makefile

Here we're only parsing (not converting to a different format) files matching `*.htm` and `*.html`.

Files matching `*.md` are going to be parsed and converted using the `smu` markdown parsing program.

Files matching `*.txt` are going to be parsed and converted using `asciidoc`.

Files matching `Makefile` will be ignored and not copied.

Conversion programs must accept a UNIX-style pipe and send converted data to stdout.

## CREDITS

* zsw: for the introduction to parameter expansion and other shell scripting techniques

## LICENSE

MIT
