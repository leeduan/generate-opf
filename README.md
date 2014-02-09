## Generate OPF

Creates an `*.opf` file for your ePub 3.0 e-book by scanning through `OPS` and its children.

## Getting Started

1. Clone the [repository](https://github.com/leeduan/generate-opf.git).
2. Check that ruby is installed (tested on v2.0.0 and higher).
```
    ruby -v
```
3. Check that the `container.xml` file located in `META-INF` directory has a full-path specified:
```
    <rootfile full-path="OPS/content.opf" media-type="application/oebps-package+xml" />
```
4. `mv` the `generate_opf.rb` file into your ePub's `OPS` directory.
5. `cd` into your `OPS` directory.
6. Run the program with the command:
```
    ruby generate_opf.rb
```
7. `rm` the `generate_opf.rb` file from `OPS` directory.
8. Reorder spine items if desired e-book order is not in file-name ascending order.
9. Package up ePub and check for errors using [ePub Checker](https://github.com/IDPF/epubcheck).

## ePub Requirements

1. Folder structure must be in ePub 3.0 format.
2. All e-book content files must exist within `OPS` and its children.
3. All text files to be added to spine must be `*.xhtml` and exist in or down one directory relative to `OPS`:
  * `/OPS/Text/page_0001.xhtml` is supported.
  * `/OPS/page_0001.xhtml` is supported.
  * `/OPS/Chapters/Texts/page_0001.xhtml` is not supported.
  * `/OPS/page_0001.html` is not supported.
4. Naming convention of table of content files should be:
  * `toc.xhtml` is preferred; a file following `*toc.xhtml` naming convention is supported.
  * `toc.ncx` is optional fallback and not required for ePub 3.0 validation.
5. Files with extensions not listed below will not be added to the OPF file.
6. Additional rendition settings are not generated.

## File Extension Compatibility

* Images: jpeg, jpg, png, gif, svg
* Fonts: eot, woff, ttf, otf
* JavaScript: js
* Video: m4v, mp4, mov
* Audio: mp3, m4a
* Text: html, xhtml
* TOC: ncx, xhtml

## License

Generate OPF is released under the [MIT License](http://www.opensource.org/licenses/MIT).

## Issues

Please report an issue if you run into any bugs or have feature requests.