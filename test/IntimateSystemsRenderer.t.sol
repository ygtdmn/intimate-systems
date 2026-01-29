// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

import "forge-std/Test.sol";
import "../src/Mod.sol";
import "../src/Essay.sol";
import "../src/IntimateSystems.sol";
import "../src/web/WebRenderer.sol";
import "../src/lib/Web3url.sol";

contract WebRendererTest is Test {
    function testResolveMode() public {
        (WebRenderer renderer, , ) = setup();
        assertEq(renderer.resolveMode(), bytes32("5219"));
    }

    function testRequestIndex() public {
        (WebRenderer renderer, Mod data, ) = setup();
        data.setExplorerBase("https://example.com/address/");

        string[] memory resource = new string[](0);
        KeyValue[] memory params = new KeyValue[](0);
        (uint statusCode, string memory body, KeyValue[] memory headers) = renderer.request(resource, params);

        assertEq(statusCode, 200);
        assertEq(headers.length, 1);
        assertEq(headers[0].key, "Content-Type");
        assertEq(headers[0].value, "text/html; charset=utf-8");
        assertTrue(bytes(body).length > 0);
        assertTrue(contains(body, "https://example.com/address/"));
    }

    function testRequestEssay() public {
        (WebRenderer renderer, , ) = setup();
        string[] memory resource = new string[](1);
        resource[0] = "essay";
        KeyValue[] memory params = new KeyValue[](0);
        (uint statusCode, string memory body, KeyValue[] memory headers) = renderer.request(resource, params);

        assertEq(statusCode, 200);
        assertEq(headers.length, 1);
        assertEq(headers[0].key, "Content-Type");
        assertEq(headers[0].value, "text/html; charset=utf-8");
        assertTrue(bytes(body).length > 0);
    }

    function setup() internal returns (WebRenderer renderer, Mod data, Essay essay) {
        data = new Mod();
        essay = new Essay();
        Sculpture[] memory sculptures = new Sculpture[](0);
        SculptureERC721[] memory sculptureERC721s = new SculptureERC721[](0);
        IntimateSystems show = new IntimateSystems(
            sculptures,
            sculptureERC721s,
            WebRenderer(address(0)),
            Mod(address(data))
        );
        renderer = new WebRenderer(address(show), address(essay), address(data));
    }

    function contains(string memory haystack, string memory needle) internal pure returns (bool) {
        bytes memory h = bytes(haystack);
        bytes memory n = bytes(needle);
        if (n.length == 0) {
            return true;
        }
        if (h.length < n.length) {
            return false;
        }
        for (uint256 i = 0; i <= h.length - n.length; i++) {
            bool matchFound = true;
            for (uint256 j = 0; j < n.length; j++) {
                if (h[i + j] != n[j]) {
                    matchFound = false;
                    break;
                }
            }
            if (matchFound) {
                return true;
            }
        }
        return false;
    }
}
