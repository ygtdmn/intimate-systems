// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

import { LibString } from "solady/utils/LibString.sol";
import { Sculpture } from "../../Sculpture.sol";
import { Essay } from "../../Essay.sol";
import { Mod } from "../../Mod.sol";
import "forge-std/console2.sol";

/// @notice Renders essay pages with semantic HTML and sans-serif aesthetic
library EssayPage {
    function html(address show, address essayContract, address data) public view returns (string memory) {
        string memory showAddr = LibString.toHexStringChecksummed(show);
        Mod mod = Mod(data);
        Essay essay = Essay(essayContract);
        string[] memory urls = essay.urls();
        for (uint256 i = 0; i < urls.length; i++) {
            console2.log(urls[i]);
        }
        string memory showTitle = Sculpture(show).title();

        string memory body = string.concat(
            "<main>",
            "<nav><i>This text was published as part of the contract show: <a href=\"/\">",
            showTitle,
            "</a></i></nav>",
            "<article>",
            essay.html(),
            "</article>",
            "<footer>",
            "<address>",
            showAddr,
            "</address>",
            "<p><i>This text was published as part of the show <a href=\"/\">",
            showTitle,
            "</a></i></p>",
            "</footer>",
            "</main>"
        );

        string memory description = string.concat(
            "The essay '",
            essay.title(),
            "' written by ",
            mod.essayAuthor(),
            " was published as part of the contract show: ",
            showTitle
        );

        return _htmlDoc(body, essay.title(), description);
    }

    function _htmlDoc(
        string memory body,
        string memory title,
        string memory description
    ) internal pure returns (string memory) {
        // Base reset and typography
        string memory baseCss = "*,*::before,*::after{box-sizing:border-box}"
            "html{-moz-text-size-adjust:none;-webkit-text-size-adjust:none;text-size-adjust:none}"
            "html,body{margin:0;padding:0}"
            "body{min-height:100vh}"
            "html,body,pre,button{font-family:system-ui,-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;font-size:16px;line-height:1.6}"
            "h1{font-size:2em;font-weight:600;margin:0}"
            "h2{font-size:1.5em;font-weight:500;margin:1.5em 0 0.5em}"
            "p{margin:0}";

        // Semantic layout styling
        string memory layoutCss = "main{max-width:680px;margin:0 auto;padding:6em 20px;min-height:100vh;display:flex;flex-direction:column;gap:3em}"
            "a{color:inherit;text-decoration:underline}"
            "nav{font-style:normal}"
            "article{display:flex;flex-direction:column;gap:2em}"
            "article header{display:flex;flex-direction:column;gap:0.5em}"
            "article address{font-style:italic;font-size:1.1em}"
            "article section{line-height:1.7}"
            "article section p{margin-bottom:1.5em}"
            "footer{display:flex;flex-direction:column;gap:1em;margin-top:auto}"
            "footer>address{font-style:normal;font-size:0.85em;opacity:0.7;overflow:hidden;text-overflow:ellipsis}"
            "hr{height:1px;border:0;background:#000;margin:2em 0}";

        return string.concat(
            "<!DOCTYPE html>"
            '<html lang="en">'
            "<head>"
            '<meta charset="UTF-8">'
            '<meta name="viewport" content="width=device-width,initial-scale=1.0">'
            "<title>",
            title,
            "</title>"
            '<meta name="description" content="',
            description,
            '">'
            "<style>",
            baseCss,
            layoutCss,
            "</style>"
            "</head>"
            "<body>",
            body,
            "</body>"
            "</html>"
        );
    }
}

