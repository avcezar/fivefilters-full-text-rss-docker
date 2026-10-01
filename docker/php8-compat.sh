#!/bin/sh
# Full-Text RSS 3.8 still uses PHP 7-era syntax that breaks response headers on PHP 8.
set -eu

html=/var/www/html

# The app turns display_errors on. On PHP 8 that prints deprecations into the
# response before Content-Type is sent, so clients receive HTML instead of XML.
sed -i 's/ini_set("display_errors", 1);/ini_set("display_errors", "0");/' \
  "$html/makefulltextfeed.php"

# utf8_encode() is deprecated in PHP 8.2. The warning is printed while the
# feed is still being built, so Content-Type never becomes text/xml.
sed -i \
  's/utf8_encode(\$effective_url)/mb_convert_encoding($effective_url, "UTF-8", "ISO-8859-1")/g' \
  "$html/makefulltextfeed.php"

# Same deprecation, used when guessing article language.
sed -i \
  's/utf8_decode(\$str)/mb_convert_encoding($str, "ISO-8859-1", "UTF-8")/g' \
  "$html/libraries/language-detect/LanguageDetect.php"

# PHP 8 removed $str{0} string offsets. $obj->{$name} is left alone.
sed -i -E \
  's/\$([A-Za-z_][A-Za-z0-9_]*)\{([^}]+)\}/$\1[\2]/g' \
  "$html/libraries/language-detect/LanguageDetect.php"

# Counts are stored on $_trigram, which was never declared. PHP 8.2 warns.
sed -i 's/protected \$_trigrams = array();/protected $_trigrams = array();\
    protected $_trigram = array();/' \
  "$html/libraries/language-detect/LanguageDetect/Parser.php"
