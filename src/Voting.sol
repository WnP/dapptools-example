pragma solidity ^0.4.24;

contract Voting {
	mapping (bytes32 => uint256) public votes;

	bytes32[] public candidates;

	bytes32 constant steeve = "Steeve";
	bytes32 constant bob = "Bob";
	bytes32 constant alice = "Alice";

	constructor () public {
		candidates.push(steeve);
		candidates.push(bob);
		candidates.push(alice);
	}

	function total_for(bytes32 candidate) public view returns (uint256) {
		require(is_valid(candidate), 'Invalid candidate');
		return votes[candidate];
	}

	function vote_for(bytes32 candidate) public {
		require(is_valid(candidate), 'Invalid candidate');
		votes[candidate] += 1;
	}

	function is_valid(bytes32 candidate) private view returns (bool) {
		for(uint i = 0; i < candidates.length; i++) {
			if (candidates[i] == candidate) {
				return true;
			}
		}
		return false;
	}
}
