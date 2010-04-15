(function(jQuery) {
    function cellColumn(cell) {
        return jQuery(cell).index();
    }

    function collapseCell($table, cell) {
        var $cell = jQuery(cell);

        var $dialog = $cell.find('.attr_editor').dialog({
            autoOpen: false,
            buttons: { "OK": function() { jQuery(this).dialog('close'); } }
        });
        $cell.find('.attr_current_value').show();

        $cell.addClass('expand_edit');
        $cell.bind("click", function(evt) {
            var column = cellColumn($cell);
            var field = jQuery.trim($table.find('thead th').eq(column).text());
            var doc = jQuery.trim($cell.siblings().eq(0).find('input').val());

            $dialog.dialog('option', 'title', field +" for "+doc);
            $dialog.dialog('open');
        });
    }

    function gridKeyDown(evt) {
        var $this = jQuery(this);
        var $table = evt.data;
        var $targetCell;
        switch (evt.keyCode) {
        case 37:
                $targetCell = $this.siblings().eq(cellColumn($this) - 1);
        break;
        case 38:

        break;
        case 39:
                $targetCell = $this.siblings().eq(cellColumn($this) + 1);
        break;
        case 40:
        break;
        }

        console.log($targetCell);
    }

    jQuery.fn.vellumGridEditor = function() {
        var $cells = this.find('td.attr');
        var $collapseCells = $cells.has('.attr_editor:not(.text)');
        var $table = this;

        $collapseCells.each(function() { collapseCell($table, this) });
        this.children('tbody').children('tr').children('td').bind('keyDown', $table, gridKeyDown);

        return this;
    }
})(jQuery);