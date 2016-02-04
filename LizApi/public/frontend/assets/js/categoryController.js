$(document).ready(function() {
var themeCells = function() {
    var tableCells = document.getElementsByClassName('themeable');
    for(var i=0;i<tableCells.length;i++) {
        tableCells[i].style.backgroundColor = tableCells[i].innerText;
        tableCells[i].style.color = 'white';
    }
}
themeCells();
});
