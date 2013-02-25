// WYMeditor.XhtmlSaxListener.prototype.removeEmptyTags = function(xhtml)
// {
//     // patch WYMeditor to allow empty paragraphs (and always just stick a single nbsp in them)
//     xhtml = xhtml.replace(new RegExp('<('+this.block_tags.join("|").replace(/\|td/,'').replace(/\|p/,'').replace(/\|th/, '')+')>(<br \/>|&#160;|&nbsp;|\\s)*<\/\\1>' ,'g'),'');
//     xhtml = xhtml.replace(new RegExp('<p>(&#160;|&nbsp;|\\s)*<\/p>', 'g'), '<p>&nbsp;</p>');
//     return xhtml;
// };