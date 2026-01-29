// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

library Layout {
    function html(
        string memory body,
        string memory title,
        string memory description,
        string memory pageCss
    ) external pure returns (string memory) {
        string memory css = "*{margin:0;padding:0;box-sizing:border-box;word-break:break-word}"
        "body{font-family:sans-serif;font-size:1.15rem;line-height:1.7;background:#fff;color:#222;--border-color:rgba(0,0,0,0.2)}"
        "iframe{display:block;border:0;background:transparent;width:100%;aspect-ratio:1/1}"
        "article p+p{margin-top:1em}"
        "a,h1,h2,h3,h4,h5,h6{filter:brightness(0.5)}"
        "a{color:inherit;text-decoration:none;border-bottom:1px solid var(--border-color)}"
        "a:hover,a:focus{--border-color:rgba(0,0,0,0.6)}"
        "h1,h2,h3,h4,h5,h6{font-weight:300;letter-spacing:-0.0625rem}";

        return
            string.concat(
                "<!DOCTYPE html>"
                '<html lang="en">'
                "<head>"
                '<meta charset="UTF-8">'
                '<meta name="viewport" content="width=device-width, initial-scale=1.0">'
                "<title>",
                title,
                "</title>"
                '<meta name="description" content="',
                description,
                '" />'
                "<style>",
                css,
                pageCss,
                "</style>"
                "</head>"
                "<body>",
                body,
                "</body>"
                "</html>"
            );
    }
}
