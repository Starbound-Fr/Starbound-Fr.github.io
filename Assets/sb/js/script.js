// Random Quotes
(function() {
    // [min, max[
    function randomInt(min, max) {
        return Math.floor(Math.random() * (max - min)) + min;
    }
    var req = new XMLHttpRequest();
    req.open('GET', '/data/random-quotes.txt', true);
    req.onreadystatechange = function (aEvt) {
        if (req.readyState == 4) {
            if(req.status == 200) {
                var node = document.querySelector('#txt-aleatoire');
                var quotes = req.responseText.split('\n');
                var quote = quotes[randomInt(0, quotes.length)];
                node.innerHTML = quote;
            }
        }
    };
    req.send(null);
})();
