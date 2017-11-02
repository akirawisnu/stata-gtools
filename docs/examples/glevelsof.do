sysuse auto
glevelsof rep78
glevelsof rep78, miss local(mylevs) silent
display "`mylevs'"
glevelsof rep78, sep(,)


*******************
*  Number format  *
*******************

* `levelsof` by default shows many significant digits for numerical variables.

sysuse auto, clear
replace headroom = headroom + 0.1
levelsof headroom
glevelsof headroom

* This is cumbersome. You can specify a number format to compress this:
glevelsof headroom, numfmt(%.3g)


************************
*  Multiple variables  *
************************

* `glevelsof` can parse multiple variables:
local varlist foreign rep78
glevelsof `varlist', sep("|") colsep(", ")

* If you know a bit of mata, you can parse this string!
mata:
string scalar function unquote_str(string scalar quoted_str)
{
    if ( substr(quoted_str, 1, 1) == `"""' ) {
        quoted_str = substr(quoted_str, 2, strlen(quoted_str) - 2)
    }
    else if (substr(quoted_str, 1, 2) == "`" + `"""') {
        quoted_str = substr(quoted_str, 3, strlen(quoted_str) - 4)
    }
    return (quoted_str);
}

t = tokeninit(`"`r(sep)'"', (""), (`""""', `"`""'"'), 1)
tokenset(t, `"`r(levels)'"')

rows = tokengetall(t)
for (i = 1; i <= cols(rows); i++) {
    rows[i] = unquote_str(rows[i]);
}

levels = J(cols(rows), `:list sizeof varlist', "")

t = tokeninit(`"`r(colsep)'"', (""), (`""""', `"`""'"'), 1)
for (i = 1; i <= cols(rows); i++) {
    tokenset(t, rows[i])
    levels[i, .] = tokengetall(t)
    for (k = 1; k <= `:list sizeof varlist'; k++) {
        levels[i, k] = unquote_str(levels[i, k])
    }
}
end

mata: levels

* While this looks cumbersome, this mechanism is used internally by
* `gtoplevelsof` to display its results.
