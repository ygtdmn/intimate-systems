// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

import { Sculpture } from "../Sculpture.sol";

contract APlaceFound is Sculpture {
    function title() external pure returns (string memory) {
        return "a place found.";
    }

    function authors() external pure returns (string[] memory _authors) {
        _authors = new string[](1);
        _authors[0] = "diid";
    }

    function addresses() external pure returns (address[] memory _addresses) {
        _addresses = new address[](1);
        _addresses[0] = 0xcf2bF523f1FCb1aA9e9896E56F097AADC9087c5e;
    }

    function urls() external pure returns (string[] memory __) {}

    function text() external pure returns (string memory) {
        return
            "who are you? after the dust settles, after the light fades, after the noise ends. who are you? simply a placeholder? an amalgamation of memories and dreams? a ghost in the machine?";
    }
}
