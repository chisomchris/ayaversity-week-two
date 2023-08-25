// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

///@author chisomchris
///@title Banking Smart Contract Vault for saving and sending ethers

contract Voting {
    struct Proposal {
        uint id;
        string proposal;
        uint vote_count;
    }

    bool private _lock;
    address owner;
    uint start_time;
    uint stop_time;
    uint total_votes;
    mapping(address => bool) private voted;
    Proposal[] private proposals;
    string[] private winning_proposals;
    int[] private tier;

    event VoteCast(string indexed proposal, address voter);
    event ChangeOfOwner(address new_owner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Access denied");
        _;
    }
    modifier onlyBefore(uint time) {
        require(block.timestamp < time, "Too late");
        _;
    }
    modifier onlyAfter(uint time) {
        require(block.timestamp > time, "Too early");
        _;
    }
    modifier canVote() {
        require(!voted[msg.sender], "voted already");
        _;
    }

    constructor(uint start, uint stop, string[] memory _proposals) {
        owner = msg.sender;
        require(_proposals.length >= 2, "Proposals must be more than one");
        start_time = start;
        start_time = stop;
        for (uint16 i = 0; i < _proposals.length; i++) {
            proposals.push(Proposal(i, _proposals[i], 0));
        }
    }

    ///@notice ownership and admin priviledge will be transfered to new account
    /// @param new_owner address of new admin
    function ChangeOwner(address new_owner) public onlyOwner {
        require(
            new_owner != address(0) || address(new_owner) == new_owner,
            "Invalid address"
        );
        owner = new_owner;
        emit ChangeOfOwner(new_owner);
    }

    ///@param index index of chosen proposal, must be positive
    function vote(
        uint16 index
    ) public canVote onlyAfter(start_time) onlyBefore(stop_time) {
        voted[msg.sender] = true;
        proposals[index].vote_count++;
        total_votes++;
    }

    function getProposals() public view returns (Proposal[] memory) {
        return proposals;
    }

    function winner() public returns (string[] memory) {
        int winning_index = _checkWinner();
        winning_proposals = new string[](0);
        if (winning_index == -1) {
            for (uint i = 0; i < tier.length; i++) {
                winning_proposals.push(proposals[uint(tier[i])].proposal);
            }
        } else {
            winning_proposals.push(proposals[uint(winning_index)].proposal);
        }
        return winning_proposals;
    }

    function _checkWinner() private returns (int) {
        uint winning_count;
        int winning_index;

        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].vote_count == winning_count) {
                if (tier.length == 0) {
                    tier.push(winning_index);
                }
                tier.push(int(i));
                winning_index = -1;
            } else if (proposals[i].vote_count > winning_count) {
                if (tier.length > 0) {
                    tier = new int[](0);
                }
                winning_count = proposals[i].vote_count;
                winning_index = int(i);
            }
        }
        return winning_index;
    }
}
