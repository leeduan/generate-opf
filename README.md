## Generate OPF

Creates a `content.opf` file for your ePub 3.0 e-book by scanning through the OPS and inner directories.

## Getting Started

1. Clone the [repository](https://github.com/leeduan/generate-opf.git).
2. Check that ruby is installed (tested on v2.0.0 and higher).
```
    ruby -v
```
3. `mv` the `generate_opf.rb` file into your ePub's `OPS` directory.
4. `cd` into your `OPS` directory.
5. Run the program with the command:
```
    ruby generate_opf.rb
```
6. `rm` the `generate_opf.rb` file from `OPS` directory.
7. Reorder spine items if desired e-book order is not in file-name ascending order.
8. Package up ePub and check errors using [ePub Checker](https://github.com/IDPF/epubcheck).

## ePub Requirements

1. Folder structure must be in ePub 3.0 format.
2. All e-book files must exist within `OPS` and its child directories.
3. All XHTML files to be added to spine must exist in or down one directory relative to `OPS`:
  * `/OPS/Text/page_0001.xhtml` is supported.
  * `/OPS/page_0001.xhtml` is supported.
  * `/OPS/Chapters/Texts/page_0001.xhtml` is not supported.
  * `/OPS/Chapters/Texts/text.html` is not supported.
4. Naming convention of table of content files should be:
  * `toc.xhtml` is preferred although a file following `*toc.xhtml` naming convention will work.
  * `toc.ncx` is optional fallback and not required for ePub 3.0 validation.
5. Files with extensions not listed below will not be added to the OPF file.

## File Extension Compatibility

* Images: jpeg, jpg, png, gif, svg
* Fonts: eot, woff, ttf, otf
* JavaScript: js
* Video: m4v, mp4
* Audio: mp3, m4a
* Text: html, xhtml
* TOC: ncx, xhtml

## License

Generate OPF is released under the [MIT License](http://www.opensource.org/licenses/MIT).

## Issues

Please report an issue if you run into any bugs or have feature requests.