function sortChildren(wrap, criteria, isNum) {
    var l = wrap.children.length;
    var arr = [];

    for(var i=0; i<l; ++i) {
        arr[i] = [criteria(wrap.children[i]), wrap.children[i]];
    }

    var sort;
    if (typeof isNum === 'function') {
        sort = isNum;
    }
    else if (!isNum || typeof isNum === 'boolean') {
        sort = isNum
            ? function(a,b){ return a[0]-b[0]; }
            : function(a,b){ return a[0]<b[0] ? -1 : a[0]>b[0] ? 1 : 0; }
    }

    arr.sort(sort);
    var par = wrap.parentNode,
        ref = wrap.nextSibling;
    par.removeChild(wrap);
    for(var i=0; i<l; ++i) wrap.appendChild(arr[i][1]);
    par.insertBefore(wrap, ref);
}