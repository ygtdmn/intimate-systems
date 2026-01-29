// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

import { Sculpture } from "../Sculpture.sol";

contract KOD is Sculpture {
    function title() external pure returns (string memory) {
        return "KALEIDOSCOPE OF ORCHESTRATED DISSONANCE";
    }

    function authors() external pure returns (string[] memory _authors) {
        _authors = new string[](1);
        _authors[0] = "FelixFelixFelix";
    }

    function addresses() external pure returns (address[] memory _addresses) {
        _addresses = new address[](1);
        _addresses[0] = 0x73469b3f8b9DEb8dC15724Dee8919Aac98605782;
    }

    function urls() external pure returns (string[] memory __) {}

    function text() external pure returns (string memory) {
        return
            "We live in networks we can't fully control, yet coordination can make a difference. A network is just a set of rules until a human interaction comes into play, like rocks drifting the water flow to new territories. This interactive work grants all the bidders a privilege: the possibility to control one point of view. It can be moved around, locked in place, or released to the blockchain stream. Every move has an impact, even the slightest, fragmenting or merging. It's constantly changing until viewers decide it should stop. This is when they can agree, each keeping their different point of view. And when someone finally wants to preserve that moment, everyone loses control and it starts all over again. A dissensus based consensus, an orchestrated dissonance. HOW IT WORKS Use the nav buttons to select one point of view, move it around using the keyboard (ZQSDAE or WASDQE), lock it and release it. Once more than half of the 16 points of view are simultaneously locked, the mint of an edition token is unlocked. All viewers that contributed to reaching the majority by locking their point of view will receive an edition. After the mint, all points of view will be released again.";
    }
}
