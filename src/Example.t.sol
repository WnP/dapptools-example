pragma solidity ^0.4.24;

import "ds-test/test.sol";

import "./Example.sol";

contract ExampleTest is DSTest {
    Example example;

    function setUp() public {
        example = new Example();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
