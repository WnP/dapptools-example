pragma solidity ^0.4.24;

import "ds-test/test.sol";

import "./Voting.sol";

contract VotingTest is DSTest {
	Voting voting;
	bytes32 constant steeve = "Steeve";
	bytes32 constant bob = "Bob";
	bytes32 constant alice = "Alice";

	function setUp() public {
		voting = new Voting();
	}

	function testFail_basic_sanity() public {
		assertTrue(false);
	}

	function test_basic_sanity() public {
		assertTrue(true);
	}

	function test_votes() public {
		// Default votes should be equals to 0
		assertTrue(voting.total_for(steeve) == 0);
		assertTrue(voting.total_for(bob) == 0);
		assertTrue(voting.total_for(alice) == 0);
		// vote for steeve
		voting.vote_for(steeve);
		// Check results
		assertTrue(voting.total_for(steeve) == 1);
		assertTrue(voting.total_for(bob) == 0);
		assertTrue(voting.total_for(alice) == 0);
		// Vote twice for bob
		voting.vote_for(bob);
		voting.vote_for(bob);
		// Check results
		assertTrue(voting.total_for(steeve) == 1);
		assertTrue(voting.total_for(bob) == 2);
		assertTrue(voting.total_for(alice) == 0);
		// Vote 3 times for alice
		voting.vote_for(alice);
		voting.vote_for(alice);
		voting.vote_for(alice);
		assertTrue(voting.total_for(steeve) == 1);
		assertTrue(voting.total_for(bob) == 2);
		assertTrue(voting.total_for(alice) == 3);
	}
}
