pragma solidity ^0.4.24;

import "ds-test/test.sol";

import "./Voting.sol";

contract VotingTest is DSTest {
	Voting voting;
	bytes32 constant steeve = "Steeve";
	bytes32 constant bob = "Bob";
	bytes32[] candidates;

	function setUp() public {
		candidates.push(steeve);
		candidates.push(bob);
		voting = new Voting(candidates);
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
		// vote for steeve
		voting.vote_for(steeve);
		// Check results
		assertTrue(voting.total_for(steeve) == 1);
		assertTrue(voting.total_for(bob) == 0);
		// Vote twice for bob
		voting.vote_for(bob);
		voting.vote_for(bob);
		// Check results
		assertTrue(voting.total_for(steeve) == 1);
		assertTrue(voting.total_for(bob) == 2);
	}
}
