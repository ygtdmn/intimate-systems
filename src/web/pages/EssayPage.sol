// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

import { LibString } from "solady/utils/LibString.sol";
import { Sculpture } from "../../Sculpture.sol";
import { Essay } from "../../Essay.sol";
import { Mod } from "../../Mod.sol";
import { Layout } from "../Layout.sol";

// TODO
library EssayPage {
    function html(address show, address essayContract, address data) public view returns (string memory) {
        string memory showAddr = LibString.toHexStringChecksummed(show);
        Mod mod = Mod(data);

        string memory body = string.concat(
            "<header>"
            "<p><i>This text was published as part of the contract show: "
            '<a href="/">',
            Sculpture(show).title(),
            "</a>"
            "</i></p>"
            "</header>"
            "<main>"
            "<article>",
            Essay(essayContract).html(),
            "</article>"
            "<footer>"
            '<a href="',
            mod.explorerBase(),
            showAddr,
            '" target="_blank" rel="noopener">',
            showAddr,
            "</a>"
            "</footer>"
            "</main>"
        );

        string memory description = string.concat(
            'The essay "',
            Essay(essayContract).title(),
            '" written by ',
            mod.essayAuthor(),
            " was published as part of the contract show: ",
            Sculpture(show).title()
        );

        string memory pageCss = "body{max-width:680px;margin:0 auto 14em;padding:2em 0.75em}"
        "header{margin-bottom:4em}"
        "article{line-height:1.8}"
        "footer{margin-top:4em;font-size:0.8em}";

        return Layout.html(body, Essay(essayContract).title(), description, pageCss);
    }
}
